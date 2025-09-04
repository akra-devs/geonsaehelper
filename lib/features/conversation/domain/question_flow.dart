import 'models.dart';

class QuestionDef {
  final String qid;
  final String label;
  final List<Choice> choices;
  const QuestionDef({required this.qid, required this.label, required this.choices});
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

// Intake flow (A1..S1)
const List<QuestionDef> intakeFlow = [
  QuestionDef(
    qid: 'A1',
    label: '현재 무주택이며 세대주이신가요?',
    choices: [
      Choice(value: 'owner', text: '무주택·세대주'),
      Choice(value: 'member', text: '무주택·세대원'),
      Choice(value: 'onehome', text: '1주택'),
    ],
  ),
  QuestionDef(
    qid: 'A2',
    label: '혼인/부양 상태를 선택해 주세요.',
    choices: [
      Choice(value: 'single', text: '미혼'),
      Choice(value: 'newly', text: '신혼(혼인 7년 이내)'),
      Choice(value: 'children', text: '자녀 있음'),
    ],
  ),
  QuestionDef(
    qid: 'A3',
    label: '소득 형태를 선택해 주세요.',
    choices: [
      Choice(value: 'work', text: '근로'),
      Choice(value: 'biz', text: '사업'),
      Choice(value: 'etc', text: '기타'),
    ],
  ),
  QuestionDef(
    qid: 'A4',
    label: '연간 소득 구간을 선택해 주세요.',
    choices: [
      Choice(value: 'inc1', text: '내부 구간 1'),
      Choice(value: 'inc2', text: '내부 구간 2'),
      Choice(value: 'inc3', text: '내부 구간 3'),
      Choice(value: 'inc4', text: '내부 구간 4'),
    ],
  ),
  QuestionDef(
    qid: 'A5',
    label: '현재 재직/사업 기간은 얼마나 되나요?',
    choices: [
      Choice(value: 'm0_6', text: '0~6개월'),
      Choice(value: 'm7_12', text: '7~12개월'),
      Choice(value: 'm13_24', text: '13~24개월'),
      Choice(value: 'm24p', text: '24개월 이상'),
    ],
  ),
  QuestionDef(
    qid: 'A6',
    label: '보유 중인 대출/보증이 있나요?',
    choices: [
      Choice(value: 'jeonse', text: '전세보증'),
      Choice(value: 'mtg', text: '주담대'),
      Choice(value: 'credit', text: '신용'),
      Choice(value: 'none', text: '없음'),
    ],
  ),
  QuestionDef(
    qid: 'A7',
    label: '최근 연체·회생·파산·면책 이력이 있나요?',
    choices: [
      Choice(value: 'credit_ok', text: '문제 없음'),
      Choice(value: 'credit_recent', text: '최근 연체'),
      Choice(value: 'credit_severe', text: '장기연체/회생/파산/면책'),
    ],
  ),
  QuestionDef(
    qid: 'P1',
    label: '주택 유형을 선택해 주세요.',
    choices: [
      Choice(value: 'apt', text: '아파트'),
      Choice(value: 'officetel', text: '오피스텔'),
      Choice(value: 'multifam', text: '다가구'),
      Choice(value: 'villa', text: '연립·다세대'),
      Choice(value: 'one_room', text: '원룸'),
      Choice(value: 'etc', text: '기타'),
    ],
  ),
  QuestionDef(
    qid: 'P2',
    label: '전용면적 범위를 선택해 주세요.',
    choices: [
      Choice(value: 'fa_le40', text: '≤ 40㎡'),
      Choice(value: 'fa_41_60', text: '41–60㎡'),
      Choice(value: 'fa_61_85', text: '61–85㎡'),
      Choice(value: 'fa_gt85', text: '85㎡ 초과'),
    ],
  ),
  QuestionDef(
    qid: 'P3',
    label: '지역을 선택해 주세요.',
    choices: [
      Choice(value: 'metro', text: '수도권'),
      Choice(value: 'metrocity', text: '광역시'),
      Choice(value: 'other', text: '기타'),
    ],
  ),
  QuestionDef(
    qid: 'P4',
    label: '전세보증금(또는 보증금+월세)을 알려주세요.',
    choices: [
      Choice(value: 'dep_le1', text: '1억 이하'),
      Choice(value: 'dep_1_2', text: '1~2억'),
      Choice(value: 'dep_2_3', text: '2~3억'),
      Choice(value: 'dep_gt3', text: '3억 이상'),
    ],
  ),
  QuestionDef(
    qid: 'P5',
    label: '계약 상태를 알려주세요.',
    choices: [
      Choice(value: 'pre', text: '계약 전'),
      Choice(value: 'precontract', text: '가계약'),
      Choice(value: 'contract', text: '본계약'),
    ],
  ),
  QuestionDef(
    qid: 'P6',
    label: '입주 예정 시점을 알려주세요.',
    choices: [
      Choice(value: 'w1', text: '1주 내'),
      Choice(value: 'w2_4', text: '2~4주'),
      Choice(value: 'm1_3', text: '1~3개월'),
      Choice(value: 'm3p', text: '3개월+'),
    ],
  ),
  QuestionDef(
    qid: 'P7',
    label: '등기상 근저당이 있나요?',
    choices: [
      Choice(value: 'encumbrance_yes', text: '있음'),
      Choice(value: 'encumbrance_no', text: '없음'),
    ],
  ),
  QuestionDef(
    qid: 'S1',
    label: '우대/특례에 해당되나요?',
    choices: [
      Choice(value: 'youth', text: '청년'),
      Choice(value: 'newly', text: '신혼'),
      Choice(value: 'multi', text: '다자녀'),
      Choice(value: 'lowinc', text: '저소득'),
      Choice(value: 'none', text: '해당 없음'),
    ],
  ),
];

