import 'models.dart';
import 'constants.dart';

/// Evaluate per-program eligibility summaries based on collected answers.
/// Returns a list of ProgramMatch ordered by business priority should be applied at UI.
List<ProgramMatch> evaluateProgramMatches(Map<String, String> answers) {
  final matches = <ProgramMatch>[];

  bool isMissing(String qid) => !answers.containsKey(qid) ||
      answers[qid] == conversationUnknownValue;

  final a1 = answers['A1'];
  final a2 = answers['A2'];
  final a3 = answers['A3'];
  final a4 = answers['A4'];
  final a5 = answers['A5'];
  final a6 = answers['A6'];
  final a8 = answers['A8'];
  final a9 = answers['A9'];
  final a10 = answers['A10'];
  final c1 = answers['C1'];
  final c2 = answers['C2'];
  final p2 = answers['P2'];
  final p3 = answers['P3'];
  final p4 = answers['P4'];
  final p4a = answers['P4a'];
  final p5 = answers['P5'];
  final s1 = answers['S1'];

  // Global disqualifier summary (applies to all programs)
  String? globalDisq() {
    if (a3 == 'under19') return '성년 요건 미충족(만 19세 미만)';
    if (a1 == 'household_member') return '세대주 요건 불충족';
    if (a2 == 'no') return '무주택 요건 불충족';
    if (c1 == 'has') return '결격/제한(신용·공공임대)';
    if (c2 == 'fund_rent' || c2 == 'bank_rent' || c2 == 'mortgage') {
      return '중복대출 금지(기존 대출/보증)';
    }
    if (p3 == 'other') return '대상 주택 유형 아님(비주거 등)';
    if (p4 == 'fa_gt100') return '전용면적 100㎡ 초과';
    if (p4 == 'fa_86_100' && p4a == 'no') return '전용면적 85㎡ 초과(읍·면 아님)';
    return null;
  }

  final disq = globalDisq();

  bool children2p = a9 == 'child2' || a9 == 'child3p';
  bool favored = (a10 != null && a10 != 'none');
  bool isMetro = p2 == 'metro';
  bool isMetroCity = p2 == 'metrocity';
  bool isOthers = p2 == 'others';

  ProgramMatch mk(ProgramId id, RulingStatus s, String msg) =>
      ProgramMatch(programId: id, status: s, summary: msg);

  // Helper for deposit boundary checks used in multiple programs
  RulingStatus? stdDepositStatus() {
    if (p5 == null || p2 == null) return RulingStatus.notPossibleInfo;
    if (isMetro) {
      if (p5 == 'dep_gt3') return RulingStatus.notPossibleDisq; // >3억 불가
    } else if (isMetroCity || isOthers) {
      if (p5 == 'dep_gt3') return RulingStatus.notPossibleDisq; // >3억 불가
      if (p5 == 'dep_le3') return RulingStatus.notPossibleInfo; // 2~3억 경계
    }
    return null; // ok
  }

  RulingStatus incomeStandard() {
    if (a6 == null || a6 == conversationUnknownValue) {
      return RulingStatus.notPossibleInfo;
    }
    if (a6 == 'inc_le50m') return RulingStatus.possible;
    if (a6 == 'inc_le60m' && (children2p || favored)) return RulingStatus.possible;
    return RulingStatus.notPossibleDisq;
  }

  // Standard
  if (disq != null) {
    matches.add(mk(ProgramId.RENT_STANDARD, RulingStatus.notPossibleDisq, disq));
  } else if (isMissing('P2') || isMissing('P3') || isMissing('P4') || isMissing('P5')) {
    matches.add(mk(ProgramId.RENT_STANDARD, RulingStatus.notPossibleInfo, '주택 정보 확인 필요(유형/면적/지역/보증금)'));
  } else {
    final depSt = stdDepositStatus();
    if (depSt == RulingStatus.notPossibleDisq) {
      matches.add(mk(ProgramId.RENT_STANDARD, depSt!, isMetro ? '임차보증금 상한 초과(수도권 3억)' : '임차보증금 상한 초과(비수도권 2~3억)'));
    } else if (depSt == RulingStatus.notPossibleInfo) {
      matches.add(mk(ProgramId.RENT_STANDARD, depSt!, '보증금 구간(≤3억)에서 2~3억 여부 확인 필요(비수도권 2억 상한)'));
    } else {
      final incSt = incomeStandard();
      final sum = incSt == RulingStatus.possible
          ? '요건 충족(소득/자산/지역·보증금/면적)'
          : (incSt == RulingStatus.notPossibleInfo
              ? '소득 구간 확인 필요'
              : '소득 상한 초과(5천 또는 우대 6천)');
      matches.add(mk(ProgramId.RENT_STANDARD, incSt, sum));
    }
  }

  // Newlywed
  if (disq != null) {
    matches.add(mk(ProgramId.RENT_NEWLYWED, RulingStatus.notPossibleDisq, disq));
  } else if (a4 == null || a4 == conversationUnknownValue) {
    matches.add(mk(ProgramId.RENT_NEWLYWED, RulingStatus.notPossibleInfo, '혼인 상태 확인 필요'));
  } else if (!(a4 == 'newly7y' || a4 == 'marry_3m_planned')) {
    matches.add(mk(ProgramId.RENT_NEWLYWED, RulingStatus.notPossibleDisq, '신혼 요건 미해당'));
  } else if (a6 == null || a6 == conversationUnknownValue) {
    matches.add(mk(ProgramId.RENT_NEWLYWED, RulingStatus.notPossibleInfo, '소득 구간 확인 필요'));
  } else if (a6 == 'inc_le130m' || a6 == 'inc_over') {
    matches.add(mk(ProgramId.RENT_NEWLYWED, RulingStatus.notPossibleDisq, '소득 상한 초과(신혼 7천5백만원)'));
  } else if (p2 == 'metro' && p5 == 'dep_gt3') {
    matches.add(mk(ProgramId.RENT_NEWLYWED, RulingStatus.notPossibleInfo, '보증금 경계(3~4억) 정확 금액 확인'));
  } else if ((isMetroCity || isOthers) && p5 == 'dep_gt3') {
    matches.add(mk(ProgramId.RENT_NEWLYWED, RulingStatus.notPossibleDisq, '임차보증금 상한 초과(비수도권 3억)'));
  } else {
    matches.add(mk(ProgramId.RENT_NEWLYWED, RulingStatus.possible, '요건 충족(신혼 예외 포함)'));
  }

  // Youth
  if (disq != null) {
    matches.add(mk(ProgramId.RENT_YOUTH, RulingStatus.notPossibleDisq, disq));
  } else if (a3 == null || a3 == conversationUnknownValue) {
    matches.add(mk(ProgramId.RENT_YOUTH, RulingStatus.notPossibleInfo, '연령 확인 필요'));
  } else if (a3 != 'y19_34') {
    matches.add(mk(ProgramId.RENT_YOUTH, RulingStatus.notPossibleDisq, '청년 연령 요건 미해당'));
  } else if (a6 == null || a6 == conversationUnknownValue) {
    matches.add(mk(ProgramId.RENT_YOUTH, RulingStatus.notPossibleInfo, '소득 구간 확인 필요'));
  } else if (a6 != 'inc_le50m') {
    matches.add(mk(ProgramId.RENT_YOUTH, RulingStatus.notPossibleDisq, '소득 상한 초과(청년 5천만원)'));
  } else if ((p5 == 'dep_le2' || p5 == 'dep_le3')) {
    matches.add(mk(ProgramId.RENT_YOUTH, RulingStatus.notPossibleInfo, '보증금 경계(1.5~2.0억) 정확 금액 확인'));
  } else {
    matches.add(mk(ProgramId.RENT_YOUTH, RulingStatus.possible, '요건 충족(청년)'));
  }

  // Newborn
  if (disq != null) {
    matches.add(mk(ProgramId.RENT_NEWBORN, RulingStatus.notPossibleDisq, disq));
  } else if (a5 == null || a5 == conversationUnknownValue) {
    matches.add(mk(ProgramId.RENT_NEWBORN, RulingStatus.notPossibleInfo, '출산 여부 확인 필요'));
  } else if (a5 != 'yes') {
    matches.add(mk(ProgramId.RENT_NEWBORN, RulingStatus.notPossibleDisq, '신생아 특례 요건 미해당'));
  } else if (a6 == null || a6 == conversationUnknownValue) {
    matches.add(mk(ProgramId.RENT_NEWBORN, RulingStatus.notPossibleInfo, '소득 구간 확인 필요'));
  } else if (a6 == 'inc_over') {
    matches.add(mk(ProgramId.RENT_NEWBORN, RulingStatus.notPossibleDisq, '소득 상한 초과(신생아 특례)'));
  } else if (a6 == 'inc_le200m') {
    if (a8 == null || a8 == conversationUnknownValue) {
      matches.add(mk(ProgramId.RENT_NEWBORN, RulingStatus.notPossibleInfo, '맞벌이 여부 확인 필요(1.3~2.0억 경계)'));
    } else if (a8 == 'no') {
      matches.add(mk(ProgramId.RENT_NEWBORN, RulingStatus.notPossibleDisq, '단일소득 1.3억원 초과'));
    } else {
      if (p2 == 'metro' && p5 == 'dep_gt3') {
        matches.add(mk(ProgramId.RENT_NEWBORN, RulingStatus.notPossibleDisq, '임차보증금 상한 초과(신생아 특례 최대 3억)'));
      } else {
        matches.add(mk(ProgramId.RENT_NEWBORN, RulingStatus.possible, '요건 충족(맞벌이 2억원 이하)'));
      }
    }
  } else {
    if (p2 == 'metro' && p5 == 'dep_gt3') {
      matches.add(mk(ProgramId.RENT_NEWBORN, RulingStatus.notPossibleDisq, '임차보증금 상한 초과(신생아 특례 최대 3억)'));
    } else {
      matches.add(mk(ProgramId.RENT_NEWBORN, RulingStatus.possible, '요건 충족(신생아 특례)'));
    }
  }

  // Damages
  if (disq != null) {
    matches.add(mk(ProgramId.RENT_DAMAGES, RulingStatus.notPossibleDisq, disq));
  } else if (s1 == null || s1 == conversationUnknownValue) {
    matches.add(mk(ProgramId.RENT_DAMAGES, RulingStatus.notPossibleInfo, '전세피해자 해당 여부 확인 필요'));
  } else if (s1 != 'yes') {
    matches.add(mk(ProgramId.RENT_DAMAGES, RulingStatus.notPossibleDisq, '전세피해자 요건 미해당'));
  } else {
    if (p2 == 'metro' && p5 == 'dep_gt3') {
      matches.add(mk(ProgramId.RENT_DAMAGES, RulingStatus.notPossibleInfo, '보증금 경계(3~5억) 정확 금액 확인'));
    } else if ((isMetroCity || isOthers) && p5 == 'dep_gt3') {
      matches.add(mk(ProgramId.RENT_DAMAGES, RulingStatus.notPossibleInfo, '보증금 경계(3~4억) 정확 금액 확인'));
    } else {
      matches.add(mk(ProgramId.RENT_DAMAGES, RulingStatus.possible, '요건 충족(피해자 특례)'));
    }
  }

  return matches;
}

