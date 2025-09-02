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

    // Otherwise, possible with summary reasons
    final reasons = <ReasonItem>[
      const ReasonItem(Icons.check_circle, '무주택·세대주/세대원 확인', '충족'),
      ReasonItem(Icons.check_circle, '소득 형태: ${_labelFor(_flow[1], _answers['A3']!)}', '충족'),
      ReasonItem(Icons.check_circle, '주택 유형: ${_labelFor(_flow[2], _answers['P1']!)}', '충족'),
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
      case 'A3':
        return '소득 형태';
      case 'P1':
        return '주택 유형';
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
                      return Padding(
                        padding: EdgeInsets.only(bottom: spacing.x4),
                        child: IntakeQuestion(
                          qid: row.qid!,
                          label: row.label!,
                          options: row.choices!,
                          showUnknown: true,
                          onChanged: (v) => _onChoiceSelected(row.qid!, v),
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

  // Question flow (subset for demo)
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
      qid: 'A3',
      label: '소득 형태를 선택해 주세요.',
      choices: const [
        Choice(value: 'work', text: '근로'),
        Choice(value: 'biz', text: '사업'),
        Choice(value: 'etc', text: '기타'),
      ],
    ),
    _Question(
      qid: 'P1',
      label: '주택 유형을 선택해 주세요.',
      choices: const [
        Choice(value: 'apt', text: '아파트'),
        Choice(value: 'officetel', text: '오피스텔'),
        Choice(value: 'one_room', text: '원룸'),
        Choice(value: 'etc', text: '기타'),
      ],
    ),
  ];
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

