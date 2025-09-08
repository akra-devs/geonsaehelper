import 'dart:convert';
import 'package:flutter/foundation.dart';

class Analytics {
  Analytics._();
  static final Analytics instance = Analytics._();

  void log(String event, [Map<String, dynamic>? params]) {
    final payload = jsonEncode(params ?? const {});
    debugPrint('[analytics] $event $payload');
  }

  // Helpers (optional sugar)
  void tabChange(String tab) => log('tab_change', {'tab': tab});
  void quickSurveyComplete(int count, int durationMs) =>
      log('quick_survey_complete', {'count': count, 'duration_ms': durationMs});
  void intakeStart() => log('intake_start', {});
  void intakeAnswer(String qid, String answer, bool isUnknown) => log(
    'intake_answer',
    {'qid': qid, 'answer': answer, 'is_unknown': isUnknown},
  );
  void intakeComplete(
    int count,
    int durationMs,
    bool hasUnknown,
    String status,
  ) => log('intake_complete', {
    'question_count': count,
    'duration_ms': durationMs,
    'has_unknown': hasUnknown,
    'result_status': status,
  });
  void rulingShown(String status) => log('ruling_shown', {'status': status});
  void reasonsExpand(bool expanded) =>
      log('reasons_expand', {'expanded': expanded});
  void qnaAsk(String topic, int length) =>
      log('qna_ask', {'topic': topic, 'length': length});
  void qnaAnswer(bool hasDisclaimer, String lastVerified) => log('qna_answer', {
    'has_disclaimer': hasDisclaimer,
    'last_verified': lastVerified,
  });
  void nextStepClick(String action) =>
      log('next_step_click', {'action': action});
}
