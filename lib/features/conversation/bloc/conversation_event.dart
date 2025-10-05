import 'package:freezed_annotation/freezed_annotation.dart';

part 'conversation_event.freezed.dart';

@freezed
class ConversationEvent with _$ConversationEvent {
  /// Event to start the conversation flow
  const factory ConversationEvent.started() = ConversationStarted;

  /// Event when user selects a choice for a question
  const factory ConversationEvent.choiceSelected(String qid, String value) =
      ChoiceSelected;

  /// Event when user selects a suggestion item by ID
  const factory ConversationEvent.suggestionSelected(String suggestionId) =
      SuggestionSelected;

  /// Event to reset/restart the conversation
  const factory ConversationEvent.reset() = ConversationReset;
}
