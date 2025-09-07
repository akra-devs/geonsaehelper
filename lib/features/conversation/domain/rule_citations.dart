import 'models.dart';

class RuleCitations {
  static const SourceRef household = SourceRef('HUG_POLICY_DOCS/버팀목전세자금', 'eligibility');
  static const SourceRef credit = SourceRef('HUG_POLICY_DOCS/버팀목전세자금', 'eligibility');
  static const SourceRef propertyType = SourceRef('HUG_POLICY_DOCS/버팀목전세자금', 'property');
  static const SourceRef floorArea = SourceRef('HUG_POLICY_DOCS/버팀목전세자금', 'property');
  static const SourceRef regionLimits = SourceRef('HUG_POLICY_DOCS/버팀목전세자금', 'region_limits');
  static const SourceRef incomeCap = SourceRef('HUG_POLICY_DOCS/HUG_POLICY', 'RENT_STANDARD:income_cap');
  static const SourceRef assetCap = SourceRef('HUG_POLICY_DOCS/HUG_POLICY', 'RENT_STANDARD:asset_cap');
  static const SourceRef damages = SourceRef('HUG_POLICY_DOCS/HUG_POLICY', 'RENT_DAMAGES_*:eligibility');
  static const SourceRef youth = SourceRef('HUG_POLICY_DOCS/HUG_POLICY', 'RENT_YOUTH_BEOTIMMOK:eligibility');
  static const SourceRef newlywed = SourceRef('HUG_POLICY_DOCS/HUG_POLICY', 'RENT_NEWLYWED:eligibility');
  static const SourceRef newborn = SourceRef('HUG_POLICY_DOCS/HUG_POLICY', 'RENT_NEWBORN_SPECIAL:eligibility');

  static List<SourceRef> forQid(String qid) {
    switch (qid) {
      case 'A1':
      case 'A2':
        return const [household];
      case 'A3':
        return const [youth, household];
      case 'A4':
        return const [newlywed, household];
      case 'A6':
        return const [incomeCap];
      case 'A7':
        return const [assetCap];
      case 'C1':
        return const [credit];
      case 'P1':
        return const [household];
      case 'P2':
        return const [regionLimits];
      case 'P3':
        return const [propertyType];
      case 'P4':
      case 'P4a':
        return const [floorArea];
      case 'P5':
        return const [regionLimits];
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
