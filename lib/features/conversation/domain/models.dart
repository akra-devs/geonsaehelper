import 'package:flutter/foundation.dart';

@immutable
class Choice {
  final String value;
  final String text;
  const Choice({required this.value, required this.text});
}

enum RulingStatus { possible, notPossibleInfo, notPossibleDisq }

enum ReasonKind { met, unmet, unknown, warning }

// Program identifiers for HUG programs
enum ProgramId {
  RENT_STANDARD,
  RENT_NEWLYWED,
  RENT_YOUTH,
  RENT_NEWBORN,
  RENT_DAMAGES,
}

@immutable
class SourceRef {
  final String docId;
  final String sectionKey;
  const SourceRef(this.docId, this.sectionKey);
}

@immutable
class Reason {
  final String text;
  final ReasonKind kind;
  final List<SourceRef>? sources;
  const Reason(this.text, this.kind, [this.sources]);
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
class ProgramMatch {
  final ProgramId programId; // e.g., RENT_STANDARD, RENT_NEWBORN
  final RulingStatus status; // map: eligible->possible, info_needed->notPossibleInfo, ineligible->notPossibleDisq
  final String summary; // one-line summary
  const ProgramMatch({
    required this.programId,
    required this.status,
    required this.summary,
  });
}

@immutable
class ConversationResult {
  final RulingStatus status;
  final String tldr;
  final List<Reason> reasons;
  final List<String> nextSteps;
  final String lastVerified;
  final List<ProgramMatch>? programMatches; // optional per-program results
  const ConversationResult(
    this.status,
    this.tldr,
    this.reasons,
    this.nextSteps,
    this.lastVerified,
    [this.programMatches]
  );
}
