import 'models.dart';

class RuleCitations {
  // 표준형(버팀목전세자금) — 근거: HUG_POLICY_DOCS/버팀목전세자금.MD
  static const SourceRef household = SourceRef(
    'HUG_POLICY_DOCS/버팀목전세자금.MD',
    '자격(세대주·무주택)',
  );
  static const SourceRef credit = SourceRef(
    'HUG_POLICY_DOCS/버팀목전세자금.MD',
    '신용도 조건',
  );
  static const SourceRef duplicateLoans = SourceRef(
    'HUG_POLICY_DOCS/버팀목전세자금.MD',
    '자격/중복대출 금지',
  );
  static const SourceRef propertyType = SourceRef(
    'HUG_POLICY_DOCS/버팀목전세자금.MD',
    '대상주택',
  );
  static const SourceRef floorArea = SourceRef(
    'HUG_POLICY_DOCS/버팀목전세자금.MD',
    '대상주택/전용면적',
  );
  static const SourceRef depositUpperBound = SourceRef(
    'HUG_POLICY_DOCS/버팀목전세자금.MD',
    '대상주택/임차보증금 상한',
  );
  static const SourceRef incomeCap = SourceRef(
    'HUG_POLICY_DOCS/버팀목전세자금.MD',
    '자격/소득',
  );
  static const SourceRef assetCap = SourceRef(
    'HUG_POLICY_DOCS/버팀목전세자금.MD',
    '자격/자산',
  );

  // 특례/전용 상품 — 근거: 각 HUG_POLICY_DOCS 하위 파일
  static const SourceRef damages = SourceRef(
    'HUG_POLICY_DOCS/전세피해 임차인 버팀목전세자금.MD',
    '대출 대상 자격요건',
  );
  static const SourceRef youth = SourceRef(
    'HUG_POLICY_DOCS/청년전용 버팀목전세자금.MD',
    '자격',
  );
  static const SourceRef newlywed = SourceRef(
    'HUG_POLICY_DOCS/신혼부부전용 전세자금.MD',
    '자격',
  );
  static const SourceRef newborn = SourceRef(
    'HUG_POLICY_DOCS/신생아 특례 버팀목대출.MD',
    '자격',
  );
  static const SourceRef encumbrance = SourceRef(
    'HUG_POLICY_DOCS/HUG_POLICY.md',
    'RENT_STANDARD:notes',
  );

  static List<SourceRef> forQid(String qid) {
    switch (qid) {
      case 'A1':
      case 'A2':
        return const [household];
      case 'A3':
        return const [youth, household];
      case 'A4':
        return const [newlywed, household];
      case 'A8':
        return const [newborn];
      case 'A6':
        return const [incomeCap];
      case 'A7':
        return const [assetCap];
      case 'A9':
      case 'A10':
        return const [incomeCap];
      case 'C1':
        return const [credit];
      case 'C2':
        return const [duplicateLoans];
      case 'P2':
        return const [depositUpperBound];
      case 'P3':
        return const [propertyType];
      case 'P4':
      case 'P4a':
        return const [floorArea];
      case 'P5':
        return const [depositUpperBound];
      case 'P7':
        return const [encumbrance];
      case 'S1':
      case 'S1a':
        return const [damages];
      case 'A5':
        return const [newborn];
      default:
        return const [];
    }
  }
}
