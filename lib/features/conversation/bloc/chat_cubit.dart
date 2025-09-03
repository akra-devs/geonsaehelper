import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../conversation/data/chat_repository.dart';
import '../../conversation/data/chat_models.dart' as model;

@immutable
class ChatState {
  final bool loading;
  final model.BotReply? reply;
  final String? error;
  const ChatState({this.loading = false, this.reply, this.error});

  ChatState copyWith({bool? loading, model.BotReply? reply, String? error}) =>
      ChatState(loading: loading ?? this.loading, reply: reply, error: error);
}

class ChatCubit extends Cubit<ChatState> {
  final ChatRepository repo;
  ChatCubit(this.repo) : super(const ChatState());

  Future<void> send(String text) async {
    emit(state.copyWith(loading: true, reply: null, error: null));
    try {
      await repo.ensureSession();
      final r = await repo.complete(text);
      emit(ChatState(loading: false, reply: r));
    } catch (e) {
      emit(ChatState(loading: false, error: '네트워크 오류가 발생했습니다. 다시 시도해 주세요.'));
    }
  }
}

