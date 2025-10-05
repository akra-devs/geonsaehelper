/// Product type definitions for HUG rental deposit loans
class ProductType {
  final String id;
  final String label;
  final String description;

  const ProductType({
    required this.id,
    required this.label,
    required this.description,
  });
}

/// Available HUG product types for Q&A
class ProductTypes {
  static const rentStandard = ProductType(
    id: 'RENT_STANDARD',
    label: '버팀목 전세자금',
    description: '무주택 세대주 대상 기본 전세대출',
  );

  static const rentNewlywed = ProductType(
    id: 'RENT_NEWLYWED',
    label: '신혼부부 전세자금',
    description: '혼인 7년 이내 신혼부부 대상',
  );

  static const rentYouth = ProductType(
    id: 'RENT_YOUTH',
    label: '청년 전세자금',
    description: '만 19~34세 청년 대상',
  );

  static const rentNewborn = ProductType(
    id: 'RENT_NEWBORN',
    label: '신생아 특례 버팀목',
    description: '2년 내 출생아 가구 대상',
  );

  static const rentDamages = ProductType(
    id: 'RENT_DAMAGES',
    label: '전세피해 임차인 전세자금',
    description: '전세사기 피해자 지원',
  );

  static const rentDamagesPriority = ProductType(
    id: 'RENT_DAMAGES_PRIORITY',
    label: '전세사기 피해자 최우선변제금',
    description: '전세사기 피해자 최우선변제',
  );

  static const List<ProductType> all = [
    rentStandard,
    rentNewlywed,
    rentYouth,
    rentNewborn,
    rentDamages,
    rentDamagesPriority,
  ];

  static ProductType? findById(String id) {
    try {
      return all.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }
}
