
// Copy helpers to centralize TL;DR and next step phrasing.
// Inputs are answer maps; outputs are plain strings for UI.

String buildTldrPossible(Map<String, String> answers) {
  final regionLabel = () {
    switch (answers['P2']) {
      case 'metro':
        return '수도권';
      case 'metrocity':
        return '광역시';
      case 'others':
        return '기타 지역';
      default:
        return '해당 지역';
    }
  }();
  final propertyLabel = () {
    switch (answers['P3']) {
      case 'apartment':
        return '아파트';
      case 'officetel':
        return '오피스텔(주거)';
      case 'multi_family':
        return '다가구';
      case 'row_house':
        return '연립·다세대';
      case 'studio':
        return '원룸';
      default:
        return '주택';
    }
  }();
  final first =
      '예비판정 결과, $regionLabel의 $propertyLabel은(는) HUG 전세자금대출 대상에 ‘해당’합니다.';
  final second =
      '핵심 요건(무주택·세대주/소득/면적/보증금)을 충족한 것으로 확인되었습니다.\n아래 준비물을 확인해 주세요.';
  // Add up to two route hints by priority: damages > newborn > newly > youth
  final hints = <String>[];
  if (answers['S1'] == 'yes') hints.add('전세피해자 특례 경로 안내 대상입니다.');
  if (answers['A5'] == 'yes') hints.add('신생아 특례 경로도 검토 대상입니다.');
  if (answers['A4'] == 'newly7y' || answers['A4'] == 'marry_3m_planned') {
    hints.add('신혼 전용 경로도 검토 대상입니다.');
  }
  if (answers['A3'] == 'y19_34') hints.add('청년 전용 경로도 검토 대상입니다.');
  final extra = hints.isEmpty ? '' : '\n${hints.take(2).join('\n')}';
  return '$first\n$second$extra';
}

List<String> buildNextSteps(Map<String, String> answers) {
  final steps = <String>[];
  // Program-specific additions first
  if (answers['S1'] == 'yes') {
    steps.add('피해자 확인서류/임차권등기(해당 시) 준비');
    steps.add('보증기관(HUG) 상담 경로 확인');
  }
  if (answers['A5'] == 'yes') {
    steps.add('출생증명서 또는 가족관계등록부 준비');
  }
  if (answers['A4'] == 'newly7y' || answers['A4'] == 'marry_3m_planned') {
    steps.add('혼인관계증명서(또는 예정 증빙) 준비');
  }
  // Common checklist
  steps.addAll([
    '신분증·가족/혼인관계·소득 증빙 준비',
    '임대인 등기부등본/건축물대장(필요 시)/계약서 사본',
    '은행 상담 → 심사 → 보증 승인 → 실행',
  ]);
  return steps;
}
