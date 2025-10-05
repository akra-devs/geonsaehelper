import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../common/analytics/analytics.dart';
import '../../conversation/domain/models.dart';
import '../../conversation/domain/constants.dart';
import '../../conversation/domain/suggestion.dart';
import '../../conversation/domain/rule_citations.dart';
import '../../conversation/domain/question_flow.dart' as qf;
import '../../conversation/domain/rules_engine.dart' as rules;
import '../../conversation/domain/copy_templates.dart' as copy;
import '../../history/domain/assessment_history.dart';
import '../../history/bloc/history_bloc.dart';
import '../../history/bloc/history_event.dart';
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
  final HistoryBloc? _historyBloc;

  ConversationBloc({HistoryBloc? historyBloc})
    : _historyBloc = historyBloc,
      super(
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
    // Keep result intact so AI chat tab remains enabled
    emit(
      state.copyWith(
        question: null, // Prevent duplicate question rendering
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
    if (qid == 'A8') {
      // 맞벌이 여부: 신생아 특례 응답 시에만 질문
      return _answers['A5'] == 'yes';
    }
    if (qid == 'A9' || qid == 'A10') {
      // 소득 6천 경계인 경우에만 질문(표준 6천 상향 반영 여부 확인)
      return _answers['A6'] == 'inc_le60m';
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
    // Pre-compute per-program results (ProgramMatches) for display
    final programMatches = _evaluateProgramMatches();
    // Unknowns
    final unknowns =
        _answers.entries
            .where(
              (e) =>
                  e.value == conversationUnknownValue && !_isSurveyQid(e.key),
            )
            .map((e) => e.key)
            .toList();
    final anyProgramPossible =
        programMatches.any((m) => m.status == RulingStatus.possible);
    if (unknowns.isNotEmpty && !anyProgramPossible) {
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
          programMatches,
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
          programMatches,
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
          programMatches,
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
          programMatches,
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
          programMatches,
        ),
        hasUnknown: false,
        statusKey: 'not_possible_disq',
      );
      return;
    }

    // Disqualifier: 중복대출 금지(C2)
    if (_answers['C2'] == 'fund_rent' ||
        _answers['C2'] == 'bank_rent' ||
        _answers['C2'] == 'mortgage') {
      _emitResult(
        emit,
        ConversationResult(
          RulingStatus.notPossibleDisq,
          '아래 결격 사유로 인해 신청이 불가합니다.',
          [
            Reason(
              '중복대출 금지(기존 전세/주담대 보유)',
              ReasonKind.unmet,
              RuleCitations.forQid('C2'),
            ),
          ],
          const ['기존 대출 상환/해지 후 재진행'],
          rulesLastVerifiedYmd,
        ),
        hasUnknown: false,
        statusKey: 'not_possible_disq',
      );
      return;
    }

    // Disqualifier: 소득/자산 상한 초과(A6/A7)
    {
      final a6 = _answers['A6'];
      final a7 = _answers['A7'];
      final isNewborn = _answers['A5'] == 'yes';
      // A8 is evaluated downstream where necessary
      final isNewly =
          _answers['A4'] == 'newly7y' || _answers['A4'] == 'marry_3m_planned';
      final isYouth = _answers['A3'] == 'y19_34';
      final children2p =
          _answers['A9'] == 'child2' || _answers['A9'] == 'child3p';
      final favored =
          _answers['A10'] == 'innov' ||
          _answers['A10'] == 'redevelop' ||
          _answers['A10'] == 'risky';

      // Asset cap (임차군 공통: 3.37억원)
      if (a7 != null && (a7 == 'asset_le488' || a7 == 'asset_over')) {
        _emitResult(
          emit,
          ConversationResult(
            RulingStatus.notPossibleDisq,
            '아래 결격 사유로 인해 신청이 불가합니다.',
            [
              Reason(
                '자산 상한 초과(3.37억원)',
                ReasonKind.unmet,
                RuleCitations.forQid('A7'),
              ),
            ],
            const ['자산 확인 후 조건 충족 가능한 상품 검토'],
            rulesLastVerifiedYmd,
            programMatches,
          ),
          hasUnknown: false,
          statusKey: 'not_possible_disq',
        );
        return;
      }

      // Income cap by program priority: 신생아 > 신혼 > 청년 > 표준
      if (a6 != null) {
        if (isNewborn) {
          // 신생아 특례 소득 한도
          // - 단일소득: 1.3억원 이하
          // - 맞벌이: 2.0억원 이하
          if (a6 == 'inc_over') {
            // 2.0억원 초과는 (맞벌이 기준도 초과) → 결격
            _emitResult(
              emit,
              ConversationResult(
                RulingStatus.notPossibleDisq,
                '아래 결격 사유로 인해 신청이 불가합니다.',
                [
                  Reason('소득 상한 초과(신생아 특례 상한 초과)', ReasonKind.unmet, [
                    RuleCitations.newborn,
                  ]),
                ],
                const ['소득 확인 후 조건 충족 가능한 상품 검토'],
                rulesLastVerifiedYmd,
                programMatches,
              ),
              hasUnknown: false,
              statusKey: 'not_possible_disq',
            );
            return;
          }

          if (a6 == 'inc_le200m') {
            // 1.3~2.0억 구간: 맞벌이 여부(A8)에 따라 판정 분기
            final a8 = _answers['A8'];
            if (a8 == 'yes') {
              // 맞벌이 2억 이하 → 충족(통과)
            } else if (a8 == 'no') {
              // 단일소득 1.3억 초과 → 결격
              _emitResult(
                emit,
                ConversationResult(
                  RulingStatus.notPossibleDisq,
                  '아래 결격 사유로 인해 신청이 불가합니다.',
                  [
                    Reason('소득 상한 초과(신생아 특례 단일소득 1.3억원)', ReasonKind.unmet, [
                      RuleCitations.newborn,
                    ]),
                  ],
                  const ['소득 확인 후 조건 충족 가능한 상품 검토'],
                  rulesLastVerifiedYmd,
                  programMatches,
                ),
                hasUnknown: false,
                statusKey: 'not_possible_disq',
              );
              return;
            } else if (a8 == conversationUnknownValue) {
              // 맞벌이 여부가 ‘모름’이면 정보 부족 처리
              final reasons = [
                Reason('맞벌이 여부 확인 필요(신생아 특례 1.3~2.0억 경계)', ReasonKind.unknown, [
                  RuleCitations.newborn,
                ]),
              ];
              _emitResult(
                emit,
                ConversationResult(
                  RulingStatus.notPossibleInfo,
                  '다음 항목의 정보가 확인되지 않아 판정이 불가합니다.\n해당 정보를 확인 후 다시 진행해 주세요.',
                  reasons,
                  const ['맞벌이 여부 확인 후 재판정'],
                  rulesLastVerifiedYmd,
                  programMatches,
                ),
                hasUnknown: true,
                statusKey: 'not_possible_info',
              );
              return;
            }
          }
        } else if (isNewly) {
          if (a6 == 'inc_le130m' || a6 == 'inc_over') {
            _emitResult(
              emit,
              ConversationResult(
                RulingStatus.notPossibleDisq,
                '아래 결격 사유로 인해 신청이 불가합니다.',
                [
                  Reason('소득 상한 초과(신혼 7천5백만원)', ReasonKind.unmet, [
                    RuleCitations.newlywed,
                  ]),
                ],
                const ['소득 확인 후 조건 충족 가능한 상품 검토'],
                rulesLastVerifiedYmd,
                programMatches,
              ),
              hasUnknown: false,
              statusKey: 'not_possible_disq',
            );
            return;
          }
        } else if (isYouth) {
          if (a6 != 'inc_le50m') {
            _emitResult(
              emit,
              ConversationResult(
                RulingStatus.notPossibleDisq,
                '아래 결격 사유로 인해 신청이 불가합니다.',
                [
                  Reason('소득 상한 초과(청년 5천만원)', ReasonKind.unmet, [
                    RuleCitations.youth,
                  ]),
                ],
                const ['소득 확인 후 조건 충족 가능한 상품 검토'],
                rulesLastVerifiedYmd,
                programMatches,
              ),
              hasUnknown: false,
              statusKey: 'not_possible_disq',
            );
            return;
          }
        } else {
          // 표준형: 5천만원(다자녀/2자녀/우대 사유는 6천 허용)
          final allow6k = a6 == 'inc_le60m' && (children2p || favored);
          if (!(a6 == 'inc_le50m' || allow6k)) {
            _emitResult(
              emit,
              ConversationResult(
                RulingStatus.notPossibleDisq,
                '아래 결격 사유로 인해 신청이 불가합니다.',
                [
                  Reason(
                    allow6k ? '소득 상한(우대 6천) 범위 초과' : '소득 상한 초과(5천만원)',
                    ReasonKind.unmet,
                    [RuleCitations.incomeCap],
                  ),
                ],
                const ['소득 확인 후 조건 충족 가능한 상품 검토'],
                rulesLastVerifiedYmd,
                programMatches,
              ),
              hasUnknown: false,
              statusKey: 'not_possible_disq',
            );
            return;
          }
        }
      }
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
          programMatches,
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
          programMatches,
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
          programMatches,
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
    final isNewborn = _answers['A5'] == 'yes';
    final isYouth = _answers['A3'] == 'y19_34';
    final isDamages = _answers['S1'] == 'yes';
    if (region != null && dep != null) {
      final isMetro = region == 'metro';
      final isMetroCity = region == 'metrocity';
      final isOthers = region == 'others';
      // Interpret coarse bands conservatively
      // - 수도권: 일반 3억, 신혼 4억
      // - 비수도권(광역시/그 외): 일반 2억, 신혼 3억
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
                programMatches,
              ),
              hasUnknown: true,
              statusKey: 'not_possible_info',
            );
            return;
          } else if (isDamages) {
            // 피해자 특례: 수도권 보증금 상한 5억원 → 3억 초과는 경계(3~5억) 정보 부족 처리
            final reasons = [
              Reason(
                '보증금 구간이 경계값(3~5억)으로 정확한 금액 확인 필요',
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
                const ['보증금: 정확 금액 확인(3~5억 경계)', '계약서 재확인 후 재판정'],
                rulesLastVerifiedYmd,
                programMatches,
              ),
              hasUnknown: true,
              statusKey: 'not_possible_info',
            );
            return;
          } else if (isNewborn) {
            // 신생아 특례: 한도 2.4억(보증금 3억 기준) → 3억 초과는 결격
            _emitResult(
              emit,
              ConversationResult(
                RulingStatus.notPossibleDisq,
                '아래 결격 사유로 인해 신청이 불가합니다.',
                [
                  Reason(
                    '임차보증금 상한 초과(신생아 특례 최대 3억 기준)',
                    ReasonKind.unmet,
                    RuleCitations.forQid('P5'),
                  ),
                ],
                const ['보증금 조정 또는 타 상품 검토'],
                rulesLastVerifiedYmd,
                programMatches,
              ),
              hasUnknown: false,
              statusKey: 'not_possible_disq',
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
                    '임차보증금 상한 초과(수도권 3억)',
                    ReasonKind.unmet,
                    RuleCitations.forQid('P5'),
                  ),
                ],
                const ['보증금 조정 또는 타 상품 검토'],
                rulesLastVerifiedYmd,
                programMatches,
              ),
              hasUnknown: false,
              statusKey: 'not_possible_disq',
            );
            return;
          }
        }
        // 청년 전용: 보증금 한도 1.5억 경계 확인(≤2억/≤3억 응답 시 정보 부족 처리)
        if (isYouth && (dep == 'dep_le2' || dep == 'dep_le3')) {
          final reasons = [
            Reason('보증금 청년 한도(1.5억) 경계로 정확한 금액 확인 필요', ReasonKind.unknown, [
              RuleCitations.youth,
            ]),
          ];
          _emitResult(
            emit,
            ConversationResult(
              RulingStatus.notPossibleInfo,
              '다음 항목의 정보가 확인되지 않아 판정이 불가합니다.\n해당 정보를 확인 후 다시 진행해 주세요.',
              reasons,
              const ['보증금: 정확 금액 확인(1.5~2.0억 경계)', '계약서 재확인 후 재판정'],
              rulesLastVerifiedYmd,
              programMatches,
            ),
            hasUnknown: true,
            statusKey: 'not_possible_info',
          );
          return;
        }
      } else if (isMetroCity || isOthers) {
        // 비수도권(광역시/그 외)
        if (dep == 'dep_gt3') {
          if (isDamages) {
            // 피해자: 비수도권 4억 상한 → 3~4 경계는 정보 부족 처리
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
                programMatches,
              ),
              hasUnknown: true,
              statusKey: 'not_possible_info',
            );
            return;
          } else {
            // 3억 초과 → 신혼 예외(3억)도 초과 → 결격
            _emitResult(
              emit,
              ConversationResult(
                RulingStatus.notPossibleDisq,
                '아래 결격 사유로 인해 신청이 불가합니다.',
                [
                  Reason(
                    '임차보증금 상한 초과(비수도권 2~3억)',
                    ReasonKind.unmet,
                    RuleCitations.forQid('P5'),
                  ),
                ],
                const ['보증금 조정 또는 타 상품 검토'],
                rulesLastVerifiedYmd,
                programMatches,
              ),
              hasUnknown: false,
              statusKey: 'not_possible_disq',
            );
            return;
          }
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
              programMatches,
            ),
            hasUnknown: true,
            statusKey: 'not_possible_info',
          );
          return;
        }
        // 청년 전용: 비수도권도 동일하게 1.5억 경계 확인
        if (isYouth && (dep == 'dep_le2' || dep == 'dep_le3')) {
          final reasons = [
            Reason('보증금 청년 한도(1.5억) 경계로 정확한 금액 확인 필요', ReasonKind.unknown, [
              RuleCitations.youth,
            ]),
          ];
          _emitResult(
            emit,
            ConversationResult(
              RulingStatus.notPossibleInfo,
              '다음 항목의 정보가 확인되지 않아 판정이 불가합니다.\n해당 정보를 확인 후 다시 진행해 주세요.',
              reasons,
              const ['보증금: 정확 금액 확인(1.5~2.0억 경계)', '계약서 재확인 후 재판정'],
              rulesLastVerifiedYmd,
              programMatches,
            ),
            hasUnknown: true,
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
      if (_answers['S1'] == 'yes')
        Reason(
          '전세피해자 특례 경로 안내 대상',
          ReasonKind.warning,
          RuleCitations.forQid('S1'),
        ),
      if (_answers['S1a'] == 'yes')
        Reason('임차권등기 설정: (확인)', ReasonKind.met, RuleCitations.forQid('S1a')),
      if (_answers['P7'] == 'yes')
        Reason(
          '등기상 근저당 있음: (주의)',
          ReasonKind.warning,
          RuleCitations.forQid('P7'),
        ),
      if (_answers['A3'] == 'y19_34')
        Reason('청년 연령 요건: (충족)', ReasonKind.met, RuleCitations.forQid('A3')),
      if (_answers['A4'] == 'newly7y' || _answers['A4'] == 'marry_3m_planned')
        Reason('신혼 요건: (충족)', ReasonKind.met, RuleCitations.forQid('A4')),
      if (_answers['A5'] == 'yes')
        Reason('신생아 특례 요건: (충족)', ReasonKind.met, RuleCitations.forQid('A5')),
    ];
    final tldr = copy.buildTldrPossible(_answers);
    _emitResult(
      emit,
      ConversationResult(
        RulingStatus.possible,
        tldr,
        const [],
        copy.buildNextSteps(_answers),
        rulesLastVerifiedYmd,
        programMatches,
      ),
      hasUnknown: false,
      statusKey: 'possible',
      overrideReasons: reasons,
    );
  }

  

  // Compute per-program matches based on current answers.
  List<ProgramMatch> _evaluateProgramMatches() {
    final matches = rules.evaluateProgramMatches(_answers);
    for (int i = 0; i < matches.length; i++) {
      Analytics.instance.programEvaluated(
        matches[i].programId.name,
        _statusKey(matches[i].status),
      );
    }
    return matches;
  }

  String _statusKey(RulingStatus s) {
    switch (s) {
      case RulingStatus.possible:
        return 'possible';
      case RulingStatus.notPossibleInfo:
        return 'not_possible_info';
      case RulingStatus.notPossibleDisq:
        return 'not_possible_disq';
    }
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
              result.programMatches,
            );

    // Save to history
    _saveToHistory(r);

    // Emit result and move to Q&A phase
    emit(
      ConversationState(
        phase: ConversationPhase.qna,
        awaitingChoice: false,
        result: r,
      ),
    );
  }

  Future<void> _saveToHistory(ConversationResult result) async {
    if (_historyBloc == null) {
      print('⚠️ [history] HistoryBloc is null, skipping save');
      return;
    }

    try {
      final now = DateTime.now();
      final history = AssessmentHistory(
        id: now.millisecondsSinceEpoch.toString(),
        timestamp: now,
        status: result.status,
        tldr: result.tldr,
        responses: Map.from(_answers),
        lastVerified: result.lastVerified,
      );
      print('💾 [conversation-bloc] Saving to history: ${history.id} (${history.status})');
      _historyBloc.add(HistoryEvent.save(history));
      print('✅ [conversation-bloc] History save event dispatched');
    } catch (e, stack) {
      print('❌ [conversation-bloc] Failed to save assessment history: $e');
      print('📍 [conversation-bloc] Stack: $stack');
      // Don't throw - history save failure should not block user flow
    }
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
      case 'A8':
        return '맞벌이 여부';
      case 'A6':
        return '연소득 구간';
      case 'A7':
        return '순자산 구간';
      case 'A9':
        return '자녀 수';
      case 'A10':
        return '우대 사유';
      case 'C1':
        return '결격/제한(신용·공공임대)';
      case 'C2':
        return '기존 대출/보증';
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
      case 'P7':
        return '등기 근저당 유무';
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
