import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../../features/conversation/ui/conversation_item.dart';
import 'appear.dart';
import 'chat_bubble.dart';
import 'progress_inline.dart';
import 'intake_question.dart';
import 'suggestions_panel.dart';
import 'product_type_selector.dart';

/// Widget responsible for rendering different types of conversation items.
/// Follows single responsibility principle by handling only UI rendering,
/// while business logic remains in domain models and BLoC.
class ConversationItemWidget extends StatelessWidget {
  final ConversationItem item;
  final Function(String qid, String? value)? onChoiceSelected;
  final Function(SuggestionItem suggestion)? onSuggestionTap;
  final Function(String productTypeId)? onProductTypeSelected;

  const ConversationItemWidget({
    super.key,
    required this.item,
    this.onChoiceSelected,
    this.onSuggestionTap,
    this.onProductTypeSelected,
  });

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;

    switch (item.type) {
      case ConversationItemType.botMessage:
        return _buildBotMessage(context, spacing);

      case ConversationItemType.userMessage:
        return _buildUserMessage(context, spacing);

      case ConversationItemType.intakeQuestion:
        return _buildIntakeQuestion(context, spacing);

      case ConversationItemType.result:
        return _buildResult(context, spacing);

      case ConversationItemType.botWidget:
        return _buildBotWidget(context, spacing);

      case ConversationItemType.advertisement:
        return _buildAdvertisement(context, spacing);

      case ConversationItemType.suggestions:
        return _buildSuggestions(context, spacing);

      case ConversationItemType.productTypeSelector:
        return _buildProductTypeSelector(context, spacing);
    }
  }

  Widget _buildBotMessage(BuildContext context, spacing) {
    return Appear(
      delay: const Duration(milliseconds: 40),
      child: Padding(
        padding: EdgeInsets.only(bottom: spacing.x3),
        child: ChatBubble(role: ChatRole.bot, content: item.text ?? ''),
      ),
    );
  }

  Widget _buildUserMessage(BuildContext context, spacing) {
    return Appear(
      delay: const Duration(milliseconds: 40),
      child: Padding(
        padding: EdgeInsets.only(bottom: spacing.x3),
        child: ChatBubble(role: ChatRole.user, content: item.text ?? ''),
      ),
    );
  }

  Widget _buildIntakeQuestion(BuildContext context, spacing) {
    return Appear(
      delay: const Duration(milliseconds: 60),
      child: Padding(
        padding: EdgeInsets.only(bottom: spacing.x4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ProgressInline(
              current: item.questionIndex ?? 1,
              total: item.totalQuestions ?? 1,
              showBar: true,
            ),
            SizedBox(height: spacing.x1),
            IntakeQuestion(
              qid: item.questionId!,
              label: item.questionLabel!,
              options: item.choices!,
              showUnknown: true,
              onChanged:
                  (value) => onChoiceSelected?.call(item.questionId!, value),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResult(BuildContext context, spacing) {
    return Appear(
      child: Padding(
        padding: EdgeInsets.only(bottom: spacing.x4),
        child: item.resultCard!,
      ),
    );
  }

  Widget _buildBotWidget(BuildContext context, spacing) {
    return Appear(
      delay: const Duration(milliseconds: 50),
      duration: const Duration(milliseconds: 120),
      child: Padding(
        padding: EdgeInsets.only(bottom: spacing.x3),
        child: item.customWidget!,
      ),
    );
  }

  Widget _buildAdvertisement(BuildContext context, spacing) {
    return Appear(
      delay: const Duration(milliseconds: 80),
      child: Padding(
        padding: EdgeInsets.only(bottom: spacing.x4),
        child: item.advertisementWidget!,
      ),
    );
  }

  Widget _buildSuggestions(BuildContext context, spacing) {
    return Appear(
      duration: const Duration(milliseconds: 120),
      delay: const Duration(milliseconds: 50),
      child: Padding(
        padding: EdgeInsets.only(bottom: spacing.x3),
        child: SuggestionsPanel(
          suggestions: item.suggestions!,
          onTap: onSuggestionTap,
        ),
      ),
    );
  }

  Widget _buildProductTypeSelector(BuildContext context, spacing) {
    return Appear(
      duration: const Duration(milliseconds: 150),
      delay: const Duration(milliseconds: 60),
      child: Padding(
        padding: EdgeInsets.only(bottom: spacing.x4),
        child: ProductTypeSelector(
          selectedProductType: item.selectedProductType,
          onProductTypeSelected: (productTypeId) {
            onProductTypeSelected?.call(productTypeId);
          },
        ),
      ),
    );
  }
}
