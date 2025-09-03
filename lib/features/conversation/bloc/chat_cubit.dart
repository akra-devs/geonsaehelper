import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import '../../conversation/data/chat_repository.dart';
import '../../conversation/data/chat_models.dart';

part 'chat_cubit.freezed.dart';

@freezed
class ChatState with _$ChatState {
  const factory ChatState.idle() = _Idle;
  const factory ChatState.loading() = _Loading;
  const factory ChatState.success(BotReply reply) = _Success;
  const factory ChatState.error(String message) = _Error;
}

class ChatCubit extends Cubit<ChatState> {
  final ChatRepository repo;
  ChatCubit(this.repo) : super(const ChatState.idle());

  Future<void> send(String text) async {
    emit(const ChatState.loading());
    try {
      await repo.ensureSession();
      final r = await repo.complete(text);
      emit(ChatState.success(r));
    } catch (e) {
      emit(const ChatState.error('네트워크 오류가 발생했습니다. 다시 시도해 주세요.'));
    }
  }
}
