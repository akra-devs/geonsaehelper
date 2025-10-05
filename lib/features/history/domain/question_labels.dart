/// Labels and value mappings for questions and answers
class QuestionLabels {
  // Question ID to Korean label mapping
  static const Map<String, String> questionLabels = {
    // Survey questions
    'QS1': '준비 기간',
    'QS2': '관심 정보',
    'QS3': '관심 지역',

    // Applicant info
    'A1': '세대주 상태',
    'A2': '무주택 여부',
    'A3': '나이(만)',
    'A4': '혼인 상태',
    'A5': '최근 2년 내 출산',
    'A6': '연소득',
    'A7': '순자산',
    'A8': '맞벌이 여부',
    'A9': '자녀 수',
    'A10': '우대 사유',

    // Credit/constraints
    'C1': '결격 사항',
    'C2': '기존 대출',

    // Property info
    'P2': '지역',
    'P3': '주택 유형',
    'P4': '전용면적',
    'P4a': '읍·면 소재 여부',
    'P5': '임차보증금',
    'P6': '계약 상태',
    'P7': '등기 근저당',

    // Special eligibility
    'S1': '전세피해자 여부',
    'S1a': '임차권등기 설정',
  };

  // Answer value to Korean text mapping
  static const Map<String, String> answerValues = {
    // Common
    'yes': '예',
    'no': '아니오',
    'unknown': '모름',
    'none': '해당 없음',

    // QS1 - Timeline
    'soon': '2주 이내',
    'month1': '1개월 이내',
    'flex': '유연함',

    // QS2 - Interest
    'elig': '자격',
    'limit': '한도',
    'docs': '서류/절차',

    // QS3 - Region interest / P2 - Property region
    'metro': '수도권',
    'metrocity': '광역시',
    'other': '기타',
    'others': '그 외',

    // A1 - Household head
    'household_head': '세대주',
    'household_head_soon': '예비 세대주(1개월 내)',
    'household_member': '세대원',

    // A3 - Age
    'under19': '만 19세 미만',
    'y19_34': '만 19–34세',
    'y35p': '만 35세 이상',

    // A4 - Marriage
    'newly7y': '신혼(혼인 7년 이내)',
    'marry_3m_planned': '3개월 내 결혼 예정',

    // A6 - Income
    'inc_le50m': '5천만원 이하',
    'inc_le60m': '6천만원 이하',
    'inc_le75m': '7천5백만원 이하',
    'inc_le130m': '1억3천만원 이하',
    'inc_le200m': '2억원 이하',
    'inc_over': '초과',

    // A7 - Assets
    'asset_le337': '3.37억원 이하',
    'asset_le488': '4.88억원 이하',
    'asset_over': '초과',

    // A9 - Children
    'child0': '없음',
    'child1': '1명',
    'child2': '2명',
    'child3p': '3명 이상',

    // A10 - Special eligibility
    'innov': '혁신도시 이전 공공기관 종사자',
    'redevelop': '타 지역 이주 재개발 구역내 세입자',
    'risky': '위험건축물 이주지원 대상자',

    // C1 - Disqualifications
    'has': '있음',

    // C2 - Existing loans
    'fund_rent': '기금 전세자금대출',
    'bank_rent': '은행 전세자금대출',
    'mortgage': '주택담보대출',

    // P3 - Property type
    'apartment': '아파트',
    'officetel': '오피스텔(주거)',
    'multi_family': '다가구',
    'row_house': '연립·다세대',
    'studio': '원룸',

    // P4 - Area
    'fa_le60': '60㎡ 이하',
    'fa_61_85': '61–85㎡',
    'fa_86_100': '86–100㎡',
    'fa_gt100': '100㎡ 초과',

    // P5 - Deposit
    'dep_le2': '2억원 이하',
    'dep_le3': '3억원 이하',
    'dep_gt3': '3억원 초과',

    // P6 - Contract status
    'complete': '계약 완료',
    'pending': '계약 전',
  };

  /// Get Korean label for question ID
  static String getQuestionLabel(String qid) {
    return questionLabels[qid] ?? qid;
  }

  /// Get Korean text for answer value
  static String getAnswerText(String value) {
    return answerValues[value] ?? value;
  }
}
