import 'package:flutter/material.dart';
import '../../../ui/components/result_card.dart';
import '../../../ui/components/suggestions_panel.dart';
import '../domain/models.dart' as domain;

/// Represents different types of items that can appear in a conversation
enum ConversationItemType {
  botMessage,
  userMessage,
  intakeQuestion,
  result,
  botWidget,
  advertisement,
  suggestions,
}

/// A conversation item that holds data for rendering different types of content
/// in the conversation flow. This follows the single responsibility principle
/// by separating data representation from UI rendering logic.
class ConversationItem {
  final ConversationItemType type;
  
  // Text content (for messages)
  final String? text;
  
  // Intake question data
  final String? questionId;
  final String? questionLabel;
  final List<domain.Choice>? choices;
  final int? questionIndex;
  final int? totalQuestions;
  final bool? isSurvey;
  
  // Result data
  final ResultCard? resultCard;
  
  // Rich widget content (for typing indicators, custom widgets)
  final Widget? customWidget;
  
  // Advertisement widget
  final Widget? advertisementWidget;
  
  // Suggestions data
  final List<SuggestionItem>? suggestions;

  const ConversationItem._({
    required this.type,
    this.text,
    this.questionId,
    this.questionLabel,
    this.choices,
    this.questionIndex,
    this.totalQuestions,
    this.isSurvey,
    this.resultCard,
    this.customWidget,
    this.advertisementWidget,
    this.suggestions,
  });

  /// Creates a bot message item
  factory ConversationItem.botMessage(String text) {
    return ConversationItem._(
      type: ConversationItemType.botMessage,
      text: text,
    );
  }

  /// Creates a user message item
  factory ConversationItem.userMessage(String text) {
    return ConversationItem._(
      type: ConversationItemType.userMessage,
      text: text,
    );
  }

  /// Creates an intake question item
  factory ConversationItem.intakeQuestion({
    required String questionId,
    required String label,
    required List<domain.Choice> choices,
    int? index,
    int? total,
    bool isSurvey = false,
  }) {
    return ConversationItem._(
      type: ConversationItemType.intakeQuestion,
      questionId: questionId,
      questionLabel: label,
      choices: choices,
      questionIndex: index,
      totalQuestions: total,
      isSurvey: isSurvey,
    );
  }

  /// Creates a result item
  factory ConversationItem.result(ResultCard resultCard) {
    return ConversationItem._(
      type: ConversationItemType.result,
      resultCard: resultCard,
    );
  }

  /// Creates a bot widget item (for typing indicators, chat bubbles with citations, etc.)
  factory ConversationItem.botWidget(Widget widget) {
    return ConversationItem._(
      type: ConversationItemType.botWidget,
      customWidget: widget,
    );
  }

  /// Creates an advertisement item
  factory ConversationItem.advertisement(Widget adWidget) {
    return ConversationItem._(
      type: ConversationItemType.advertisement,
      advertisementWidget: adWidget,
    );
  }

  /// Creates a suggestions item
  factory ConversationItem.suggestions(List<SuggestionItem> suggestions) {
    return ConversationItem._(
      type: ConversationItemType.suggestions,
      suggestions: suggestions,
    );
  }
}
