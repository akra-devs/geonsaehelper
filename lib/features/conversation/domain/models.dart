import 'package:flutter/foundation.dart';

@immutable
class Choice {
  final String value;
  final String text;
  const Choice({required this.value, required this.text});
}

enum RulingStatus { possible, notPossibleInfo, notPossibleDisq }

enum ReasonKind { met, unmet, unknown, warning }

@immutable
class Reason {
  final String text;
  final ReasonKind kind;
  const Reason(this.text, this.kind);
}

@immutable
class ConversationQuestion {
  final String qid;
  final String label;
  final List<Choice> choices;
  final int index;
  final int total;
  final bool isSurvey;
  const ConversationQuestion({
    required this.qid,
    required this.label,
    required this.choices,
    required this.index,
    required this.total,
    required this.isSurvey,
  });
}

@immutable
class ConversationResult {
  final RulingStatus status;
  final String tldr;
  final List<Reason> reasons;
  final List<String> nextSteps;
  final String lastVerified;
  const ConversationResult(this.status, this.tldr, this.reasons, this.nextSteps, this.lastVerified);
}

