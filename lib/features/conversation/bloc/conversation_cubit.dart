import 'package:flutter/foundation.dart';
import 'package:meta/meta.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../common/analytics/analytics.dart';
import '../../conversation/domain/models.dart';

enum ConversationPhase { survey, intake, qna }

// ConversationQuestion and ConversationResult moved to domain models.

@immutable
class ConversationState {
  final ConversationPhase phase;
  final bool awaitingChoice;
  final ConversationQuestion? question;
  final ConversationResult? result;
  final String? message; // optional bot message to show
  const ConversationState({
    required this.phase,
    required this.awaitingChoice,
    this.question,
    this.result,
    this.message,
  });

  ConversationState copyWith({
    ConversationPhase? phase,
    bool? awaitingChoice,
    ConversationQuestion? question,
    ConversationResult? result,
    String? message,
  }) => ConversationState(
        phase: phase ?? this.phase,
        awaitingChoice: awaitingChoice ?? this.awaitingChoice,
        question: question,
        result: result,
        message: message,
      );
}

class ConversationCubit extends Cubit<ConversationState> {
  static const _unknown = '__unknown__';
  int _step = 0;
  final Map<String, String> _answers = {};
  DateTime _phaseStartedAt = DateTime.now();

  ConversationCubit() : super(const ConversationState(phase: ConversationPhase.survey, awaitingChoice: false));

  void start() {
    _phaseStartedAt = DateTime.now();
    _emitQuestion(phase: ConversationPhase.survey, step: 0);
  }

  void answer(String qid, String value) {
    final phase = state.phase;
    _answers[qid] = value;
    final list = phase == ConversationPhase.survey ? _surveyFlow : _flow;
    if (_step < list.length - 1) {
      _step += 1;
      _emitQuestion(phase: phase, step: _step);
    } else {
      if (phase == ConversationPhase.survey) {
        final surveyDuration = DateTime.now().difference(_phaseStartedAt).inMilliseconds;
        Analytics.instance.quickSurveyComplete(_surveyFlow.length, surveyDuration);
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
        _emitQuestion(phase: ConversationPhase.intake, step: 0);
      } else {
        _evaluateAndEmit();
      }
    }
  }

