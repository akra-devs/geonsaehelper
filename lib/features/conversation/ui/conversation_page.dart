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
import '../../conversation/bloc/conversation_cubit.dart';
import '../../conversation/data/chat_repository.dart';
import '../../conversation/data/chat_models.dart';

class ConversationPage extends StatefulWidget {
  const ConversationPage({super.key});

  @override
  State<ConversationPage> createState() => _ConversationPageState();
}

class _ConversationPageState extends State<ConversationPage> {
  final List<_Row> _rows = [];
  final TextEditingController _composer = TextEditingController();
  bool _awaitingChoice = true;
  final ScrollController _scroll = ScrollController();

  static const _unknown = '__unknown__';

  int? _typingRowIndex;
  bool _didStart = false;

  @override
  void initState() {
    super.initState();
    // Kick off with greeting + first question
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _appendBotText('간단 조사를 통해 맞춤 안내를 준비할게요. 이후 예비판정을 진행합니다.');
    });
  }

  @override
  void dispose() {
    _composer.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _appendBotText(String text) {
    setState(() => _rows.add(_Row.bot(text)));
    _scheduleScroll();
  }

  void _appendUserText(String text) {
    setState(() => _rows.add(_Row.user(text)));
    _scheduleScroll();
  }

  void _appendQuestion(
    String qid,
    String label,
    List<Choice> choices, {
    int? index,
    int? total,
    bool isSurvey = false,
  }) {
    setState(() {
      _rows.add(_Row.intake(
        qid: qid,
        label: label,
        choices: choices,
        index: index,
        total: total,
        isSurvey: isSurvey,
      ));
      _awaitingChoice = true;
    });
    _scheduleScroll();
  }

  void _onChoiceSelected(BuildContext ctx, String qid, String? value) {
    if (value == null) return;
    String label;
    if (value == _unknown) {
      label = '모름';
    } else {
      final q = ctx.read<ConversationCubit>().state.question;
      if (q == null) {
        label = value;
      } else {
        final match = q.choices.where((c) => c.value == value);
        label = match.isNotEmpty ? match.first.text : value;
      }
    }
    _appendUserText(label);
    setState(() => _awaitingChoice = false);
    ctx.read<ConversationCubit>().answer(qid, value);
  }

  // Flow evaluation now fully handled by ConversationCubit

  void _showSuggestionsAndAds() {
    _rows.add(_Row.suggestions(const [
      _Suggestion('한도 추정하기', '한도는 소득/보증금/지역 등에 따라 달라집니다. 내부 기준으로 개요를 안내드릴게요.'),
      _Suggestion('서류 체크리스트', '기본 서류는 신분증, 가족·혼인관계, 소득 증빙입니다. 발급처와 순서를 안내해요.'),
      _Suggestion('확인 방법 보기', '세대주/보증금/근저당 확인 방법을 알려드릴게요.'),
    ]));
    _rows.add(_Row.ad(const AdSlot(placement: AdPlacement.resultBottom)));
    setState(() {
      _awaitingChoice = false;
    });
    _scheduleScroll();
  }

  void _scheduleScroll() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      // If no scroll controller yet or no clients, ignore.
      final primary = PrimaryScrollController.maybeOf(context);
      final controller = _scroll.hasClients ? _scroll : primary;
      if (controller == null || !controller.hasClients) return;
      final offset = controller.position.maxScrollExtent;
      controller.animateTo(
        offset,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  void _onSend(BuildContext ctx) {
    final text = _composer.text.trim();
    if (text.isEmpty) return;
    _composer.clear();
    _appendUserText(text);
    Analytics.instance.qnaAsk('free', text.length);
    // Show typing indicator and request completion via Cubit
    _typingRowIndex = _showTyping();
    ctx.read<ChatCubit>().send(text);
  }

  int _showTyping() {
    _rows.add(_Row.botRich(const TypingIndicator()));
    _typingRowIndex = _rows.length - 1;
    setState(() {});
    _scheduleScroll();
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
    _scheduleScroll();
  }

  void _replaceTypingWithError(int typingIndex, String message) {
    _rows[typingIndex] = _Row.botRich(ChatBubble(
      role: ChatRole.bot,
      content: message,
    ));
    setState(() {});
    _scheduleScroll();
  }

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;
    return MultiBlocProvider(
      providers: [
        BlocProvider<ChatCubit>(create: (ctx) => ChatCubit(RepositoryProvider.of<ChatRepository>(ctx))),
        BlocProvider<ConversationCubit>(create: (_) => ConversationCubit()),
      ],
      child: Builder(
        builder: (innerCtx) {
          if (!_didStart) {
            _didStart = true;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              innerCtx.read<ConversationCubit>().start();
            });
          }
          return MultiBlocListener(
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
              _scheduleScroll();
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
                controller: _scroll,
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
                                onChanged: (v) => _onChoiceSelected(context, row.qid!, v),
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
              onSend: () => _onSend(context),
              enabled: !_awaitingChoice,
            ),
          ],
        ),
      ),
    ),
      );
        },
      ),
    );
  }

  // Question flow is provided by ConversationCubit.
  // (UI formerly defined _flow here; removed for single source of truth.)
  // (flow definitions removed)

  // Flows and survey handling are provided by ConversationCubit.
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

// UI no longer declares a _Question; ConversationCubit provides question data.

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
        suggestions = null,
        index = null,
        total = null,
        isSurvey = null;

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

// Phase state is tracked in ConversationCubit; no local enum needed here.
