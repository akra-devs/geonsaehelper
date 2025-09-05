import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../common/analytics/analytics.dart';
import '../../../ui/components/ad_slot.dart';
import '../../../ui/components/chat_bubble.dart';
import '../../../ui/components/chat_composer.dart';
import '../../../ui/components/conversation_item_widget.dart';
import '../../../ui/components/result_card.dart';
import '../../../ui/components/suggestions_panel.dart';
import '../../../ui/components/typing_indicator.dart';
import '../../../ui/theme/app_theme.dart';
import '../bloc/chat_cubit.dart';
import '../bloc/conversation_bloc.dart';
import '../bloc/conversation_event.dart';
import '../data/chat_models.dart';
import '../data/chat_repository.dart';
import 'conversation_item.dart';
import '../domain/models.dart' as domain;

class ConversationPage extends StatefulWidget {
  const ConversationPage({super.key});

  @override
  State<ConversationPage> createState() => _ConversationPageState();
}

class _ConversationPageState extends State<ConversationPage> {
  final List<ConversationItem> _items = [];
  final TextEditingController _composer = TextEditingController();
  final ScrollController _scroll = ScrollController();
  int? _typingItemIndex;
  bool _hasStarted = false;

  // No local constants; business logic lives in Cubit.

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
    setState(() => _items.add(ConversationItem.botMessage(text)));
    _scheduleScroll();
  }

  void _appendUserText(String text) {
    setState(() => _items.add(ConversationItem.userMessage(text)));
    _scheduleScroll();
  }

  void _appendQuestion(
    String qid,
    String label,
    List<domain.Choice> choices, {
    int? index,
    int? total,
    bool isSurvey = false,
  }) {
    setState(() {
      _items.add(
        ConversationItem.intakeQuestion(
          questionId: qid,
          label: label,
          choices: choices,
          index: index,
          total: total,
          isSurvey: isSurvey,
        ),
      );
      // Choice state managed by ConversationCubit
    });
    _scheduleScroll();
  }

  void _handleChoiceSelection(BuildContext ctx, String qid, String? value) {
    // Delegate to Bloc for label resolution and state emission
    if (value != null) {
      ctx.read<ConversationBloc>().add(ConversationEvent.choiceSelected(qid, value));
    }
  }

  // Flow evaluation now fully handled by ConversationCubit

  void _showSuggestionsAndAds() {
    _items.add(
      ConversationItem.suggestions(const [
        SuggestionItem(
          '한도 추정하기',
          '한도는 소득/보증금/지역 등에 따라 달라집니다. 내부 기준으로 개요를 안내드릴게요.',
        ),
        SuggestionItem(
          '서류 체크리스트',
          '기본 서류는 신분증, 가족·혼인관계, 소득 증빙입니다. 발급처와 순서를 안내해요.',
        ),
        SuggestionItem('확인 방법 보기', '세대주/보증금/근저당 확인 방법을 알려드릴게요.'),
      ]),
    );
    _items.add(ConversationItem.advertisement(const AdSlot(placement: AdPlacement.resultBottom)));
    // UI state managed automatically by BLoC listener
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
    _typingItemIndex = _showTyping();
    ctx.read<ChatCubit>().send(text);
  }

  int _showTyping() {
    _items.add(ConversationItem.botWidget(const TypingIndicator()));
    _typingItemIndex = _items.length - 1;
    setState(() {});
    _scheduleScroll();
    return _typingItemIndex!;
  }

  void _replaceTypingWithReply(int typingIndex, BotReply reply) {
    // Convert model citations to UI component citations
    final cites =
        reply.citations.map((c) => Citation(c.docId, c.sectionKey)).toList();
    _items[typingIndex] = ConversationItem.botWidget(
      ChatBubble(role: ChatRole.bot, content: reply.content, citations: cites),
    );
    setState(() {});
    _scheduleScroll();
  }

  void _replaceTypingWithError(int typingIndex, String message) {
    _items[typingIndex] = ConversationItem.botWidget(
      ChatBubble(role: ChatRole.bot, content: message),
    );
    setState(() {});
    _scheduleScroll();
  }

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;
    return MultiBlocProvider(
      providers: [
        BlocProvider<ChatCubit>(
          create:
              (ctx) => ChatCubit(RepositoryProvider.of<ChatRepository>(ctx)),
        ),
        BlocProvider<ConversationBloc>(create: (_) => ConversationBloc()),
      ],
      child: Builder(
        builder: (innerCtx) {
          if (!_hasStarted) {
            _hasStarted = true;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              innerCtx.read<ConversationBloc>().add(const ConversationEvent.started());
            });
          }
          return MultiBlocListener(
            listeners: [
              BlocListener<ChatCubit, ChatState>(
                listener: (context, state) {
                  state.maybeWhen(
                    success: (reply) {
                      if (_typingItemIndex != null) {
                        _replaceTypingWithReply(_typingItemIndex!, reply);
                        Analytics.instance.qnaAnswer(
                          true,
                          reply.lastVerified.isEmpty
                              ? '2025-09-02'
                              : reply.lastVerified,
                        );
                        _typingItemIndex = null;
                      }
                    },
                    error: (msg) {
                      if (_typingItemIndex != null) {
                        _replaceTypingWithError(_typingItemIndex!, msg);
                        _typingItemIndex = null;
                      }
                    },
                    orElse: () {},
                  );
                },
              ),
              BlocListener<ConversationBloc, ConversationState>(
                listener: (context, state) {
                  if (state.userEcho != null && state.userEcho!.isNotEmpty) {
                    _appendUserText(state.userEcho!);
                  }
                  if (state.message != null && state.message!.isNotEmpty) {
                    _appendBotText(state.message!);
                  }
                  if (state.suggestionReply != null && state.suggestionReply!.isNotEmpty) {
                    _items.add(
                      ConversationItem.botWidget(
                        ChatBubble(
                          role: ChatRole.bot,
                          content: state.suggestionReply!,
                        ),
                      ),
                    );
                    setState(() {});
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
                    _items.add(
                      ConversationItem.result(
                        ResultCard(
                          status: state.result!.status,
                          tldr: state.result!.tldr,
                          reasons: state.result!.reasons,
                          nextSteps: state.result!.nextSteps,
                          lastVerified: state.result!.lastVerified,
                        ),
                      ),
                    );
                    setState(() {});
                    _showSuggestionsAndAds();
                  }
                  // Choice state managed by ConversationCubit
                  _scheduleScroll();
                },
              ),
            ],
            child: Scaffold(
              appBar: AppBar(title: const Text('대화형 예비판정')),
              body: SafeArea(
                child: _CenteredContent(child: Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        controller: _scroll,
                        padding: EdgeInsets.only(top: spacing.x4, bottom: spacing.x4),
                        itemCount: _items.length,
                        itemBuilder: (context, index) {
                          final item = _items[index];
                          return ConversationItemWidget(
                            item: item,
                            onChoiceSelected: (qid, value) {
                              // Handle choice selection with BLoC logic in parent
                              _handleChoiceSelection(context, qid, value);
                            },
                            onSuggestionTap: (s) {
                              context.read<ConversationBloc>().add(ConversationEvent.suggestionSelected(s));
                            },
                          );
                        },
                      ),
                    ),
                    BlocBuilder<ConversationBloc, ConversationState>(
                      builder: (context, state) {
                        return ChatComposer(
                          controller: _composer,
                          onSend: () => _onSend(context),
                          enabled: !state.awaitingChoice,
                        );
                      },
                    ),
                  ],
                )),
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

// _Composer extracted to ui/components/chat_composer.dart as ChatComposer

// UI no longer declares a _Question; ConversationCubit provides question data.



class _CenteredContent extends StatelessWidget {
  final Widget child;
  const _CenteredContent({required this.child});
  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 820),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: spacing.x4),
          child: child,
        ),
      ),
    );
  }
}
