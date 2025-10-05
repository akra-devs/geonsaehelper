import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../common/analytics/analytics.dart';
import '../../../ui/components/ad_slot.dart';
import '../../../ui/components/chat_bubble.dart';
import '../../../ui/components/chat_composer.dart';
import '../../../ui/components/conversation_item_widget.dart';
import '../../../ui/components/result_card.dart';
import '../../../ui/components/program_help_sheet.dart';
import '../../../ui/components/suggestions_panel.dart';
import '../../../ui/components/typing_indicator.dart';
import '../../../ui/theme/app_theme.dart';
import '../bloc/chat_bloc.dart';
import '../bloc/chat_event.dart';
import '../bloc/conversation_bloc.dart';
import '../bloc/conversation_event.dart';
import '../data/chat_models.dart';
import '../data/chat_repository.dart';
import '../domain/product_types.dart';
import 'conversation_item.dart';
import '../domain/models.dart' as domain;
import '../domain/suggestion.dart';
import '../domain/constants.dart';

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
  domain.ConversationResult? _lastResult; // for Q&A citations fallback

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
      ctx.read<ConversationBloc>().add(
        ConversationEvent.choiceSelected(qid, value),
      );
    }
  }

  // Flow evaluation now fully handled by ConversationBloc

  void _showSuggestionsAndAds() {
    // Convert domain SuggestionAction to UI SuggestionItem
    final suggestionItems =
        SuggestionActions.list
            .map((action) => SuggestionItem(action.label, action.botReply))
            .toList();

    _items.add(ConversationItem.suggestions(suggestionItems));
    _items.add(
      ConversationItem.advertisement(
        const AdSlot(placement: AdPlacement.resultBottom),
      ),
    );
    _scheduleScroll();
  }

  // Derive up to 3 citations from the latest ruling reasons
  List<Citation> _deriveCitationsFromResult(domain.ConversationResult? result) {
    if (result == null) return const [];
    // Priority: unmet > unknown > warning > met
    int prio(domain.ReasonKind k) {
      switch (k) {
        case domain.ReasonKind.unmet:
          return 0;
        case domain.ReasonKind.unknown:
          return 1;
        case domain.ReasonKind.warning:
          return 2;
        case domain.ReasonKind.met:
          return 3;
      }
    }

    final pairs = <String>{};
    final collected = <Citation>[];
    final sorted = List<domain.Reason>.from(result.reasons)
      ..sort((a, b) => prio(a.kind).compareTo(prio(b.kind)));
    for (final r in sorted) {
      final srcs = r.sources ?? const [];
      for (final s in srcs) {
        final key = '${s.docId}#${s.sectionKey}';
        if (pairs.add(key)) {
          collected.add(Citation(s.docId, s.sectionKey));
          if (collected.length >= 3) return collected;
        }
      }
      if (collected.length >= 3) break;
    }
    return collected;
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
    // Show typing indicator and request completion via Bloc
    _typingItemIndex = _showTyping();
    ctx.read<ChatBloc>().add(ChatEvent.messageSent(text));
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
    var cites =
        reply.citations.map((c) => Citation(c.docId, c.sectionKey)).toList();
    // Fallback: if server provided no citations, derive from last ruling
    if (cites.isEmpty) {
      final derived = _deriveCitationsFromResult(_lastResult);
      if (derived.isNotEmpty) cites = derived;
    }
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
        BlocProvider<ChatBloc>(
          create: (ctx) => ChatBloc(RepositoryProvider.of<ChatRepository>(ctx)),
        ),
        BlocProvider<ConversationBloc>(create: (_) => ConversationBloc()),
      ],
      child: Builder(
        builder: (innerCtx) {
          if (!_hasStarted) {
            _hasStarted = true;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              innerCtx.read<ConversationBloc>().add(
                const ConversationEvent.started(),
              );
            });
          }
          return MultiBlocListener(
            listeners: [
              BlocListener<ChatBloc, ChatState>(
                listener: (context, state) {
                  state.maybeWhen(
                    success: (reply, selectedProductType) {
                      if (_typingItemIndex != null) {
                        _replaceTypingWithReply(_typingItemIndex!, reply);
                        Analytics.instance.qnaAnswer(
                          true,
                          reply.lastVerified.isEmpty
                              ? rulesLastVerifiedYmd
                              : reply.lastVerified,
                        );
                        _typingItemIndex = null;
                      }
                    },
                    error: (msg, selectedProductType) {
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
                  // Handle reset trigger
                  if (state.resetTriggered) {
                    _items.clear();
                    setState(() {});
                    return;
                  }

                  if (state.userEcho != null && state.userEcho!.isNotEmpty) {
                    _appendUserText(state.userEcho!);
                  }
                  if (state.message != null && state.message!.isNotEmpty) {
                    _appendBotText(state.message!);
                  }
                  if (state.suggestionReply != null &&
                      state.suggestionReply!.isNotEmpty) {
                    final cites = _deriveCitationsFromResult(state.result);
                    _items.add(
                      ConversationItem.botWidget(
                        ChatBubble(
                          role: ChatRole.bot,
                          content: state.suggestionReply!,
                          citations: cites,
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
                    _lastResult = state.result; // keep for Q&A citation fallback
                    _items.add(
                      ConversationItem.result(
                        ResultCard(
                          status: state.result!.status,
                          tldr: state.result!.tldr,
                          reasons: state.result!.reasons,
                          nextSteps: state.result!.nextSteps,
                          lastVerified: state.result!.lastVerified,
                          programMatches: state.result!.programMatches,
                          onProgramHelp: (pid) {
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              builder: (ctx) => ProgramHelpSheet(
                                programId: pid,
                                lastVerified: state.result!.lastVerified,
                              ),
                            );
                          },
                        ),
                      ),
                    );
                    setState(() {});
                    // Show product selector after result if flag is set
                    if (state.showProductSelector) {
                      _items.add(ConversationItem.productTypeSelector());
                      setState(() {});
                    }
                    _showSuggestionsAndAds();
                  }
                  _scheduleScroll();
                },
              ),
            ],
            child: Scaffold(
              appBar: AppBar(title: const Text('대화형 예비판정')),
              body: SafeArea(
                child: _CenteredContent(
                  child: Column(
                    children: [
                      Expanded(
                        child: ListView.builder(
                          controller: _scroll,
                          padding: EdgeInsets.only(
                            top: spacing.x4,
                            bottom: spacing.x4,
                          ),
                          itemCount: _items.length,
                          itemBuilder: (context, index) {
                            final item = _items[index];
                            return ConversationItemWidget(
                              item: item,
                              onChoiceSelected: (qid, value) {
                                // Handle choice selection with Bloc logic
                                _handleChoiceSelection(context, qid, value);
                              },
                              onSuggestionTap: (s) {
                                // Find suggestion ID by label
                                final suggestion = SuggestionActions.list
                                    .firstWhere(
                                      (action) => action.label == s.label,
                                      orElse:
                                          () =>
                                              SuggestionActions.limitEstimation,
                                    );
                                context.read<ConversationBloc>().add(
                                  ConversationEvent.suggestionSelected(
                                    suggestion.id,
                                  ),
                                );
                              },
                              onProductTypeSelected: (productTypeId) {
                                context.read<ChatBloc>().add(
                                  ChatEvent.productTypeSelected(productTypeId),
                                );
                              },
                            );
                          },
                        ),
                      ),
                      BlocBuilder<ChatBloc, ChatState>(
                        builder: (context, chatState) {
                          final selectedProductType = chatState.mapOrNull(
                            idle: (s) => s.selectedProductType,
                            loading: (s) => s.selectedProductType,
                            success: (s) => s.selectedProductType,
                            error: (s) => s.selectedProductType,
                          );
                          final selectedProductLabel = selectedProductType != null
                              ? ProductTypes.findById(selectedProductType)?.label
                              : null;

                          return BlocBuilder<ConversationBloc, ConversationState>(
                            builder: (context, conversationState) {
                              return ChatComposer(
                                controller: _composer,
                                onSend: () => _onSend(context),
                                enabled: !conversationState.awaitingChoice,
                                selectedProductType: selectedProductType,
                                selectedProductLabel: selectedProductLabel,
                              );
                            },
                          );
                        },
                      ),
                    ],
                  ),
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
