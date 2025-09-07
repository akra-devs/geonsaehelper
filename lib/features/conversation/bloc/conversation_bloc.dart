import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../common/analytics/analytics.dart';
import '../../conversation/domain/models.dart';
import '../../conversation/domain/constants.dart';
import '../../conversation/domain/suggestion.dart';
import '../../conversation/domain/question_flow.dart' as qf;
import 'conversation_event.dart';

part 'conversation_bloc.freezed.dart';


enum ConversationPhase { survey, intake, qna }

// ConversationQuestion and ConversationResult moved to domain models.

@freezed
class ConversationState with _$ConversationState {
  const factory ConversationState({
    required ConversationPhase phase,
    required bool awaitingChoice,
    ConversationQuestion? question,
    ConversationResult? result,
    String? message, // optional bot message to show
    String? userEcho, // optional user message to echo in UI
    String? suggestionReply, // optional bot reply from suggestion
    @Default(false) bool resetTriggered, // flag to trigger UI reset
  }) = _ConversationState;
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
    emit(state.copyWith(
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
    emit(state.copyWith(
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
    final nextStep = _findNextAskableStep(phase, _step);
    if (nextStep != -1) {
      _step = nextStep;
      _emitQuestion(emit, phase: phase, step: _step);
    } else {
      if (phase == ConversationPhase.survey) {
        final surveyDuration = DateTime.now().difference(_phaseStartedAt).inMilliseconds;
        Analytics.instance.quickSurveyComplete(qf.surveyFlow.length, surveyDuration);
        // Transition to intake
        _step = 0;
        _phaseStartedAt = DateTime.now();
        emit(const ConversationState(
          phase: ConversationPhase.intake,
          awaitingChoice: false,
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
    emit(ConversationState(phase: phase, awaitingChoice: true, question: cq));
  }

  // Branch visibility rules
  bool _shouldAsk(String qid) {
    if (qid == 'P4a') {
      return _answers['P4'] == 'fa_86_100';
    }
    if (qid == 'S1a') {
      return _answers['S1'] == 'yes';
    }
    return true;
  }

  int _findNextAskableStep(ConversationPhase phase, int fromExclusive) {
    final list = phase == ConversationPhase.survey ? qf.surveyFlow : qf.intakeFlow;
    for (int i = fromExclusive + 1; i < list.length; i++) {
      if (_shouldAsk(list[i].qid)) return i;
    }
    return -1;
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
        const ['세대주: 정부24 확인', '면적: 등기/건축물대장 확인', '보증금: 계약서 확인'],
        '2025-09-08',
      ), hasUnknown: true, statusKey: 'not_possible_info');
      return;
    }

    // Disqualifier: 미성년(A3)
    if (_answers['A3'] == 'under19') {
      _emitResult(
        emit,
        ConversationResult(
          RulingStatus.notPossibleDisq,
          '아래 결격 사유로 신청이 불가합니다.',
          const [Reason('성년 요건 미충족(만 19세 미만)', ReasonKind.unmet)],
          const ['연령 요건 충족 시 재진행'],
          '2025-09-08',
        ),
        hasUnknown: false,
        statusKey: 'not_possible_disq',
      );
      return;
    }

    // Disqualifier: 무주택 요건 미충족(A2)
    if (_answers['A2'] == 'no') {
      _emitResult(
        emit,
        ConversationResult(
          RulingStatus.notPossibleDisq,
          '아래 결격 사유로 신청이 불가합니다.',
          const [Reason('무주택 요건 불충족(세대원 보유)', ReasonKind.unmet)],
          const ['보유 주택 처분 후 재진행'],
          '2025-09-08',
        ),
        hasUnknown: false,
        statusKey: 'not_possible_disq',
      );
      return;
    }

    // Disqualifier: 결격/제한(C1)
    if (_answers['C1'] == 'has') {
      _emitResult(
        emit,
        ConversationResult(
          RulingStatus.notPossibleDisq,
          '아래 결격 사유로 신청이 불가합니다.',
          const [Reason('신용/공공임대 등 결격 사항', ReasonKind.unmet)],
          const ['신용 상태/거주 형태 확인 후 재시도'],
          '2025-09-08',
        ),
        hasUnknown: false,
        statusKey: 'not_possible_disq',
      );
      return;
    }

    // Disqualifier: 소득/자산 상한 초과(A6/A7)
    if (_answers['A6'] == 'inc_over' || _answers['A7'] == 'asset_over') {
      final reasons = <Reason>[
        if (_answers['A6'] == 'inc_over') const Reason('소득 상한 초과', ReasonKind.unmet),
        if (_answers['A7'] == 'asset_over') const Reason('자산 상한 초과', ReasonKind.unmet),
      ];
      _emitResult(
        emit,
        ConversationResult(
          RulingStatus.notPossibleDisq,
          '아래 결격 사유로 신청이 불가합니다.',
          reasons,
          const ['조건 충족 가능한 상품군 재탐색 또는 조건 변경'],
          '2025-09-08',
        ),
        hasUnknown: false,
        statusKey: 'not_possible_disq',
      );
      return;
    }

    // Disqualifier: 대상 주택 유형 불가(P3)
    if (_answers['P3'] == 'other') {
      _emitResult(
        emit,
        ConversationResult(
          RulingStatus.notPossibleDisq,
          '아래 결격 사유로 신청이 불가합니다.',
          const [Reason('대상 주택 유형 아님(비주거 등)', ReasonKind.unmet)],
          const ['주거용 유형으로 조건 변경 후 재진행'],
          '2025-09-08',
        ),
        hasUnknown: false,
        statusKey: 'not_possible_disq',
      );
      return;
    }

    // Disqualifier: 전용면적 초과(P4) — 읍·면 100㎡ 예외 처리
    if (_answers['P4'] == 'fa_gt100') {
      _emitResult(
        emit,
        ConversationResult(
          RulingStatus.notPossibleDisq,
          '아래 결격 사유로 신청이 불가합니다.',
          const [Reason('전용면적 100㎡ 초과(예외 없음)', ReasonKind.unmet)],
          const ['면적 조건 충족 주택으로 재검토'],
          '2025-09-08',
        ),
        hasUnknown: false,
        statusKey: 'not_possible_disq',
      );
      return;
    }
    if (_answers['P4'] == 'fa_86_100' && _answers['P4a'] == 'no') {
      _emitResult(
        emit,
        ConversationResult(
          RulingStatus.notPossibleDisq,
          '아래 결격 사유로 신청이 불가합니다.',
          const [Reason('전용면적 85㎡ 초과(읍·면 아님)', ReasonKind.unmet)],
          const ['면적·입지 조건 충족 주택으로 재검토'],
          '2025-09-08',
        ),
        hasUnknown: false,
        statusKey: 'not_possible_disq',
      );
      return;
    }

    // Disqualifier: 지역별 보증금 상한 초과(P2+P5)
    final region = _answers['P2'];
    final dep = _answers['P5'];
    if (region != null && dep != null) {
      final isMetro = region == 'metro';
      final overLimit = (!isMetro && dep == 'dep_le3') || (isMetro && dep == 'dep_gt3');
      if (overLimit) {
        _emitResult(
          emit,
          ConversationResult(
            RulingStatus.notPossibleDisq,
            '아래 결격 사유로 신청이 불가합니다.',
            const [Reason('지역별 임차보증금 상한 초과', ReasonKind.unmet)],
            const ['보증금 조정 또는 타 상품 검토'],
            '2025-09-08',
          ),
          hasUnknown: false,
          statusKey: 'not_possible_disq',
        );
        return;
      }
    }

    // Otherwise, possible
    final reasons = <Reason>[
      const Reason('세대주/무주택 요건: (충족)', ReasonKind.met),
      if (_answers.containsKey('A6')) const Reason('소득 상한: (충족)', ReasonKind.met),
      if (_answers.containsKey('A7')) const Reason('자산 상한: (충족)', ReasonKind.met),
      if (_answers.containsKey('P3')) const Reason('대상 주택 유형: (충족)', ReasonKind.met),
      if (_answers.containsKey('P4')) const Reason('전용면적: (충족/예외 확인)', ReasonKind.met),
      if (_answers.containsKey('P2')) const Reason('지역 요건/우대: (확인)', ReasonKind.met),
      if (_answers.containsKey('P5')) const Reason('보증금 상한: (충족)', ReasonKind.met),
      if (_answers['P1'] == 'no') const Reason('계약/5% 미지급 → 기한 유의', ReasonKind.warning),
      if (_answers['S1'] == 'yes') const Reason('전세피해자 라우팅 가능(특례)', ReasonKind.warning),
    ];
    _emitResult(
      emit,
      ConversationResult(
        RulingStatus.possible,
        '예비판정 결과, \'해당\'합니다. 체크리스트를 확인하세요.',
        const [], // reasons replaced below to keep const
        const ['신분증·가족/혼인관계·소득 증빙 준비', '임대인 등기부등본/계약서 사본', '은행 상담 → 심사 → 승인 → 실행'],
        '2025-09-08',
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
      result: r,
    ));
  }

  String _unknownLabel(String qid) {
    switch (qid) {
      case 'A1':
        return '세대주 여부';
      case 'A2':
        return '세대원 무주택 여부';
      case 'A3':
        return '나이대(만)';
      case 'A4':
        return '혼인 상태';
      case 'A5':
        return '최근 2년 내 출산';
      case 'A6':
        return '연소득 구간';
      case 'A7':
        return '순자산 구간';
      case 'C1':
        return '결격/제한(신용·공공임대)';
      case 'P1':
        return '계약 및 5% 지급';
      case 'P2':
        return '지역';
      case 'P3':
        return '주택 유형';
      case 'P4':
        return '전용면적';
      case 'P4a':
        return '읍·면 소재 여부';
      case 'P5':
        return '임차보증금';
      case 'S1':
        return '전세피해자 여부';
      case 'S1a':
        return '임차권등기 설정';
      default:
        return qid;
    }
  }

  bool _isSurveyQid(String qid) => qid.startsWith('QS');
}
