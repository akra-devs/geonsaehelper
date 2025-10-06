import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import '../../conversation/data/chat_repository.dart';
import '../../conversation/data/chat_models.dart';
import '../../conversation/domain/constants.dart';
import '../../history/bloc/history_bloc.dart';
import '../../history/bloc/history_state.dart';
import '../../history/domain/assessment_history.dart';
import '../../history/domain/question_labels.dart';
import 'chat_event.dart';

part 'chat_bloc.freezed.dart';

@freezed
class ChatState with _$ChatState {
  const factory ChatState.idle({String? selectedProductType}) = _Idle;
  const factory ChatState.loading({String? selectedProductType}) = _Loading;
  const factory ChatState.success(
    BotReply reply, {
    String? selectedProductType,
  }) = _Success;
  const factory ChatState.error(String message, {String? selectedProductType}) =
      _Error;
}

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final ChatRepository repo;
  final HistoryBloc historyBloc;

  ChatBloc({required this.repo, required this.historyBloc})
    : super(const ChatState.idle()) {
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
      final productTypes =
          currentProductType != null ? [currentProductType] : null;
      final contextPayload = _buildUserContext();
      final reply = await repo.complete(
        event.text,
        productTypes: productTypes,
        userContext: contextPayload.isEmpty ? null : contextPayload,
      );
      emit(ChatState.success(reply, selectedProductType: currentProductType));
    } catch (e, st) {
      if (kDebugMode) {
        debugPrint('❌ [chat-bloc] message send failed: $e');
        debugPrintStack(stackTrace: st);
      }
      emit(
        ChatState.error(
          '네트워크 오류가 발생했습니다. 다시 시도해 주세요.',
          selectedProductType: currentProductType,
        ),
      );
    }
  }

  void _onReset(ChatReset event, Emitter<ChatState> emit) {
    emit(const ChatState.idle());
  }

  void _onProductTypeSelected(
    ProductTypeSelected event,
    Emitter<ChatState> emit,
  ) {
    final current = state;
    current.maybeWhen(
      idle:
          (selectedProductType) =>
              emit(ChatState.idle(selectedProductType: event.productType)),
      loading:
          (selectedProductType) =>
              emit(ChatState.loading(selectedProductType: event.productType)),
      success:
          (reply, selectedProductType) => emit(
            ChatState.success(reply, selectedProductType: event.productType),
          ),
      error:
          (message, selectedProductType) => emit(
            ChatState.error(message, selectedProductType: event.productType),
          ),
      orElse: () {},
    );
  }

  Map<String, String> _buildUserContext() {
    final HistoryState state = historyBloc.state;
    final AssessmentHistory? assessment = state.maybeWhen(
      loaded: (items) => items.isNotEmpty ? items.first : null,
      orElse: () => null,
    );

    final context = <String, String>{'requestType': 'FOLLOW_UP_QNA'};

    if (assessment == null) {
      context['historyAvailable'] = 'false';
      return context;
    }

    context['historyAvailable'] = 'true';
    context['userContextKey'] = assessment.id;
    context['rulingStatus'] = assessment.status.name;
    context['resultSummary'] = assessment.tldr;
    context['lastVerified'] =
        (assessment.lastVerified?.isNotEmpty ?? false)
            ? assessment.lastVerified!
            : rulesLastVerifiedYmd;

    assessment.responses.forEach((qid, rawValue) {
      final normalized =
          rawValue == conversationUnknownValue
              ? '확인불가'
              : QuestionLabels.getAnswerText(rawValue);
      context['${qid}_label'] = QuestionLabels.getQuestionLabel(qid);
      context['${qid}_value'] = normalized;
      context['${qid}_raw'] = rawValue;
    });

    return context;
  }
}
