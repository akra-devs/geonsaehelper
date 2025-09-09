/// Centralized validation/normalization for Q&A citations to enforce
/// internal-docs-only policy and sectionKey presence.
class CitationSchema {
  /// Allow only internal policy docs (no external links/IDs).
  static const List<String> allowedDocIds = [
    'HUG_POLICY_DOCS/HUG_POLICY.md',
    'HUG_POLICY_DOCS/버팀목전세자금.MD',
    'HUG_POLICY_DOCS/청년전용 버팀목전세자금.MD',
    'HUG_POLICY_DOCS/신혼부부전용 전세자금.MD',
    'HUG_POLICY_DOCS/신생아 특례 버팀목대출.MD',
    'HUG_POLICY_DOCS/전세피해 임차인 버팀목전세자금.MD',
  ];

  /// Backward-compatibility aliases from older server responses.
  static const Map<String, String> docAliases = {
    // Legacy/internal names -> normalized path
    'HUG_internal_policy.md': 'HUG_POLICY_DOCS/HUG_POLICY.md',
    'HUG_POLICY.md': 'HUG_POLICY_DOCS/HUG_POLICY.md',
  };

  /// Normalize docId by applying alias mapping.
  static String normalizeDocId(String docId) {
    if (docAliases.containsKey(docId)) return docAliases[docId]!;
    return docId;
  }

  /// Basic validation: docId must be one of the allowed list and sectionKey non-empty.
  static bool isValid(String docId, String sectionKey) {
    if (docId.isEmpty || sectionKey.isEmpty) return false;
    if (!allowedDocIds.contains(docId)) return false;
    return true;
  }
}

