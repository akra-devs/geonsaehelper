import 'models.dart';

class QuestionDef {
  final String qid;
  final String label;
  final List<Choice> choices;
  const QuestionDef({
    required this.qid,
    required this.label,
    required this.choices,
  });
}

// Quick survey flow (QS1..)
const List<QuestionDef> surveyFlow = [
  QuestionDef(
    qid: 'QS1',
    label: '언제까지 준비가 필요하신가요?',
    choices: [
      Choice(value: 'soon', text: '2주 이내'),
      Choice(value: 'month1', text: '1개월 이내'),
      Choice(value: 'flex', text: '유연함'),
    ],
  ),
  QuestionDef(
    qid: 'QS2',
    label: '어떤 정보가 가장 궁금하신가요?',
    choices: [
      Choice(value: 'elig', text: '자격'),
      Choice(value: 'limit', text: '한도'),
      Choice(value: 'docs', text: '서류/절차'),
    ],
  ),
  QuestionDef(
    qid: 'QS3',
    label: '주 관심 지역을 선택해 주세요.',
    choices: [
      Choice(value: 'metro', text: '수도권'),
      Choice(value: 'metrocity', text: '광역시'),
      Choice(value: 'other', text: '기타'),
    ],
  ),
];

// Intake flow (A1..S1) — HUG 기반 12문(모두 '모름' 제공)
const List<QuestionDef> intakeFlow = [
  // A1. 세대주 상태
  QuestionDef(
    qid: 'A1',
    label: '현재 세대주이신가요?',
    choices: [
      Choice(value: 'household_head', text: '세대주'),
      Choice(value: 'household_head_soon', text: '예비 세대주(1개월 내)'),
      Choice(value: 'household_member', text: '세대원'),
    ],
  ),
  // A2. 세대원 전원 무주택 여부
  QuestionDef(
    qid: 'A2',
    label: '세대원 전원이 무주택인가요?',
    choices: [
      Choice(value: 'yes', text: '예'),
      Choice(value: 'no', text: '아니오'),
    ],
  ),
  // A3. 나이대(성년/청년 분기)
  QuestionDef(
    qid: 'A3',
    label: '나이를 선택해 주세요(만 나이).',
    choices: [
      Choice(value: 'under19', text: '만 19세 미만'),
      Choice(value: 'y19_34', text: '만 19–34세'),
      Choice(value: 'y35p', text: '만 35세 이상'),
    ],
  ),
  // A4. 혼인 상태(신혼 라우팅)
  QuestionDef(
    qid: 'A4',
    label: '혼인 상태를 알려주세요.',
    choices: [
      Choice(value: 'newly7y', text: '신혼(혼인 7년 이내)'),
      Choice(value: 'marry_3m_planned', text: '3개월 내 결혼 예정'),
      Choice(value: 'none', text: '해당 없음'),
    ],
  ),
  // A5. 출산(신생아 특례)
  QuestionDef(
    qid: 'A5',
    label: '최근 2년 내 출산하셨나요?(’23.1.1. 이후)',
    choices: [
      Choice(value: 'yes', text: '예'),
      Choice(value: 'no', text: '아니오'),
    ],
  ),
  // A8. 맞벌이 여부(신생아 특례 소득 한도 구분)
  QuestionDef(
    qid: 'A8',
    label: '맞벌이이신가요?',
    choices: [
      Choice(value: 'yes', text: '예'),
      Choice(value: 'no', text: '아니오'),
    ],
  ),
  // A6. 부부합산 연소득 구간
  QuestionDef(
    qid: 'A6',
    label: '부부합산 연소득 구간을 선택해 주세요.',
    choices: [
      Choice(value: 'inc_le50m', text: '5천만원 이하'),
      Choice(value: 'inc_le60m', text: '6천만원 이하'),
      Choice(value: 'inc_le75m', text: '7천5백만원 이하'),
      Choice(value: 'inc_le130m', text: '1억3천만원 이하'),
      Choice(value: 'inc_over', text: '초과'),
    ],
  ),
  // A9. 자녀 수(표준 2자녀 이상 우대 소득 상향 6천 적용)
  QuestionDef(
    qid: 'A9',
    label: '자녀 수를 알려주세요.',
    choices: [
      Choice(value: 'child0', text: '없음'),
      Choice(value: 'child1', text: '1명'),
      Choice(value: 'child2', text: '2명'),
      Choice(value: 'child3p', text: '3명 이상'),
    ],
  ),
  // A10. 우대 사유(표준 6천 상향 적용 대상)
  QuestionDef(
    qid: 'A10',
    label: '우대 사유가 있나요?',
    choices: [
      Choice(value: 'none', text: '해당 없음'),
      Choice(value: 'innov', text: '혁신도시 이전 공공기관 종사자'),
      Choice(value: 'redevelop', text: '타 지역 이주 재개발 구역내 세입자'),
      Choice(value: 'risky', text: '위험건축물 이주지원 대상자'),
    ],
  ),
  // A7. 합산 순자산
  QuestionDef(
    qid: 'A7',
    label: '합산 순자산 구간을 선택해 주세요.',
    choices: [
      Choice(value: 'asset_le337', text: '3.37억원 이하'),
      Choice(value: 'asset_le488', text: '4.88억원 이하'),
      Choice(value: 'asset_over', text: '초과'),
    ],
  ),
  // C1. 결격/제한(신용·공공임대 등)
  QuestionDef(
    qid: 'C1',
    label: '최근 장기연체/회생/파산/면책 또는 공공임대 거주 중인가요?',
    choices: [
      Choice(value: 'none', text: '해당 없음'),
      Choice(value: 'has', text: '있음'),
    ],
  ),
  // P1. 계약 및 5% 지급
  QuestionDef(
    qid: 'P1',
    label: '임대차계약 체결 및 계약금(5%) 지급을 완료했나요?',
    choices: [
      Choice(value: 'yes', text: '예'),
      Choice(value: 'no', text: '아니오'),
    ],
  ),
  // P2. 지역
  QuestionDef(
    qid: 'P2',
    label: '지역을 선택해 주세요.',
    choices: [
      Choice(value: 'metro', text: '수도권'),
      Choice(value: 'metrocity', text: '광역시'),
      Choice(value: 'others', text: '그 외'),
    ],
  ),
  // P3. 주택 유형
  QuestionDef(
    qid: 'P3',
    label: '주택 유형을 선택해 주세요.',
    choices: [
      Choice(value: 'apartment', text: '아파트'),
      Choice(value: 'officetel', text: '오피스텔(주거)'),
      Choice(value: 'multi_family', text: '다가구'),
      Choice(value: 'row_house', text: '연립·다세대'),
      Choice(value: 'studio', text: '원룸'),
      Choice(value: 'other', text: '기타'),
    ],
  ),
  // P4. 전용면적
  QuestionDef(
    qid: 'P4',
    label: '전용면적을 선택해 주세요.',
    choices: [
      Choice(value: 'fa_le60', text: '60㎡ 이하'),
      Choice(value: 'fa_61_85', text: '61–85㎡'),
      Choice(value: 'fa_86_100', text: '86–100㎡'),
      Choice(value: 'fa_gt100', text: '100㎡ 초과'),
    ],
  ),
  // P4a. 읍·면 소재 여부(면적 예외)
  QuestionDef(
    qid: 'P4a',
    label: '도시지역이 아닌 읍·면 소재인가요?',
    choices: [
      Choice(value: 'yes', text: '예'),
      Choice(value: 'no', text: '아니오'),
    ],
  ),
  // P5. 임차보증금 구간
  QuestionDef(
    qid: 'P5',
    label: '임차보증금(전세금) 구간을 선택해 주세요.',
    choices: [
      Choice(value: 'dep_le2', text: '2억원 이하'),
      Choice(value: 'dep_le3', text: '3억원 이하'),
      Choice(value: 'dep_gt3', text: '3억원 초과'),
    ],
  ),
  // P7. 등기 근저당(경고/주의)
  QuestionDef(
    qid: 'P7',
    label: '등기부등본상 근저당이 있나요?',
    choices: [
      Choice(value: 'yes', text: '있음'),
      Choice(value: 'no', text: '없음'),
    ],
  ),
  // S1. 전세피해자 여부(간단 라우팅용)
  QuestionDef(
    qid: 'S1',
    label: '전세사기/피해자 특별법 대상에 해당되시나요?',
    choices: [
      Choice(value: 'yes', text: '예'),
      Choice(value: 'no', text: '아니오'),
    ],
  ),
  // S1a. 임차권등기 설정 여부(피해자 대환)
  QuestionDef(
    qid: 'S1a',
    label: '임차권등기를 설정하셨나요?',
    choices: [
      Choice(value: 'yes', text: '예'),
      Choice(value: 'no', text: '아니오'),
    ],
  ),
];
