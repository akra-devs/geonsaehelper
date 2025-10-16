import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../ui/components/ad_slot.dart';
import '../../../ui/components/conversation_item_widget.dart';
import '../../../ui/components/result_card.dart';
import '../../../ui/components/program_help_sheet.dart';
import '../../../ui/components/suggestions_panel.dart';
import '../../../ui/theme/app_theme.dart';
import '../bloc/conversation_bloc.dart';
import '../bloc/conversation_event.dart';
import 'conversation_item.dart';
import '../domain/models.dart' as domain;
import '../domain/suggestion.dart';

class ConversationPage extends StatefulWidget {
  const ConversationPage({super.key});

  @override
  State<ConversationPage> createState() => _ConversationPageState();
}

class _ConversationPageState extends State<ConversationPage> {
  final List<ConversationItem> _items = [];
  final ScrollController _scroll = ScrollController();
  bool _hasStarted = false;

  @override
  void initState() {
    super.initState();
    // Kick off with greeting + first question
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _appendBotText('환영합니다! 예비판정에 필요한 핵심 정보만 순서대로 확인해 볼게요.');
      Future.delayed(const Duration(milliseconds: 400), () {
        if (!mounted) return;
        _appendBotText('총 12문 내외이며 예상 소요 시간은 약 2분입니다.');
      });
    });
  }

  @override
  void dispose() {
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

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;
    if (!_hasStarted) {
      _hasStarted = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<ConversationBloc>().add(
          const ConversationEvent.started(),
        );
      });
    }
    return BlocListener<ConversationBloc, ConversationState>(
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
                    _appendBotText(state.suggestionReply!);
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
                    _showSuggestionsAndAds();
                  }
                  _scheduleScroll();
                },
                child: Scaffold(
                  appBar: AppBar(title: const Text('대화형 예비판정')),
                  body: SafeArea(
                    child: _CenteredContent(
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
                          );
                        },
                      ),
                    ),
                  ),
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
