import 'package:freezed_annotation/freezed_annotation.dart';
import '../../conversation/domain/models.dart';

part 'assessment_history.freezed.dart';
part 'assessment_history.g.dart';

/// A saved assessment result with timestamp and user responses
@freezed
class AssessmentHistory with _$AssessmentHistory {
  const factory AssessmentHistory({
    required String id, // Unique identifier (e.g., UUID)
    required DateTime timestamp, // When the assessment was completed
    required RulingStatus status, // Overall ruling status
    required String tldr, // Summary from result
    required Map<String, String> responses, // Question ID -> Answer value
    String? lastVerified, // Rules verification date
  }) = _AssessmentHistory;

  factory AssessmentHistory.fromJson(Map<String, dynamic> json) =>
      _$AssessmentHistoryFromJson(json);
}
