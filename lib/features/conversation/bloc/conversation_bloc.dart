import 'package:meta/meta.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../common/analytics/analytics.dart';
import '../../conversation/domain/models.dart';
import '../../conversation/domain/constants.dart';
import '../../conversation/domain/suggestion.dart';
import '../../conversation/domain/question_flow.dart' as qf;
import 'conversation_event.dart';


enum ConversationPhase { survey, intake, qna }

// ConversationQuestion and ConversationResult moved to domain models.

@immutable
class ConversationState {
  final ConversationPhase phase;
  final bool awaitingChoice;
  final ConversationQuestion? question;
  final ConversationResult? result;
  final String? message; // optional bot message to show
  final String? userEcho; // optional user message to echo in UI
  final String? suggestionReply; // optional bot reply from suggestion
  final bool resetTriggered; // flag to trigger UI reset
  
  const ConversationState({
    required this.phase,
    required this.awaitingChoice,
    this.question,
    this.result,
    this.message,
    this.userEcho,
    this.suggestionReply,
    this.resetTriggered = false,
  });

  ConversationState copyWith({
    ConversationPhase? phase,
    bool? awaitingChoice,
    ConversationQuestion? question,
    ConversationResult? result,
    String? message,
    String? userEcho,
    String? suggestionReply,
    bool? resetTriggered,
  }) => ConversationState(
        phase: phase ?? this.phase,
        awaitingChoice: awaitingChoice ?? this.awaitingChoice,
        question: question,
        result: result,
        message: message,
        userEcho: userEcho,
        suggestionReply: suggestionReply,
        resetTriggered: resetTriggered ?? this.resetTriggered,
      );
}

class ConversationBloc extends Bloc<ConversationEvent, ConversationState> {
  int _step = 0;
  final Map<String, String> _answers = {};
  DateTime _phaseStartedAt = DateTime.now();

  ConversationBloc() : super(const ConversationState(phase: ConversationPhase.survey, awaitingChoice: false)) {
    on<ConversationStarted>(_onStarted);
    on<ChoiceSelected>(_onChoiceSelected);
    on<SuggestionSelected>(_onSuggestionSelected);
    on<ConversationReset>(_onReset);
  }

  void _onStarted(ConversationStarted event, Emitter<ConversationState> emit) {
    _phaseStartedAt = DateTime.now();
    _emitQuestion(emit, phase: ConversationPhase.survey, step: 0);
  }

  void _onChoiceSelected(ChoiceSelected event, Emitter<ConversationState> emit) {
    // Resolve label for echoing in UI
    String label;
    if (event.value == conversationUnknownValue) {
      label = '모름';
    } else {
      final q = state.question;
      if (q == null) {
        label = event.value;
      } else {
        final match = q.choices.where((c) => c.value == event.value);
        label = match.isNotEmpty ? match.first.text : event.value;
      }
    }
    
    // Emit echo-only state so UI appends just the user message.
    // Do NOT include a question here to avoid duplicate question renders.
    emit(ConversationState(
      phase: state.phase,
      awaitingChoice: state.awaitingChoice,
      question: null,
      result: null,
      message: null,
      userEcho: label,
    ));

    // Log measurement and continue with canonical answer flow
    Analytics.instance.intakeAnswer(event.qid, event.value, event.value == conversationUnknownValue);
    _answer(emit, event.qid, event.value);
  }

  void _onSuggestionSelected(SuggestionSelected event, Emitter<ConversationState> emit) {
    // Get suggestion data by ID from domain layer
    final suggestion = SuggestionActions.all[event.suggestionId];
    if (suggestion == null) return;
    
    // Emit echo-only state to prevent duplicate question rendering
    emit(ConversationState(
      phase: state.phase,
      awaitingChoice: state.awaitingChoice,
      question: null,        // Prevent duplicate question rendering
      result: null,          // Clear result as well 
      message: null,
      userEcho: suggestion.label,
      suggestionReply: suggestion.botReply,
    ));
    
    // Log analytics
    Analytics.instance.nextStepClick(suggestion.label);
  }

  void _onReset(ConversationReset event, Emitter<ConversationState> emit) {
    _step = 0;
    _answers.clear();
    _phaseStartedAt = DateTime.now();
    emit(const ConversationState(
      phase: ConversationPhase.survey, 
      awaitingChoice: false,
      resetTriggered: true,
    ));
  }

  void _answer(Emitter<ConversationState> emit, String qid, String value) {
    final phase = state.phase;
    _answers[qid] = value;
    final list = phase == ConversationPhase.survey ? qf.surveyFlow : qf.intakeFlow;
    if (_step < list.length - 1) {
      _step += 1;
      _emitQuestion(emit, phase: phase, step: _step);
    } else {
      if (phase == ConversationPhase.survey) {
        final surveyDuration = DateTime.now().difference(_phaseStartedAt).inMilliseconds;
        Analytics.instance.quickSurveyComplete(qf.surveyFlow.length, surveyDuration);
        // Transition to intake
        _step = 0;
        _phaseStartedAt = DateTime.now();
        emit(ConversationState(
          phase: ConversationPhase.intake,
          awaitingChoice: false,
          question: null,
          result: null,
          message: '감사합니다. 답변을 반영해 예비판정을 시작할게요.',
        ));
        Analytics.instance.intakeStart();
        // Next question (intake)
        _emitQuestion(emit, phase: ConversationPhase.intake, step: 0);
      } else {
        _evaluateAndEmit(emit);
      }
    }
  }