  void _emitQuestion({required ConversationPhase phase, required int step}) {
    final list = phase == ConversationPhase.survey ? _surveyFlow : _flow;
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

  void _evaluateAndEmit() {
    // Unknowns
    final unknowns = _answers.entries
        .where((e) => e.value == _unknown && !_isSurveyQid(e.key))
        .map((e) => e.key)
        .toList();
    if (unknowns.isNotEmpty) {
      final reasons = unknowns.map((qid) => Reason(_unknownLabel(qid), ReasonKind.unknown)).toList();
      _emitResult(ConversationResult(
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
      ConversationResult(
        RulingStatus.possible,
        '예비판정 결과, ‘해당’합니다. 체크리스트를 확인하세요.',
        const [], // reasons replaced below to keep const
        const ['신분증·가족/혼인관계·소득 증빙 준비', '임대인 등기부등본/계약서 사본', '은행 상담 → 심사 → 승인 → 실행'],
        '2025-09-02',
      ),
      hasUnknown: false,
      statusKey: 'possible',
      overrideReasons: reasons,
    );
  }

  void _emitResult(ConversationResult result,
      {required bool hasUnknown, required String statusKey, List<Reason>? overrideReasons}) {
    final intakeDuration = DateTime.now().difference(_phaseStartedAt).inMilliseconds;
    Analytics.instance.intakeComplete(_flow.length, intakeDuration, hasUnknown, statusKey);
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

  // Question flow (moved from UI)
  static final List<_Q> _flow = [
    _Q(
      qid: 'A1',
      label: '현재 무주택이며 세대주이신가요?',
      choices: const [
        Choice(value: 'owner', text: '무주택·세대주'),
        Choice(value: 'member', text: '무주택·세대원'),
        Choice(value: 'onehome', text: '1주택'),
      ],
    ),
    _Q(
      qid: 'A2',
      label: '혼인/부양 상태를 선택해 주세요.',
      choices: const [
        Choice(value: 'single', text: '미혼'),
        Choice(value: 'newly', text: '신혼(혼인 7년 이내)'),
        Choice(value: 'children', text: '자녀 있음'),
      ],
    ),
    _Q(
      qid: 'A3',
      label: '소득 형태를 선택해 주세요.',
      choices: const [
        Choice(value: 'work', text: '근로'),
        Choice(value: 'biz', text: '사업'),
        Choice(value: 'etc', text: '기타'),
      ],
    ),
    _Q(
      qid: 'A4',
      label: '연간 소득 구간을 선택해 주세요.',
      choices: const [
        Choice(value: 'inc1', text: '내부 구간 1'),
        Choice(value: 'inc2', text: '내부 구간 2'),
        Choice(value: 'inc3', text: '내부 구간 3'),
        Choice(value: 'inc4', text: '내부 구간 4'),
      ],
    ),
    _Q(
      qid: 'A5',
      label: '현재 재직/사업 기간은 얼마나 되나요?',
      choices: const [
        Choice(value: 'm0_6', text: '0~6개월'),
        Choice(value: 'm7_12', text: '7~12개월'),
        Choice(value: 'm13_24', text: '13~24개월'),
        Choice(value: 'm24p', text: '24개월 이상'),
      ],
    ),
    _Q(
      qid: 'A6',
      label: '보유 중인 대출/보증이 있나요?',
      choices: const [
        Choice(value: 'jeonse', text: '전세보증'),
        Choice(value: 'mtg', text: '주담대'),
        Choice(value: 'credit', text: '신용'),
        Choice(value: 'none', text: '없음'),
      ],
    ),
    _Q(
      qid: 'A7',
      label: '최근 연체·회생·파산·면책 이력이 있나요?',
      choices: const [
        Choice(value: 'credit_ok', text: '문제 없음'),
        Choice(value: 'credit_recent', text: '최근 연체'),
        Choice(value: 'credit_severe', text: '장기연체/회생/파산/면책'),
      ],
    ),
    _Q(
      qid: 'P1',
      label: '주택 유형을 선택해 주세요.',
      choices: const [
        Choice(value: 'apt', text: '아파트'),
        Choice(value: 'officetel', text: '오피스텔'),
        Choice(value: 'multifam', text: '다가구'),
        Choice(value: 'villa', text: '연립·다세대'),
        Choice(value: 'one_room', text: '원룸'),
        Choice(value: 'etc', text: '기타'),
      ],
    ),
    _Q(
      qid: 'P2',
      label: '전용면적 범위를 선택해 주세요.',
      choices: const [
        Choice(value: 'fa_le40', text: '≤ 40㎡'),
        Choice(value: 'fa_41_60', text: '41–60㎡'),
        Choice(value: 'fa_61_85', text: '61–85㎡'),
        Choice(value: 'fa_gt85', text: '85㎡ 초과'),
      ],
    ),
    _Q(
      qid: 'P3',
      label: '지역을 선택해 주세요.',
      choices: const [
        Choice(value: 'metro', text: '수도권'),
        Choice(value: 'metrocity', text: '광역시'),
        Choice(value: 'other', text: '기타'),
      ],
    ),
    _Q(
      qid: 'P4',
      label: '전세보증금(또는 보증금+월세)을 알려주세요.',
      choices: const [
        Choice(value: 'dep_le1', text: '1억 이하'),
        Choice(value: 'dep_1_2', text: '1~2억'),
        Choice(value: 'dep_2_3', text: '2~3억'),
        Choice(value: 'dep_gt3', text: '3억 이상'),
      ],
    ),
    _Q(
      qid: 'P5',
      label: '계약 상태를 알려주세요.',
      choices: const [
        Choice(value: 'pre', text: '계약 전'),
        Choice(value: 'precontract', text: '가계약'),
        Choice(value: 'contract', text: '본계약'),
      ],
    ),
    _Q(
      qid: 'P6',
      label: '입주 예정 시점을 알려주세요.',
      choices: const [
        Choice(value: 'w1', text: '1주 내'),
        Choice(value: 'w2_4', text: '2~4주'),
        Choice(value: 'm1_3', text: '1~3개월'),
        Choice(value: 'm3p', text: '3개월+'),
      ],
    ),
    _Q(
      qid: 'P7',
      label: '등기상 근저당이 있나요?',
      choices: const [
        Choice(value: 'encumbrance_yes', text: '있음'),
        Choice(value: 'encumbrance_no', text: '없음'),
      ],
    ),
    _Q(
      qid: 'S1',
      label: '우대/특례에 해당되나요?',
      choices: const [
        Choice(value: 'youth', text: '청년'),
        Choice(value: 'newly', text: '신혼'),
        Choice(value: 'multi', text: '다자녀'),
        Choice(value: 'lowinc', text: '저소득'),
        Choice(value: 'none', text: '해당 없음'),
      ],
    ),
  ];

  static final List<_Q> _surveyFlow = [
    const _Q(
      qid: 'QS1',
      label: '언제까지 준비가 필요하신가요?',
      choices: [
        Choice(value: 'soon', text: '2주 이내'),
        Choice(value: 'month1', text: '1개월 이내'),
        Choice(value: 'flex', text: '유연함'),
      ],
    ),
    const _Q(
      qid: 'QS2',
      label: '어떤 정보가 가장 궁금하신가요?',
      choices: [
        Choice(value: 'elig', text: '자격'),
        Choice(value: 'limit', text: '한도'),
        Choice(value: 'docs', text: '서류/절차'),
      ],
    ),
    const _Q(
      qid: 'QS3',
      label: '주 관심 지역을 선택해 주세요.',
      choices: [
        Choice(value: 'metro', text: '수도권'),
        Choice(value: 'metrocity', text: '광역시'),
        Choice(value: 'other', text: '기타'),
      ],
    ),
  ];
}

@immutable
class _Q {
  final String qid;
  final String label;
  final List<Choice> choices;
  const _Q({required this.qid, required this.label, required this.choices});
}
