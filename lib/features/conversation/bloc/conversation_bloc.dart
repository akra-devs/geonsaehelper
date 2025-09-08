import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../common/analytics/analytics.dart';
import '../../conversation/domain/models.dart';
import '../../conversation/domain/constants.dart';
import '../../conversation/domain/suggestion.dart';
import '../../conversation/domain/rule_citations.dart';
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

  ConversationBloc()
    : super(
        const ConversationState(
          phase: ConversationPhase.survey,
          awaitingChoice: false,
        ),
      ) {
    on<ConversationStarted>(_onStarted);
    on<ChoiceSelected>(_onChoiceSelected);
    on<SuggestionSelected>(_onSuggestionSelected);
    on<ConversationReset>(_onReset);
  }

  void _onStarted(ConversationStarted event, Emitter<ConversationState> emit) {
    _phaseStartedAt = DateTime.now();
    _emitQuestion(emit, phase: ConversationPhase.survey, step: 0);
  }

  void _onChoiceSelected(
    ChoiceSelected event,
    Emitter<ConversationState> emit,
  ) {
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
    emit(
      state.copyWith(
        question: null,
        result: null,
        message: null,
        userEcho: label,
      ),
    );

    // Log measurement and continue with canonical answer flow
    Analytics.instance.intakeAnswer(
      event.qid,
      event.value,
      event.value == conversationUnknownValue,
    );
    _answer(emit, event.qid, event.value);
  }

  void _onSuggestionSelected(
    SuggestionSelected event,
    Emitter<ConversationState> emit,
  ) {
    // Get suggestion data by ID from domain layer
    final suggestion = SuggestionActions.all[event.suggestionId];
    if (suggestion == null) return;

    // Emit echo-only state to prevent duplicate question rendering
    emit(
      state.copyWith(
        question: null, // Prevent duplicate question rendering
        result: null, // Clear result as well
        message: null,
        userEcho: suggestion.label,
        suggestionReply: suggestion.botReply,
      ),
    );

    // Log analytics
    Analytics.instance.nextStepClick(suggestion.label);
  }

  void _onReset(ConversationReset event, Emitter<ConversationState> emit) {
    _step = 0;
    _answers.clear();
    _phaseStartedAt = DateTime.now();
    emit(
      const ConversationState(
        phase: ConversationPhase.survey,
        awaitingChoice: false,
        resetTriggered: true,
      ),
    );
  }

  void _answer(Emitter<ConversationState> emit, String qid, String value) {
    final phase = state.phase;
    _answers[qid] = value;
    final nextStep = _findNextAskableStep(phase, _step);
    if (nextStep != -1) {
      _step = nextStep;
      _emitQuestion(emit, phase: phase, step: _step);
    } else {
      if (phase == ConversationPhase.survey) {
        final surveyDuration =
            DateTime.now().difference(_phaseStartedAt).inMilliseconds;
        Analytics.instance.quickSurveyComplete(
          qf.surveyFlow.length,
          surveyDuration,
        );
        // Transition to intake
        _step = 0;
        _phaseStartedAt = DateTime.now();
        emit(
          const ConversationState(
            phase: ConversationPhase.intake,
            awaitingChoice: false,
            message: '감사합니다. 답변을 반영해 예비판정을 시작할게요.',
          ),
        );
        Analytics.instance.intakeStart();
        // Next question (intake)
        _emitQuestion(emit, phase: ConversationPhase.intake, step: 0);
      } else {
        _evaluateAndEmit(emit);
      }
    }
  }

  void _emitQuestion(
    Emitter<ConversationState> emit, {
    required ConversationPhase phase,
    required int step,
  }) {
    final list =
        phase == ConversationPhase.survey ? qf.surveyFlow : qf.intakeFlow;
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
    final list =
        phase == ConversationPhase.survey ? qf.surveyFlow : qf.intakeFlow;
    for (int i = fromExclusive + 1; i < list.length; i++) {
      if (_shouldAsk(list[i].qid)) return i;
    }
    return -1;
  }

  void _evaluateAndEmit(Emitter<ConversationState> emit) {
    // Unknowns
    final unknowns =
        _answers.entries
            .where(
              (e) =>
                  e.value == conversationUnknownValue && !_isSurveyQid(e.key),
            )
            .map((e) => e.key)
            .toList();
    if (unknowns.isNotEmpty) {
      final reasons =
          unknowns
              .map(
                (qid) => Reason(
                  _unknownLabel(qid),
                  ReasonKind.unknown,
                  RuleCitations.forQid(qid),
                ),
              )
              .toList();
      _emitResult(
        emit,
        ConversationResult(
          RulingStatus.notPossibleInfo,
          '다음 항목의 정보가 확인되지 않아 판정이 불가합니다.\n해당 정보를 확인 후 다시 진행해 주세요.',
          reasons,
          const ['세대주: 정부24 확인', '면적: 등기/건축물대장 확인', '보증금: 계약서 확인'],
          rulesLastVerifiedYmd,
        ),
        hasUnknown: true,
        statusKey: 'not_possible_info',
      );
      return;
    }

    // Disqualifier: 미성년(A3)
    if (_answers['A3'] == 'under19') {
      _emitResult(
        emit,
        ConversationResult(
          RulingStatus.notPossibleDisq,
          '아래 결격 사유로 인해 신청이 불가합니다.',
          [
            Reason(
              '성년 요건 미충족(만 19세 미만)',
              ReasonKind.unmet,
              RuleCitations.forQid('A3'),
            ),
          ],
          const ['연령 요건 충족 시 재진행'],
          rulesLastVerifiedYmd,
        ),
        hasUnknown: false,
        statusKey: 'not_possible_disq',
      );
      return;
    }

    // Disqualifier: 세대주 요건 미충족(A1)
    if (_answers['A1'] == 'household_member') {
      _emitResult(
        emit,
        ConversationResult(
          RulingStatus.notPossibleDisq,
          '아래 결격 사유로 인해 신청이 불가합니다.',
          [
            Reason(
              '세대주 요건 불충족(예비 세대주 아님)',
              ReasonKind.unmet,
              RuleCitations.forQid('A1'),
            ),
          ],
          const ['세대주 전환(전입/혼인 등) 후 재진행'],
          rulesLastVerifiedYmd,
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
          '아래 결격 사유로 인해 신청이 불가합니다.',
          [
            Reason(
              '무주택 요건 불충족(세대원 보유)',
              ReasonKind.unmet,
              RuleCitations.forQid('A2'),
            ),
          ],
          const ['보유 주택 처분 후 재진행'],
          rulesLastVerifiedYmd,
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
          '아래 결격 사유로 인해 신청이 불가합니다.',
          [
            Reason(
              '신용/공공임대 등 결격 사항',
              ReasonKind.unmet,
              RuleCitations.forQid('C1'),
            ),
          ],
          const ['신용 상태/거주 형태 확인 후 재시도'],
          rulesLastVerifiedYmd,
        ),
        hasUnknown: false,
        statusKey: 'not_possible_disq',
      );
      return;
    }

    // Disqualifier: 소득/자산 상한 초과(A6/A7)
    if (_answers['A6'] == 'inc_over' || _answers['A7'] == 'asset_over') {
      final reasons = <Reason>[
        if (_answers['A6'] == 'inc_over')
          Reason('소득 상한 초과', ReasonKind.unmet, RuleCitations.forQid('A6')),
        if (_answers['A7'] == 'asset_over')
          Reason('자산 상한 초과', ReasonKind.unmet, RuleCitations.forQid('A7')),
      ];
      _emitResult(
        emit,
        ConversationResult(
          RulingStatus.notPossibleDisq,
          '아래 결격 사유로 인해 신청이 불가합니다.',
          reasons,
          const ['조건 충족 가능한 상품군 재탐색 또는 조건 변경'],
          rulesLastVerifiedYmd,
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
          '아래 결격 사유로 인해 신청이 불가합니다.',
          [
            Reason(
              '대상 주택 유형 아님(비주거 등)',
              ReasonKind.unmet,
              RuleCitations.forQid('P3'),
            ),
          ],
          const ['주거용 유형으로 조건 변경 후 재진행'],
          rulesLastVerifiedYmd,
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
          '아래 결격 사유로 인해 신청이 불가합니다.',
          [
            Reason(
              '전용면적 100㎡ 초과(예외 없음)',
              ReasonKind.unmet,
              RuleCitations.forQid('P4'),
            ),
          ],
          const ['면적 조건 충족 주택으로 재검토'],
          rulesLastVerifiedYmd,
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
          '아래 결격 사유로 인해 신청이 불가합니다.',
          [
            Reason(
              '전용면적 85㎡ 초과(읍·면 아님)',
              ReasonKind.unmet,
              RuleCitations.forQid('P4a'),
            ),
          ],
          const ['면적·입지 조건 충족 주택으로 재검토'],
          rulesLastVerifiedYmd,
        ),
        hasUnknown: false,
        statusKey: 'not_possible_disq',
      );
      return;
    }

    // 지역별 보증금 상한(P2+P5) — 신혼 예외 고려
    final region = _answers['P2'];
    final dep = _answers['P5'];
    final isNewly =
        _answers['A4'] == 'newly7y' || _answers['A4'] == 'marry_3m_planned';
    if (region != null && dep != null) {
      final isMetro = region == 'metro';
      // Interpret coarse bands conservatively
      // - 수도권: 일반 3억, 신혼 4억
      // - 비수도권: 일반 2억, 신혼 3억
      if (isMetro) {
        if (dep == 'dep_gt3') {
          if (isNewly) {
            // 3~4억인지 4억 초과인지 불명확 → 정보 부족 처리
            final reasons = [
              Reason(
                '보증금 구간이 경계값(3~4억)으로 정확한 금액 확인 필요',
                ReasonKind.unknown,
                RuleCitations.forQid('P5'),
              ),
            ];
            _emitResult(
              emit,
              ConversationResult(
                RulingStatus.notPossibleInfo,
                '다음 항목의 정보가 확인되지 않아 판정이 불가합니다.\n해당 정보를 확인 후 다시 진행해 주세요.',
                reasons,
                const ['보증금: 정확 금액 확인(3~4억 경계)', '계약서 재확인 후 재판정'],
                rulesLastVerifiedYmd,
              ),
              hasUnknown: false,
              statusKey: 'not_possible_info',
            );
            return;
          } else {
            // 일반가구 수도권 3억 초과 → 결격
            _emitResult(
              emit,
              ConversationResult(
                RulingStatus.notPossibleDisq,
                '아래 결격 사유로 인해 신청이 불가합니다.',
                [
                  Reason(
                    '지역별 임차보증금 상한 초과(수도권 3억)',
                    ReasonKind.unmet,
                    RuleCitations.forQid('P5'),
                  ),
                ],
                const ['보증금 조정 또는 타 상품 검토'],
                rulesLastVerifiedYmd,
              ),
              hasUnknown: false,
              statusKey: 'not_possible_disq',
            );
            return;
          }
        }
      } else {
        // 비수도권(광역시/그 외)
        if (dep == 'dep_gt3') {
          // 3억 초과 → 신혼 예외(3억)도 초과
          _emitResult(
            emit,
            ConversationResult(
              RulingStatus.notPossibleDisq,
              '아래 결격 사유로 인해 신청이 불가합니다.',
              [
                Reason(
                  '지역별 임차보증금 상한 초과(비수도권 2~3억)',
                  ReasonKind.unmet,
                  RuleCitations.forQid('P5'),
                ),
              ],
              const ['보증금 조정 또는 타 상품 검토'],
              rulesLastVerifiedYmd,
            ),
            hasUnknown: false,
            statusKey: 'not_possible_disq',
          );
          return;
        }
        if (dep == 'dep_le3' && !isNewly) {
          // 2~3억 구간 → 일반가구 상한(2억)과 충돌 가능, 보수적 정보부족 처리
          final reasons = [
            Reason(
              '보증금 구간(≤3억)에서 2~3억 여부 확인 필요(비수도권 일반 2억 상한)',
              ReasonKind.unknown,
              RuleCitations.forQid('P5'),
            ),
          ];
          _emitResult(
            emit,
            ConversationResult(
              RulingStatus.notPossibleInfo,
              '다음 항목의 정보가 확인되지 않아 판정이 불가합니다.\n해당 정보를 확인 후 다시 진행해 주세요.',
              reasons,
              const ['보증금: 정확 금액 확인(2~3억 경계)', '계약서 재확인 후 재판정'],
              rulesLastVerifiedYmd,
            ),
            hasUnknown: false,
            statusKey: 'not_possible_info',
          );
          return;
        }
      }
    }

    // Otherwise, possible
    final reasons = <Reason>[
      Reason('세대주/무주택 요건: (충족)', ReasonKind.met, RuleCitations.forQid('A1')),
      if (_answers.containsKey('A6'))
        Reason('소득 상한: (충족)', ReasonKind.met, RuleCitations.forQid('A6')),
      if (_answers.containsKey('A7'))
        Reason('자산 상한: (충족)', ReasonKind.met, RuleCitations.forQid('A7')),
      if (_answers.containsKey('P3'))
        Reason('대상 주택 유형: (충족)', ReasonKind.met, RuleCitations.forQid('P3')),
      if (_answers.containsKey('P4'))
        Reason('전용면적: (충족/예외 확인)', ReasonKind.met, RuleCitations.forQid('P4')),
      if (_answers.containsKey('P2'))
        Reason('지역 요건/우대: (확인)', ReasonKind.met, RuleCitations.forQid('P2')),
      if (_answers.containsKey('P5'))
        Reason('보증금 상한: (충족)', ReasonKind.met, RuleCitations.forQid('P5')),
      if (_answers['P1'] == 'no')
        Reason(
          '계약/5% 미지급 → 기한 유의',
          ReasonKind.warning,
          RuleCitations.forQid('P1'),
        ),
      if (_answers['S1'] == 'yes')
        Reason(
          '전세피해자 특례 경로 안내 대상',
          ReasonKind.warning,
          RuleCitations.forQid('S1'),
        ),
      if (_answers['S1a'] == 'yes')
        Reason('임차권등기 설정: (확인)', ReasonKind.met, RuleCitations.forQid('S1a')),
      if (_answers['A3'] == 'y19_34')
        Reason('청년 연령 요건: (충족)', ReasonKind.met, RuleCitations.forQid('A3')),
      if (_answers['A4'] == 'newly7y' || _answers['A4'] == 'marry_3m_planned')
        Reason('신혼 요건: (충족)', ReasonKind.met, RuleCitations.forQid('A4')),
      if (_answers['A5'] == 'yes')
        Reason('신생아 특례 요건: (충족)', ReasonKind.met, RuleCitations.forQid('A5')),
    ];
    final tldr = _buildTldrPossible();
    _emitResult(
      emit,
      ConversationResult(
        RulingStatus.possible,
        tldr,
        const [],
        _buildNextSteps(),
        rulesLastVerifiedYmd,
      ),
      hasUnknown: false,
      statusKey: 'possible',
      overrideReasons: reasons,
    );
  }

  String _buildTldrPossible() {
    final regionLabel = () {
      switch (_answers['P2']) {
        case 'metro':
          return '수도권';
        case 'metrocity':
          return '광역시';
        case 'others':
          return '기타 지역';
        default:
          return '해당 지역';
      }
    }();
    final propertyLabel = () {
      switch (_answers['P3']) {
        case 'apartment':
          return '아파트';
        case 'officetel':
          return '오피스텔(주거)';
        case 'multi_family':
          return '다가구';
        case 'row_house':
          return '연립·다세대';
        case 'studio':
          return '원룸';
        default:
          return '주택';
      }
    }();
    final first =
        '예비판정 결과, $regionLabel의 $propertyLabel은(는) HUG 전세자금대출 대상에 ‘해당’합니다.';
    final second =
        '핵심 요건(무주택·세대주/소득/면적/보증금)을 충족한 것으로 확인되었습니다.\n아래 준비물을 확인해 주세요.';
    // Add up to two route hints by priority: damages > newborn > newly > youth
    final hints = <String>[];
    if (_answers['S1'] == 'yes') hints.add('전세피해자 특례 경로 안내 대상입니다.');
    if (_answers['A5'] == 'yes') hints.add('신생아 특례 경로도 검토 대상입니다.');
    if (_answers['A4'] == 'newly7y' || _answers['A4'] == 'marry_3m_planned') {
      hints.add('신혼 전용 경로도 검토 대상입니다.');
    }
    if (_answers['A3'] == 'y19_34') hints.add('청년 전용 경로도 검토 대상입니다.');
    final extra = hints.isEmpty ? '' : '\n${hints.take(2).join('\n')}';
    return '$first\n$second$extra';
  }

  List<String> _buildNextSteps() {
    final steps = <String>[];
    // Program-specific additions first
    if (_answers['S1'] == 'yes') {
      steps.add('피해자 확인서류/임차권등기(해당 시) 준비');
      steps.add('보증기관(HUG) 상담 경로 확인');
    }
    if (_answers['A5'] == 'yes') {
      steps.add('출생증명서 또는 가족관계등록부 준비');
    }
    if (_answers['A4'] == 'newly7y' || _answers['A4'] == 'marry_3m_planned') {
      steps.add('혼인관계증명서(또는 예정 증빙) 준비');
    }
    // Common checklist
    steps.addAll([
      '신분증·가족/혼인관계·소득 증빙 준비',
      '임대인 등기부등본/건축물대장(필요 시)/계약서 사본',
      '은행 상담 → 심사 → 보증 승인 → 실행',
    ]);
    return steps;
  }

  void _emitResult(
    Emitter<ConversationState> emit,
    ConversationResult result, {
    required bool hasUnknown,
    required String statusKey,
    List<Reason>? overrideReasons,
  }) {
    final intakeDuration =
        DateTime.now().difference(_phaseStartedAt).inMilliseconds;
    Analytics.instance.intakeComplete(
      qf.intakeFlow.length,
      intakeDuration,
      hasUnknown,
      statusKey,
    );
    Analytics.instance.rulingShown(statusKey);
    final r =
        overrideReasons == null
            ? result
            : ConversationResult(
              result.status,
              result.tldr,
              overrideReasons,
              result.nextSteps,
              result.lastVerified,
            );
    emit(
      ConversationState(
        phase: ConversationPhase.qna,
        awaitingChoice: false,
        result: r,
      ),
    );
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