  void _emitQuestion(Emitter<ConversationState> emit, {required ConversationPhase phase, required int step}) {
    final list = phase == ConversationPhase.survey ? qf.surveyFlow : qf.intakeFlow;
    final q = list[step];
    final cq = ConversationQuestion(
      qid: q.qid,
      label: q.label,
      choices: q.choices,
      index: step + 1,
      total: list.length,
      isSurvey: phase == ConversationPhase.survey,
    );
    emit(ConversationState(phase: phase, awaitingChoice: true, question: cq, result: null, message: null));
  }

  void _evaluateAndEmit(Emitter<ConversationState> emit) {
    // Unknowns
    final unknowns = _answers.entries
        .where((e) => e.value == conversationUnknownValue && !_isSurveyQid(e.key))
        .map((e) => e.key)
        .toList();
    if (unknowns.isNotEmpty) {
      final reasons = unknowns.map((qid) => Reason(_unknownLabel(qid), ReasonKind.unknown)).toList();
      _emitResult(emit, ConversationResult(
        RulingStatus.notPossibleInfo,
        '다음 정보가 없어 판정 불가입니다.',
        reasons,
        const ['세대주: 정부24 확인', '보증금: 계약서 확인', '근저당: 등기부등본 열람'],
        '2025-09-02',
      ), hasUnknown: true, statusKey: 'not_possible_info');
      return;
    }

    // Disqualifier: A1 == 1주택
    if (_answers['A1'] == 'onehome') {
      _emitResult(
        emit,
        ConversationResult(
          RulingStatus.notPossibleDisq,
          '아래 결격 사유로 신청이 불가합니다.',
          const [Reason('무주택 요건 불충족', ReasonKind.unmet)],
          const ['조건 변경(보증금 조정) 또는 타 기관 검토'],
          '2025-09-02',
        ),
        hasUnknown: false,
        statusKey: 'not_possible_disq',
      );
      return;
    }

    // Disqualifier: 중대한 신용 문제(A7)
    if (_answers['A7'] == 'credit_severe') {
      _emitResult(
        emit,
        ConversationResult(
          RulingStatus.notPossibleDisq,
          '아래 결격 사유로 신청이 불가합니다.',
          const [Reason('중대한 신용 문제(장기연체/회생/파산/면책)', ReasonKind.unmet)],
          const ['신용 상태 확인 후 재시도 또는 타 상품 검토'],
          '2025-09-02',
        ),
        hasUnknown: false,
        statusKey: 'not_possible_disq',
      );
      return;
    }

    // Otherwise, possible
    final reasons = <Reason>[
      const Reason('가구/세대: (충족)', ReasonKind.met),
      if (_answers.containsKey('A3')) const Reason('소득 형태: (충족)', ReasonKind.met),
      if (_answers.containsKey('A4')) const Reason('소득 구간: (충족)', ReasonKind.met),
      if (_answers.containsKey('P1')) const Reason('주택 유형: (충족)', ReasonKind.met),
      if (_answers.containsKey('P2')) const Reason('전용면적: (충족)', ReasonKind.met),
      if (_answers.containsKey('P3')) const Reason('지역: (충족)', ReasonKind.met),
      if (_answers.containsKey('P4')) const Reason('보증금: (충족)', ReasonKind.met),
      if (_answers['P7'] == 'encumbrance_yes') const Reason('근저당 있음 → 등기 확인 필요', ReasonKind.warning),
    ];
    _emitResult(
      emit,
      ConversationResult(
        RulingStatus.possible,
        '예비판정 결과, \'해당\'합니다. 체크리스트를 확인하세요.',
        const [], // reasons replaced below to keep const
        const ['신분증·가족/혼인관계·소득 증빙 준비', '임대인 등기부등본/계약서 사본', '은행 상담 → 심사 → 승인 → 실행'],
        '2025-09-02',
      ),
      hasUnknown: false,
      statusKey: 'possible',
      overrideReasons: reasons,
    );
  }

  void _emitResult(Emitter<ConversationState> emit, ConversationResult result,
      {required bool hasUnknown, required String statusKey, List<Reason>? overrideReasons}) {
    final intakeDuration = DateTime.now().difference(_phaseStartedAt).inMilliseconds;
    Analytics.instance.intakeComplete(qf.intakeFlow.length, intakeDuration, hasUnknown, statusKey);
    Analytics.instance.rulingShown(statusKey);
    final r = overrideReasons == null
        ? result
        : ConversationResult(result.status, result.tldr, overrideReasons, result.nextSteps, result.lastVerified);
    emit(ConversationState(
      phase: ConversationPhase.qna,
      awaitingChoice: false,
      question: null,
      result: r,
      message: null,
    ));
  }

  String _unknownLabel(String qid) {
    switch (qid) {
      case 'A1':
        return '세대주 여부';
      case 'A2':
        return '혼인/부양 상태';
      case 'A3':
        return '소득 형태';
      case 'A4':
        return '소득 구간';
      case 'A5':
        return '재직/사업 기간';
      case 'A6':
        return '기존 대출/보증';
      case 'A7':
        return '신용/연체 이력';
      case 'P1':
        return '주택 유형';
      case 'P2':
        return '전용면적';
      case 'P3':
        return '지역';
      case 'P4':
        return '보증금(또는 보증금+월세)';
      case 'P5':
        return '계약 상태';
      case 'P6':
        return '입주 예정';
      case 'P7':
        return '등기 근저당';
      case 'S1':
        return '우대/특례';
      default:
        return qid;
    }
  }

  bool _isSurveyQid(String qid) => qid.startsWith('QS');
}