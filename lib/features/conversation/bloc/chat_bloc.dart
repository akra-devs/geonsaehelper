import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import '../../conversation/data/chat_repository.dart';
import '../../conversation/data/chat_models.dart';
import 'chat_event.dart';

part 'chat_bloc.freezed.dart';

@freezed
class ChatState with _$ChatState {
  const factory ChatState.idle({
    String? selectedProductType,
  }) = _Idle;
  const factory ChatState.loading({
    String? selectedProductType,
  }) = _Loading;
  const factory ChatState.success(
    BotReply reply, {
    String? selectedProductType,
  }) = _Success;
  const factory ChatState.error(
    String message, {
    String? selectedProductType,
  }) = _Error;
}

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final ChatRepository repo;

  ChatBloc(this.repo) : super(const ChatState.idle()) {
    on<MessageSent>(_onMessageSent);
    on<ChatReset>(_onReset);
    on<ProductTypeSelected>(_onProductTypeSelected);
  }

  Future<void> _onMessageSent(
    MessageSent event,
    Emitter<ChatState> emit,
  ) async {
    final currentProductType = state.mapOrNull(
      idle: (s) => s.selectedProductType,
      loading: (s) => s.selectedProductType,
      success: (s) => s.selectedProductType,
      error: (s) => s.selectedProductType,
    );

    emit(ChatState.loading(selectedProductType: currentProductType));
    try {
      final productTypes = currentProductType != null ? [currentProductType] : null;
      final reply = await repo.complete(event.text, productTypes: productTypes);
      emit(ChatState.success(reply, selectedProductType: currentProductType));
    } catch (e, st) {
      if (kDebugMode) {
        debugPrint('❌ [chat-bloc] message send failed: $e');
        debugPrintStack(stackTrace: st);
      }
      emit(ChatState.error(
        '네트워크 오류가 발생했습니다. 다시 시도해 주세요.',
        selectedProductType: currentProductType,
      ));
    }
  }

  void _onReset(ChatReset event, Emitter<ChatState> emit) {
    emit(const ChatState.idle());
  }

  void _onProductTypeSelected(ProductTypeSelected event, Emitter<ChatState> emit) {
    final current = state;
    current.maybeWhen(
      idle: (selectedProductType) => emit(ChatState.idle(selectedProductType: event.productType)),
      loading: (selectedProductType) => emit(ChatState.loading(selectedProductType: event.productType)),
      success: (reply, selectedProductType) => emit(ChatState.success(reply, selectedProductType: event.productType)),
      error: (message, selectedProductType) => emit(ChatState.error(message, selectedProductType: event.productType)),
      orElse: () {},
    );
  }
}
