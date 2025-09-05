/// Domain model for suggestion actions, decoupled from UI components
class SuggestionAction {
  final String id;
  final String label;
  final String botReply;

  const SuggestionAction({
    required this.id,
    required this.label,
    required this.botReply,
  });
}

/// Predefined suggestion actions available in the conversation
class SuggestionActions {
  static const limitEstimation = SuggestionAction(
    id: 'limit_estimation',
    label: '한도 추정하기',
    botReply: '한도는 소득/보증금/지역 등에 따라 달라집니다. 내부 기준으로 개요를 안내드릴게요.',
  );

  static const documentChecklist = SuggestionAction(
    id: 'document_checklist', 
    label: '서류 체크리스트',
    botReply: '기본 서류는 신분증, 가족·혼인관계, 소득 증빙입니다. 발급처와 순서를 안내해요.',
  );

  static const verificationMethods = SuggestionAction(
    id: 'verification_methods',
    label: '확인 방법 보기',
    botReply: '세대주/보증금/근저당 확인 방법을 알려드릴게요.',
  );

  /// Map of all available suggestions by ID
  static const Map<String, SuggestionAction> all = {
    'limit_estimation': limitEstimation,
    'document_checklist': documentChecklist,
    'verification_methods': verificationMethods,
  };

  /// List of all suggestions for UI display
  static const List<SuggestionAction> list = [
    limitEstimation,
    documentChecklist,
    verificationMethods,
  ];
}