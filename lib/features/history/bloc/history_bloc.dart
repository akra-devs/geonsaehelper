import 'package:hydrated_bloc/hydrated_bloc.dart';
import '../domain/assessment_history.dart';
import 'history_event.dart';
import 'history_state.dart';

class HistoryBloc extends HydratedBloc<HistoryEvent, HistoryState> {
  HistoryBloc() : super(const HistoryState.loaded([])) {
    on<HistoryLoadRequested>(_onLoad);
    on<HistorySaveRequested>(_onSave);
    on<HistoryDeleteRequested>(_onDelete);
    on<HistoryClearRequested>(_onClear);
  }

  void _onLoad(
    HistoryLoadRequested event,
    Emitter<HistoryState> emit,
  ) {
    // State is automatically restored from storage by HydratedBloc
    // Just emit current state
    print('🔍 [history-bloc] Load requested, emitting current state');
  }

  void _onSave(
    HistorySaveRequested event,
    Emitter<HistoryState> emit,
  ) {
    print('💾 [history-bloc] Saving: ${event.history.id}');
    state.maybeWhen(
      loaded: (items) {
        final updated = [event.history, ...items].take(50).toList();
        print('✅ [history-bloc] Saved, total: ${updated.length}');
        emit(HistoryState.loaded(updated));
      },
      orElse: () {
        print('✅ [history-bloc] Saved as first item');
        emit(HistoryState.loaded([event.history]));
      },
    );
  }

  void _onDelete(
    HistoryDeleteRequested event,
    Emitter<HistoryState> emit,
  ) {
    print('🗑️ [history-bloc] Deleting: ${event.id}');
    state.maybeWhen(
      loaded: (items) {
        final updated = items.where((e) => e.id != event.id).toList();
        print('✅ [history-bloc] Deleted, remaining: ${updated.length}');
        emit(HistoryState.loaded(updated));
      },
      orElse: () {
        print('⚠️ [history-bloc] Delete skipped, no items loaded');
      },
    );
  }

  void _onClear(
    HistoryClearRequested event,
    Emitter<HistoryState> emit,
  ) {
    print('🗑️ [history-bloc] Clearing all history');
    emit(const HistoryState.loaded([]));
    print('✅ [history-bloc] Cleared successfully');
  }

  @override
  HistoryState? fromJson(Map<String, dynamic> json) {
    try {
      print('📥 [history-bloc] Restoring from storage...');
      final items = (json['items'] as List<dynamic>?)
              ?.map((e) => AssessmentHistory.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [];
      print('✅ [history-bloc] Restored ${items.length} items');
      return HistoryState.loaded(items);
    } catch (e, stack) {
      print('❌ [history-bloc] Restore failed: $e');
      print('📍 [history-bloc] Stack: $stack');
      return const HistoryState.loaded([]);
    }
  }

  @override
  Map<String, dynamic>? toJson(HistoryState state) {
    return state.maybeWhen(
      loaded: (items) {
        print('💾 [history-bloc] Persisting ${items.length} items');
        return {
          'items': items.map((e) => e.toJson()).toList(),
        };
      },
      orElse: () => null,
    );
  }
}
