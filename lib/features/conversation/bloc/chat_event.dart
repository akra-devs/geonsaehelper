import 'package:freezed_annotation/freezed_annotation.dart';

part 'chat_event.freezed.dart';

@freezed
class ChatEvent with _$ChatEvent {
  /// Event to send a message to the chat system
  const factory ChatEvent.messageSent(String text) = MessageSent;

  /// Event to reset the chat state to idle
  const factory ChatEvent.reset() = ChatReset;

  /// Event to select a product type for Q&A
  const factory ChatEvent.productTypeSelected(String productType) = ProductTypeSelected;
}
