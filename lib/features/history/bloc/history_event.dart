import 'package:freezed_annotation/freezed_annotation.dart';
import '../domain/assessment_history.dart';

part 'history_event.freezed.dart';

@freezed
class HistoryEvent with _$HistoryEvent {
  const factory HistoryEvent.load() = HistoryLoadRequested;
  const factory HistoryEvent.save(AssessmentHistory history) = HistorySaveRequested;
  const factory HistoryEvent.delete(String id) = HistoryDeleteRequested;
  const factory HistoryEvent.clear() = HistoryClearRequested;
}
