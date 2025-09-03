import 'package:flutter/material.dart';
import '../../../ui/components/chat_bubble.dart';
import '../../../ui/components/intake_question.dart';
import '../../../ui/components/result_card.dart';
import '../../../ui/theme/app_theme.dart';
import '../../../ui/components/progress_inline.dart';
import '../../../ui/components/typing_indicator.dart';
import '../../../ui/components/ad_slot.dart';
import '../../../common/analytics/analytics.dart';
import '../../../ui/components/appear.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../conversation/bloc/chat_cubit.dart';
import '../../conversation/data/chat_repository.dart';
import '../../conversation/data/chat_models.dart';

class ConversationPage extends StatefulWidget {
  const ConversationPage({super.key});

  @override
  State<ConversationPage> createState() => _ConversationPageState();
}

class _ConversationPageState extends State<ConversationPage> {
  final List<_Row> _rows = [];
  final Map<String, String> _answers = {}; // qid -> value
  final TextEditingController _composer = TextEditingController();
  int _step = 0; // index of current question in _flow
  bool _awaitingChoice = true;

  _Phase _phase = _Phase.survey;
  DateTime _phaseStartedAt = DateTime.now();

  static const _unknown = '__unknown__';

  int? _typingRowIndex;

  @override
  void initState() {
    super.initState();
    // Kick off with greeting + first question
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _appendBotText('간단 조사를 통해 맞춤 안내를 준비할게요. 이후 예비판정을 진행합니다.');
      _askCurrent();
    });
  }

  @override
  void dispose() {
    _composer.dispose();
    super.dispose();
  }

  void _appendBotText(String text) {
    setState(() => _rows.add(_Row.bot(text)));
  }

  void _appendUserText(String text) {
    setState(() => _rows.add(_Row.user(text)));
  }

  void _appendQuestion(String qid, String label, List<Choice> choices) {
    setState(() {
      _rows.add(_Row.intake(qid: qid, label: label, choices: choices));
      _awaitingChoice = true;
    });
  }

  void _askCurrent() {
    final list = _phase == _Phase.survey ? _surveyFlow : _flow;
    final q = list[_step];
    _appendQuestion(q.qid, q.label, q.choices);
  }

  void _onChoiceSelected(String qid, String? value) {
    if (value == null) return;
    final label = value == _unknown
        ? '모름'
        : (context.read<ConversationCubit>().state.question?.choices.firstWhere((c) => c.value == value).text ?? value);
    _appendUserText(label);
    setState(() => _awaitingChoice = false);
    context.read<ConversationCubit>().answer(qid, value);
  }

  String _labelFor(_Question q, String value) {
    if (value == _unknown) return '모름';
    final match = q.choices.where((c) => c.value == value);
    return match.isNotEmpty ? match.first.text : value;
  }

  void _evaluateAndShow() {
    // Minimal evaluation logic per RULES_HUG_v1.md
    final unknowns = _answers.entries
        .where((e) => e.value == _unknown && !_isSurveyQid(e.key))
        .map((e) => e.key)
        .toList();
    if (unknowns.isNotEmpty) {
      final reasons = unknowns
          .map((qid) => ReasonItem(Icons.help_outline, _unknownLabel(qid), '확인불가'))
          .toList();
      _rows.add(_Row.result(ResultCard(
        status: RulingStatus.notPossibleInfo,
        tldr: '다음 정보가 없어 판정 불가입니다.',
        reasons: reasons,
        nextSteps: const [
          '세대주: 정부24 확인',
          '보증금: 계약서 확인',
          '근저당: 등기부등본 열람',
        ],
        lastVerified: '2025-09-02',
      )));
      final intakeDuration = DateTime.now().difference(_phaseStartedAt).inMilliseconds;
      Analytics.instance.intakeComplete(_flow.length, intakeDuration, true, 'not_possible_info');
      Analytics.instance.rulingShown('not_possible_info');
      setState(() {});
      _showSuggestionsAndAds();
      return;
    }

    // Disqualifier: A1 == 1주택
    if (_answers['A1'] == 'onehome') {
      _rows.add(_Row.result(ResultCard(
        status: RulingStatus.notPossibleDisq,
        tldr: '아래 결격 사유로 신청이 불가합니다.',
        reasons: const [
          ReasonItem(Icons.cancel, '무주택 요건 불충족', '미충족'),
        ],
        nextSteps: const ['조건 변경(보증금 조정) 또는 타 기관 검토'],
        lastVerified: '2025-09-02',
      )));
      final intakeDuration = DateTime.now().difference(_phaseStartedAt).inMilliseconds;
      Analytics.instance.intakeComplete(_flow.length, intakeDuration, false, 'not_possible_disq');
      Analytics.instance.rulingShown('not_possible_disq');
      setState(() {});
      _showSuggestionsAndAds();
      return;
    }

    // Disqualifier: 중대한 신용 문제(A7)
    if (_answers['A7'] == 'credit_severe') {
      _rows.add(_Row.result(ResultCard(
        status: RulingStatus.notPossibleDisq,
        tldr: '아래 결격 사유로 신청이 불가합니다.',
        reasons: const [
          ReasonItem(Icons.cancel, '중대한 신용 문제(장기연체/회생/파산/면책)', '미충족'),
        ],
        nextSteps: const ['신용 상태 확인 후 재시도 또는 타 상품 검토'],
        lastVerified: '2025-09-02',
      )));
      setState(() {});
      _appendBotText('필요 시 확인 방법을 안내해 드릴게요.');
      return;
    }

    // Otherwise, possible with summary reasons
    final reasons = <ReasonItem>[
      ReasonItem(Icons.check_circle, '가구/세대: ${_labelFor(_q('A1'), _answers['A1']!)}', '충족'),
      if (_answers.containsKey('A3'))
        ReasonItem(Icons.check_circle, '소득 형태: ${_labelFor(_q('A3'), _answers['A3']!)}', '충족'),
      if (_answers.containsKey('A4'))
        ReasonItem(Icons.check_circle, '소득 구간: ${_labelFor(_q('A4'), _answers['A4']!)}', '충족'),
      if (_answers.containsKey('P1'))
        ReasonItem(Icons.check_circle, '주택 유형: ${_labelFor(_q('P1'), _answers['P1']!)}', '충족'),
      if (_answers.containsKey('P2'))
        ReasonItem(Icons.check_circle, '전용면적: ${_labelFor(_q('P2'), _answers['P2']!)}', '충족'),
      if (_answers.containsKey('P3'))
        ReasonItem(Icons.check_circle, '지역: ${_labelFor(_q('P3'), _answers['P3']!)}', '충족'),
      if (_answers.containsKey('P4'))
        ReasonItem(Icons.check_circle, '보증금: ${_labelFor(_q('P4'), _answers['P4']!)}', '충족'),
      if (_answers['P7'] == 'encumbrance_yes')
        const ReasonItem(Icons.warning_amber, '근저당 있음 → 등기 확인 필요', '주의'),
    ];
    _rows.add(_Row.result(ResultCard(
      status: RulingStatus.possible,
      tldr: '예비판정 결과, ‘해당’합니다. 체크리스트를 확인하세요.',
      reasons: reasons,
      nextSteps: const [
        '신분증·가족/혼인관계·소득 증빙 준비',
        '임대인 등기부등본/계약서 사본',
        '은행 상담 → 심사 → 승인 → 실행',
      ],
      lastVerified: '2025-09-02',
    )));
    final intakeDuration = DateTime.now().difference(_phaseStartedAt).inMilliseconds;
    Analytics.instance.intakeComplete(_flow.length, intakeDuration, false, 'possible');
    Analytics.instance.rulingShown('possible');
    setState(() {});
    _showSuggestionsAndAds();
  }

  void _showSuggestionsAndAds() {
    _rows.add(_Row.suggestions(const [
      _Suggestion('한도 추정하기', '한도는 소득/보증금/지역 등에 따라 달라집니다. 내부 기준으로 개요를 안내드릴게요.'),
      _Suggestion('서류 체크리스트', '기본 서류는 신분증, 가족·혼인관계, 소득 증빙입니다. 발급처와 순서를 안내해요.'),
      _Suggestion('확인 방법 보기', '세대주/보증금/근저당 확인 방법을 알려드릴게요.'),
    ]));
    _rows.add(_Row.ad(const AdSlot(placement: AdPlacement.resultBottom)));
    setState(() {
      _phase = _Phase.qna;
      _awaitingChoice = false;
    });
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

  void _onSend() {
    final text = _composer.text.trim();
    if (text.isEmpty) return;
    _composer.clear();
    _appendUserText(text);
    Analytics.instance.qnaAsk('free', text.length);
    // Show typing indicator and request completion via Cubit
    _typingRowIndex = _showTyping();
    context.read<ChatCubit>().send(text);
  }

  int _showTyping() {
    _rows.add(_Row.botRich(const TypingIndicator()));
    _typingRowIndex = _rows.length - 1;
    setState(() {});
    return _typingRowIndex!;
  }

  void _replaceTypingWithReply(int typingIndex, BotReply reply) {
    // Convert model citations to UI component citations
    final cites = reply.citations
        .map((c) => Citation(c.docId, c.sectionKey))
        .toList();
    _rows[typingIndex] = _Row.botRich(ChatBubble(
      role: ChatRole.bot,
      content: reply.content,
      citations: cites,
    ));
    setState(() {});
  }

  void _replaceTypingWithError(int typingIndex, String message) {
    _rows[typingIndex] = _Row.botRich(ChatBubble(
      role: ChatRole.bot,
      content: message,
    ));
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;
    return MultiBlocProvider(
      providers: [
        BlocProvider<ChatCubit>(create: (ctx) => ChatCubit(RepositoryProvider.of(ctx))),
        BlocProvider<ConversationCubit>(create: (_) => ConversationCubit()),
      ],
      child: MultiBlocListener(
        listeners: [
          BlocListener<ChatCubit, ChatState>(
            listener: (context, state) {
              state.maybeWhen(
                success: (reply) {
                  if (_typingRowIndex != null) {
                    _replaceTypingWithReply(_typingRowIndex!, reply);
                    Analytics.instance
                        .qnaAnswer(true, reply.lastVerified.isEmpty ? '2025-09-02' : reply.lastVerified);
                    _typingRowIndex = null;
                  }
                },
                error: (msg) {
                  if (_typingRowIndex != null) {
                    _replaceTypingWithError(_typingRowIndex!, msg);
                    _typingRowIndex = null;
                  }
                },
                orElse: () {},
              );
            },
          ),
          BlocListener<ConversationCubit, ConversationState>(
            listener: (context, state) {
              if (state.message != null && state.message!.isNotEmpty) {
                _appendBotText(state.message!);
              }
              if (state.question != null) {
                _appendQuestion(
                  state.question!.qid,
                  state.question!.label,
                  state.question!.choices,
                  index: state.question!.index,
                  total: state.question!.total,
                  isSurvey: state.question!.isSurvey,
                );
              }
              if (state.result != null) {
                _rows.add(_Row.result(ResultCard(
                  status: state.result!.status,
                  tldr: state.result!.tldr,
                  reasons: state.result!.reasons,
                  nextSteps: state.result!.nextSteps,
                  lastVerified: state.result!.lastVerified,
                )));
                setState(() {});
                _showSuggestionsAndAds();
              }
              setState(() => _awaitingChoice = state.awaitingChoice);
            },
          ),
        ],
        child: Scaffold(
          appBar: AppBar(title: const Text('대화형 예비판정')),
          body: SafeArea(
            child: Column(
              children: [
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.all(spacing.x4),
                itemCount: _rows.length,
                itemBuilder: (context, index) {
                  final row = _rows[index];
                  switch (row.type) {
                    case _RowType.botText:
                      return Appear(
                        delay: Duration(milliseconds: 40),
                        child: Padding(
                          padding: EdgeInsets.only(bottom: spacing.x3),
                          child: ChatBubble(role: ChatRole.bot, content: row.text ?? ''),
                        ),
                      );
                    case _RowType.userText:
                      return Appear(
                        delay: Duration(milliseconds: 40),
                        child: Padding(
                          padding: EdgeInsets.only(bottom: spacing.x3),
                          child: ChatBubble(role: ChatRole.user, content: row.text ?? ''),
                        ),
                      );
                    case _RowType.intake:
                      return Appear(
                        delay: Duration(milliseconds: 60),
                        child: Padding(
                          padding: EdgeInsets.only(bottom: spacing.x4),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ProgressInline(current: row.index ?? 1, total: row.total ?? 1, showBar: true),
                              SizedBox(height: spacing.x1),
                              IntakeQuestion(
                                qid: row.qid!,
                                label: row.label!,
                                options: row.choices!,
                                showUnknown: true,
                                onChanged: (v) => _onChoiceSelected(row.qid!, v),
                              ),
                            ],
                          ),
                        ),
                      );
                    case _RowType.ad:
                      return Appear(
                        delay: Duration(milliseconds: 80),
                        child: Padding(
                          padding: EdgeInsets.only(bottom: spacing.x4),
                          child: row.adWidget!,
                        ),
                      );
                    case _RowType.suggestions:
                      return Appear(
                        duration: const Duration(milliseconds: 120),
                        delay: Duration(milliseconds: 50),
                        child: Padding(
                          padding: EdgeInsets.only(bottom: spacing.x3),
                          child: Wrap(
                            spacing: spacing.x2,
                            runSpacing: spacing.x2,
                            children: [
                              for (final s in row.suggestions!)
                                ActionChip(
                                  avatar: const Icon(Icons.tips_and_updates, size: 18),
                                  label: Text(s.label),
                                  onPressed: () {
                                    _appendUserText(s.label);
                                    _rows.add(_Row.botRich(ChatBubble(
                                      role: ChatRole.bot,
                                      content: s.botReply,
                                    )));
                                    Analytics.instance.nextStepClick(s.label);
                                    setState(() {});
                                  },
                                ),
                            ],
                          ),
                        ),
                      );
                    case _RowType.result:
                      return Appear(
                        child: Padding(
                          padding: EdgeInsets.only(bottom: spacing.x4),
                          child: row.resultCard!,
                        ),
                      );
                    case _RowType.botRich:
                      return Appear(
                        delay: Duration(milliseconds: 50),
                        duration: const Duration(milliseconds: 120),
                        child: Padding(
                          padding: EdgeInsets.only(bottom: spacing.x3),
                          child: row.richWidget!,
                        ),
                      );
                  }
                },
              ),
            ),
            _Composer(
              controller: _composer,
              onSend: _onSend,
              enabled: !_awaitingChoice,
            ),
          ],
        ),
      ),
    ),
      ),
    );
  }

  // Question flow (full v1 per INTAKE_FLOW.md)
  static final List<_Question> _flow = [
    _Question(
      qid: 'A1',
      label: '현재 무주택이며 세대주이신가요?',
      choices: const [
        Choice(value: 'owner', text: '무주택·세대주'),
        Choice(value: 'member', text: '무주택·세대원'),
        Choice(value: 'onehome', text: '1주택'),
      ],
    ),
    _Question(
      qid: 'A2',
      label: '혼인/부양 상태를 선택해 주세요.',
      choices: const [
        Choice(value: 'single', text: '미혼'),
        Choice(value: 'newly', text: '신혼(혼인 7년 이내)'),
        Choice(value: 'children', text: '자녀 있음'),
      ],
    ),
    _Question(
      qid: 'A3',
      label: '소득 형태를 선택해 주세요.',
      choices: const [
        Choice(value: 'work', text: '근로'),
        Choice(value: 'biz', text: '사업'),
        Choice(value: 'etc', text: '기타'),
      ],
    ),
    _Question(
      qid: 'A4',
      label: '연간 소득 구간을 선택해 주세요.',
      choices: const [
        Choice(value: 'inc1', text: '내부 구간 1'),
        Choice(value: 'inc2', text: '내부 구간 2'),
        Choice(value: 'inc3', text: '내부 구간 3'),
        Choice(value: 'inc4', text: '내부 구간 4'),
      ],
    ),
    _Question(
      qid: 'A5',
      label: '현재 재직/사업 기간은 얼마나 되나요?',
      choices: const [
        Choice(value: 'm0_6', text: '0~6개월'),
        Choice(value: 'm7_12', text: '7~12개월'),
        Choice(value: 'm13_24', text: '13~24개월'),
        Choice(value: 'm24p', text: '24개월 이상'),
      ],
    ),
    _Question(
      qid: 'A6',
      label: '보유 중인 대출/보증이 있나요?',
      choices: const [
        Choice(value: 'jeonse', text: '전세보증'),
        Choice(value: 'mtg', text: '주담대'),
        Choice(value: 'credit', text: '신용'),
        Choice(value: 'none', text: '없음'),
      ],
    ),
    _Question(
      qid: 'A7',
      label: '최근 연체·회생·파산·면책 이력이 있나요?',
      choices: const [
        Choice(value: 'credit_ok', text: '문제 없음'),
        Choice(value: 'credit_recent', text: '최근 연체'),
        Choice(value: 'credit_severe', text: '장기연체/회생/파산/면책'),
      ],
    ),
    _Question(
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
    _Question(
      qid: 'P2',
      label: '전용면적 범위를 선택해 주세요.',
      choices: const [
        Choice(value: 'fa_le40', text: '≤ 40㎡'),
        Choice(value: 'fa_41_60', text: '41–60㎡'),
        Choice(value: 'fa_61_85', text: '61–85㎡'),
        Choice(value: 'fa_gt85', text: '85㎡ 초과'),
      ],
    ),
    _Question(
      qid: 'P3',
      label: '지역을 선택해 주세요.',
      choices: const [
        Choice(value: 'metro', text: '수도권'),
        Choice(value: 'metrocity', text: '광역시'),
        Choice(value: 'other', text: '기타'),
      ],
    ),
    _Question(
      qid: 'P4',
      label: '전세보증금(또는 보증금+월세)을 알려주세요.',
      choices: const [
        Choice(value: 'dep_le1', text: '1억 이하'),
        Choice(value: 'dep_1_2', text: '1~2억'),
        Choice(value: 'dep_2_3', text: '2~3억'),
        Choice(value: 'dep_gt3', text: '3억 이상'),
      ],
    ),
    _Question(
      qid: 'P5',
      label: '계약 상태를 알려주세요.',
      choices: const [
        Choice(value: 'pre', text: '계약 전'),
        Choice(value: 'precontract', text: '가계약'),
        Choice(value: 'contract', text: '본계약'),
      ],
    ),
    _Question(
      qid: 'P6',
      label: '입주 예정 시점을 알려주세요.',
      choices: const [
        Choice(value: 'w1', text: '1주 내'),
        Choice(value: 'w2_4', text: '2~4주'),
        Choice(value: 'm1_3', text: '1~3개월'),
        Choice(value: 'm3p', text: '3개월+'),
      ],
    ),
    _Question(
      qid: 'P7',
      label: '등기상 근저당이 있나요?',
      choices: const [
        Choice(value: 'encumbrance_yes', text: '있음'),
        Choice(value: 'encumbrance_no', text: '없음'),
      ],
    ),
    _Question(
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

  static _Question _q(String id) => _flow.firstWhere((e) => e.qid == id);

  static final List<_Question> _surveyFlow = [
    _Question(
      qid: 'QS1',
      label: '언제까지 준비가 필요하신가요?',
      choices: const [
        Choice(value: 'soon', text: '2주 이내'),
        Choice(value: 'month1', text: '1개월 이내'),
        Choice(value: 'flex', text: '유연함'),
      ],
    ),
    _Question(
      qid: 'QS2',
      label: '어떤 정보가 가장 궁금하신가요?',
      choices: const [
        Choice(value: 'elig', text: '자격'),
        Choice(value: 'limit', text: '한도'),
        Choice(value: 'docs', text: '서류/절차'),
      ],
    ),
    _Question(
      qid: 'QS3',
      label: '주 관심 지역을 선택해 주세요.',
      choices: const [
        Choice(value: 'metro', text: '수도권'),
        Choice(value: 'metrocity', text: '광역시'),
        Choice(value: 'other', text: '기타'),
      ],
    ),
  ];

  bool _isSurveyQid(String qid) => qid.startsWith('QS');
}

class _Composer extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;
  final bool enabled;
  const _Composer({required this.controller, required this.onSend, required this.enabled});

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;
    final cs = Theme.of(context).colorScheme;
    final radius = BorderRadius.circular(22);
    return Container(
      padding: EdgeInsets.fromLTRB(spacing.x3, spacing.x2, spacing.x3, spacing.x2),
      decoration: BoxDecoration(
        color: cs.surface,
        border: Border(top: BorderSide(color: cs.outlineVariant)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Material(
              elevation: enabled ? 2 : 0,
              color: cs.surface,
              borderRadius: radius,
              child: TextField(
                controller: controller,
                enabled: enabled,
                decoration: InputDecoration(
                  hintText: enabled ? '질문을 입력하세요…' : '선택지에서 답변해 주세요',
                  isDense: true,
                  filled: true,
                  fillColor: cs.surfaceVariant,
                  contentPadding: EdgeInsets.symmetric(horizontal: spacing.x3, vertical: spacing.x2),
                  border: OutlineInputBorder(borderRadius: radius, borderSide: BorderSide.none),
                ),
                onSubmitted: (_) => onSend(),
              ),
            ),
          ),
          SizedBox(width: spacing.x2),
          AnimatedScale(
            scale: enabled ? 1.0 : 0.96,
            duration: const Duration(milliseconds: 150),
            curve: Curves.easeOut,
            child: Material(
              color: enabled ? cs.primary : cs.surfaceVariant,
              elevation: enabled ? 3 : 0,
              shape: const CircleBorder(),
              child: IconButton(
                onPressed: enabled ? onSend : null,
                icon: Icon(Icons.send, color: enabled ? cs.onPrimary : cs.onSurfaceVariant),
                tooltip: '보내기',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Question {
  final String qid;
  final String label;
  final List<Choice> choices;
  const _Question({required this.qid, required this.label, required this.choices});
}

enum _RowType { botText, userText, intake, result, botRich, ad, suggestions }

class _Row {
  final _RowType type;
  final String? text;
  final String? qid;
  final String? label;
  final List<Choice>? choices;
  final ResultCard? resultCard;
  final Widget? richWidget;
  final Widget? adWidget;
  final List<_Suggestion>? suggestions;
  final int? index;
  final int? total;
  final bool? isSurvey;

  _Row.bot(this.text)
      : type = _RowType.botText,
        qid = null,
        label = null,
        choices = null,
        resultCard = null,
        richWidget = null,
        adWidget = null,
        suggestions = null;

  _Row.user(this.text)
      : type = _RowType.userText,
        qid = null,
        label = null,
        choices = null,
        resultCard = null,
        richWidget = null,
        adWidget = null,
        suggestions = null,
        index = null,
        total = null,
        isSurvey = null;

  _Row.intake({required this.qid, required this.label, required this.choices, this.index, this.total, this.isSurvey})
      : type = _RowType.intake,
        text = null,
        resultCard = null,
        richWidget = null,
        adWidget = null,
        suggestions = null;

  _Row.result(this.resultCard)
      : type = _RowType.result,
        text = null,
        qid = null,
        label = null,
        choices = null,
        richWidget = null,
        adWidget = null,
        suggestions = null,
        index = null,
        total = null,
        isSurvey = null;

  _Row.botRich(this.richWidget)
      : type = _RowType.botRich,
        text = null,
        qid = null,
        label = null,
        choices = null,
        resultCard = null,
        adWidget = null,
        suggestions = null,
        index = null,
        total = null,
        isSurvey = null;

  _Row.ad(this.adWidget)
      : type = _RowType.ad,
        text = null,
        qid = null,
        label = null,
        choices = null,
        resultCard = null,
        richWidget = null,
        suggestions = null,
        index = null,
        total = null,
        isSurvey = null;

  _Row.suggestions(this.suggestions)
      : type = _RowType.suggestions,
        text = null,
        qid = null,
        label = null,
        choices = null,
        resultCard = null,
        richWidget = null,
        adWidget = null,
        index = null,
        total = null,
        isSurvey = null;
}

class _Suggestion {
  final String label;
  final String botReply;
  const _Suggestion(this.label, this.botReply);
}

enum _Phase { survey, intake, qna }
