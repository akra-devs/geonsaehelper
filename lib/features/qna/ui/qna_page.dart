import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../common/analytics/analytics.dart';
import '../../../ui/components/chat_bubble.dart';
import '../../../ui/components/chat_composer.dart';
import '../../../ui/components/product_type_selector.dart';
import '../../../ui/components/typing_indicator.dart';
import '../../../ui/theme/app_theme.dart';
import '../../conversation/bloc/chat_bloc.dart';
import '../../conversation/bloc/chat_event.dart';
import '../../conversation/data/chat_models.dart';
import '../../conversation/data/chat_repository.dart';
import '../../conversation/domain/constants.dart';
import '../../conversation/domain/product_types.dart';
import '../../history/bloc/history_bloc.dart';

/// QnA-only page for AI chat after ruling completion
class QnAPage extends StatefulWidget {
  const QnAPage({super.key});

  @override
  State<QnAPage> createState() => _QnAPageState();
}

class _QnAPageState extends State<QnAPage> {
  final TextEditingController _composer = TextEditingController();
  final ScrollController _scroll = ScrollController();
  final List<_ChatItem> _items = [];
  int? _typingItemIndex;

  @override
  void dispose() {
    _composer.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _appendUserText(String text) {
    setState(() => _items.add(_ChatItem.user(text)));
    _scheduleScroll();
  }

  int _showTyping() {
    _items.add(_ChatItem.bot(const TypingIndicator()));
    _typingItemIndex = _items.length - 1;
    setState(() {});
    _scheduleScroll();
    return _typingItemIndex!;
  }

  void _replaceTypingWithReply(int typingIndex, BotReply reply) {
    final cites =
        reply.citations.map((c) => Citation(c.docId, c.sectionKey)).toList();
    _items[typingIndex] = _ChatItem.bot(
      ChatBubble(role: ChatRole.bot, content: reply.content, citations: cites),
    );
    setState(() {});
    _scheduleScroll();
  }

  void _replaceTypingWithError(int typingIndex, String message) {
    _items[typingIndex] = _ChatItem.bot(
      ChatBubble(role: ChatRole.bot, content: message),
    );
    setState(() {});
    _scheduleScroll();
  }

  void _scheduleScroll() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final controller = _scroll.hasClients ? _scroll : null;
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
    final bloc = ctx.read<ChatBloc>();
    final isWaiting = bloc.state.maybeWhen(
      loading: (_) => true,
      orElse: () => false,
    );
    if (isWaiting) {
      return;
    }
    final text = _composer.text.trim();
    if (text.isEmpty) return;
    _composer.clear();
    _appendUserText(text);
    Analytics.instance.qnaAsk('free', text.length);
    _typingItemIndex = _showTyping();
    bloc.add(ChatEvent.messageSent(text));
  }

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;
    final headerHeight = spacing.x10 * 6;
    return BlocProvider<ChatBloc>(
      create:
          (ctx) => ChatBloc(
            repo: RepositoryProvider.of<ChatRepository>(ctx),
            historyBloc: ctx.read<HistoryBloc>(),
          ),
      child: Builder(
        builder: (innerCtx) {
          return BlocListener<ChatBloc, ChatState>(
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
            child: Scaffold(
              appBar: AppBar(title: const Text('AI 대화')),
              body: SafeArea(
                child: _CenteredContent(
                  child: Column(
                    children: [
                      Expanded(
                        child: CustomScrollView(
                          controller: _scroll,
                          slivers: [
                            SliverPersistentHeader(
                              pinned: true,
                              delegate: _ProductTypeHeaderDelegate(
                                height: headerHeight,
                                childBuilder: (ctx) => BlocBuilder<ChatBloc, ChatState>(
                                  builder: (context, state) {
                                    final selectedProductType = state.mapOrNull(
                                      idle: (s) => s.selectedProductType,
                                      loading: (s) => s.selectedProductType,
                                      success: (s) => s.selectedProductType,
                                      error: (s) => s.selectedProductType,
                                    );
                                    return ProductTypeSelector(
                                      selectedProductType: selectedProductType,
                                      onProductTypeSelected: (productTypeId) {
                                        context
                                            .read<ChatBloc>()
                                            .add(ChatEvent.productTypeSelected(productTypeId));
                                      },
                                    );
                                  },
                                ),
                              ),
                            ),
                            SliverToBoxAdapter(
                              child: Builder(
                                builder: (dividerContext) => Padding(
                                  padding: EdgeInsets.symmetric(horizontal: spacing.x4),
                                  child: Divider(
                                    height: spacing.x4,
                                    color: Theme.of(dividerContext).colorScheme.outlineVariant,
                                  ),
                                ),
                              ),
                            ),
                            SliverPadding(
                              padding: EdgeInsets.symmetric(
                                horizontal: spacing.x4,
                                vertical: spacing.x3,
                              ),
                              sliver: SliverList(
                                delegate: SliverChildBuilderDelegate(
                                  (context, index) {
                                    final item = _items[index];
                                    return Padding(
                                      padding: EdgeInsets.only(
                                        bottom: index == _items.length - 1 ? 0 : spacing.x3,
                                      ),
                                      child: item.isUser
                                          ? ChatBubble(
                                              role: ChatRole.user,
                                              content: item.text ?? '',
                                            )
                                          : item.widget!,
                                    );
                                  },
                                  childCount: _items.length,
                                ),
                              ),
                            ),
                            SliverToBoxAdapter(
                              child: SizedBox(height: spacing.x3),
                            ),
                          ],
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
                          final selectedProductLabel =
                              selectedProductType != null
                                  ? ProductTypes.findById(
                                    selectedProductType,
                                  )?.label
                                  : null;
                          final isSending = chatState.maybeWhen(
                            loading: (_) => true,
                            orElse: () => false,
                          );

                          return ChatComposer(
                            controller: _composer,
                            onSend: () => _onSend(context),
                            enabled: !isSending,
                            selectedProductType: selectedProductType,
                            selectedProductLabel: selectedProductLabel,
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
}

class _ChatItem {
  final bool isUser;
  final String? text;
  final Widget? widget;

  const _ChatItem._({required this.isUser, this.text, this.widget});

  factory _ChatItem.user(String text) => _ChatItem._(isUser: true, text: text);
  factory _ChatItem.bot(Widget widget) =>
      _ChatItem._(isUser: false, widget: widget);
}

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

class _ProductTypeHeaderDelegate extends SliverPersistentHeaderDelegate {
  _ProductTypeHeaderDelegate({
    required this.height,
    required this.childBuilder,
  });

  final double height;
  final WidgetBuilder childBuilder;

  @override
  double get minExtent => height;

  @override
  double get maxExtent => height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final scheme = Theme.of(context).colorScheme;
    final spacing = context.spacing;
    final showShadow = overlapsContent || shrinkOffset > 0;
    return SizedBox.expand(
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: scheme.surface,
          border: Border(bottom: BorderSide(color: scheme.outlineVariant)),
          boxShadow: showShadow
              ? [
                  BoxShadow(
                    color: scheme.shadow.withOpacity(0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : const [],
        ),
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            spacing.x4,
            spacing.x3,
            spacing.x4,
            spacing.x2,
          ),
          child: Align(
            alignment: Alignment.topCenter,
            child: childBuilder(context),
          ),
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(covariant _ProductTypeHeaderDelegate oldDelegate) => true;
}
