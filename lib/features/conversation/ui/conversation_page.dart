import 'package:flutter/material.dart';
import '../../../ui/components/chat_bubble.dart';
import '../../../ui/components/intake_question.dart';
import '../../../ui/components/result_card.dart';
import '../../../ui/theme/app_theme.dart';

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

  static const _unknown = '__unknown__';

  @override
  void initState() {
    super.initState();
    // Kick off with greeting + first question
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _appendBotText('예비자격 빠른 판정을 진행합니다. 각 질문에 답해주세요. 모르면 “모름”을 선택하세요.');
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
    final q = _flow[_step];
    _appendQuestion(q.qid, q.label, q.choices);
  }

  void _onChoiceSelected(String qid, String? value) {
    if (value == null) return;
    final q = _flow.firstWhere((e) => e.qid == qid);
    final label = _labelFor(q, value);
    _appendUserText(label);
    _answers[qid] = value;
    setState(() => _awaitingChoice = false);

    if (_step < _flow.length - 1) {
      _step += 1;
      _askCurrent();
    } else {
      _evaluateAndShow();
    }
  }

  String _labelFor(_Question q, String value) {
    if (value == _unknown) return '모름';
    return q.choices.firstWhere((c) => c.value == value).text;
  }

  void _evaluateAndShow() {
    // Minimal evaluation logic per RULES_HUG_v1.md
    final unknowns = _answers.entries.where((e) => e.value == _unknown).map((e) => e.key).toList();
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
      setState(() {});
      _appendBotText('궁금한 점을 이어서 질문해 주세요. 내부 문서 기준으로 요약해 드립니다.');
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
      setState(() {});
      _appendBotText('다른 조건이나 기관 가능성을 확인해 보시겠어요?');
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
    setState(() {});
    _appendBotText('한도/서류/절차 등 무엇이든 질문해 주세요.');
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
    // Stubbed bot answer following RAG policy tone
    _rows.add(_Row.botRich(const ChatBubble(
      role: ChatRole.bot,
      content: 'TL;DR: 서류는 신분증, 가족·혼인관계, 소득 증빙이 기본입니다. 다음 단계에서 발급처/순서를 안내해 드립니다.',
      citations: [Citation('HUG_internal_policy.md', 'A.1')],
    )));
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;
    return Scaffold(
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
                      return Padding(
                        padding: EdgeInsets.only(bottom: spacing.x3),
                        child: ChatBubble(role: ChatRole.bot, content: row.text ?? ''),
                      );
                    case _RowType.userText:
                      return Padding(
                        padding: EdgeInsets.only(bottom: spacing.x3),
                        child: ChatBubble(role: ChatRole.user, content: row.text ?? ''),
                      );
                    case _RowType.intake:
                      final idx = _flow.indexWhere((e) => e.qid == row.qid);
                      final total = _flow.length;
                      return Padding(
                        padding: EdgeInsets.only(bottom: spacing.x4),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('진행 ${idx + 1}/$total', style: Theme.of(context).textTheme.labelMedium),
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
                      );
                    case _RowType.result:
                      return Padding(
                        padding: EdgeInsets.only(bottom: spacing.x4),
                        child: row.resultCard!,
                      );
                    case _RowType.botRich:
                      return Padding(
                        padding: EdgeInsets.only(bottom: spacing.x3),
                        child: row.richWidget!,
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
}

class _Composer extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;
  final bool enabled;
  const _Composer({required this.controller, required this.onSend, required this.enabled});

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;
    return Container(
      padding: EdgeInsets.fromLTRB(spacing.x3, spacing.x2, spacing.x3, spacing.x2),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(top: BorderSide(color: Theme.of(context).colorScheme.outlineVariant)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              enabled: enabled,
              decoration: InputDecoration(
                hintText: enabled ? '질문을 입력하세요…' : '선택지에서 답변해 주세요',
                isDense: true,
                border: const OutlineInputBorder(),
              ),
              onSubmitted: (_) => onSend(),
            ),
          ),
          SizedBox(width: spacing.x2),
          IconButton(
            onPressed: enabled ? onSend : null,
            icon: const Icon(Icons.send),
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

enum _RowType { botText, userText, intake, result, botRich }

class _Row {
  final _RowType type;
  final String? text;
  final String? qid;
  final String? label;
  final List<Choice>? choices;
  final ResultCard? resultCard;
  final Widget? richWidget;

  _Row.bot(this.text)
      : type = _RowType.botText,
        qid = null,
        label = null,
        choices = null,
        resultCard = null,
        richWidget = null;

  _Row.user(this.text)
      : type = _RowType.userText,
        qid = null,
        label = null,
        choices = null,
        resultCard = null,
        richWidget = null;

  _Row.intake({required this.qid, required this.label, required this.choices})
      : type = _RowType.intake,
        text = null,
        resultCard = null,
        richWidget = null;

  _Row.result(this.resultCard)
      : type = _RowType.result,
        text = null,
        qid = null,
        label = null,
        choices = null,
        richWidget = null;

  _Row.botRich(this.richWidget)
      : type = _RowType.botRich,
        text = null,
        qid = null,
        label = null,
        choices = null,
        resultCard = null;
}
