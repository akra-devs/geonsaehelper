import 'package:freezed_annotation/freezed_annotation.dart';
import '../domain/assessment_history.dart';

part 'history_state.freezed.dart';

@freezed
class HistoryState with _$HistoryState {
  const factory HistoryState.initial() = _Initial;
  const factory HistoryState.loading() = _Loading;
  const factory HistoryState.loaded(List<AssessmentHistory> items) = _Loaded;
  const factory HistoryState.error(String message) = _Error;
}
