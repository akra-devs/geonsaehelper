import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import '../../conversation/data/chat_repository.dart';
import '../../conversation/data/chat_models.dart';
import 'chat_event.dart';

part 'chat_bloc.freezed.dart';

@freezed
class ChatState with _$ChatState {
  const factory ChatState.idle() = _Idle;
  const factory ChatState.loading() = _Loading;
  const factory ChatState.success(BotReply reply) = _Success;
  const factory ChatState.error(String message) = _Error;
}

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final ChatRepository repo;

  ChatBloc(this.repo) : super(const ChatState.idle()) {
    on<MessageSent>(_onMessageSent);
    on<ChatReset>(_onReset);
  }

  Future<void> _onMessageSent(
    MessageSent event,
    Emitter<ChatState> emit,
  ) async {
    emit(const ChatState.loading());
    try {
      final reply = await repo.complete(event.text);
      emit(ChatState.success(reply));
    } catch (e) {
      emit(const ChatState.error('네트워크 오류가 발생했습니다. 다시 시도해 주세요.'));
    }
  }

  void _onReset(ChatReset event, Emitter<ChatState> emit) {
    emit(const ChatState.idle());
  }
}
