import 'package:flutter/material.dart';
import '../../../ui/theme/app_theme.dart';

enum LegalNoticeType { disclaimer, privacy, terms }

class LegalNoticePage extends StatelessWidget {
  final LegalNoticeType type;

  const LegalNoticePage({super.key, required this.type});

  @override
  Widget build(BuildContext context) {
    final title = switch (type) {
      LegalNoticeType.disclaimer => '면책조항',
      LegalNoticeType.privacy => '개인정보 처리방침',
      LegalNoticeType.terms => '이용약관',
    };

    final content = switch (type) {
      LegalNoticeType.disclaimer => _disclaimerContent,
      LegalNoticeType.privacy => _privacyContent,
      LegalNoticeType.terms => _termsContent,
    };

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: _CenteredBody(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(context.spacing.x4),
          child: Text(
            content,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      ),
    );
  }

  static const String _disclaimerContent = '''
면책조항

1. 서비스 성격
본 서비스는 HUG(한국주택금융공사) 전세자금대출 자격에 대한 예비 판정을 제공하는 서비스입니다. 본 서비스의 판정 결과는 참고용이며, 법적 자문이나 최종 승인을 의미하지 않습니다.

2. 최종 승인
실제 대출 승인 여부는 HUG 및 금융기관의 공식 심사 결과에 따라 결정됩니다. 본 서비스의 예비 판정 결과와 실제 심사 결과가 다를 수 있습니다.

3. 정보의 정확성
본 서비스는 공개된 HUG 규정을 기반으로 작성되었으나, 규정 변경, 해석 차이, 개별 사례의 특수성 등으로 인해 실제와 다를 수 있습니다.

4. 규정 최신성
본 서비스에 표시된 "마지막 확인일"은 규정 검토 시점을 나타냅니다. 최신 규정은 HUG 공식 사이트에서 확인하시기 바랍니다.

5. 책임의 제한
본 서비스 이용으로 인해 발생하는 어떠한 손해에 대해서도 당사는 책임을 지지 않습니다. 중요한 결정을 내리기 전에 반드시 HUG 및 금융기관과 직접 상담하시기 바랍니다.

6. AI 상담
AI 상담 기능은 내부 문서를 기반으로 한 자동 응답 서비스입니다. AI의 답변이 부정확하거나 불완전할 수 있으며, 이를 최종 판단 근거로 사용해서는 안 됩니다.

마지막 업데이트: 2025-10-05
''';

  static const String _privacyContent = '''
개인정보 처리방침

전세자금대출 도우미(이하 "본 서비스")는 사용자의 개인정보를 중요하게 생각하며, 다음과 같이 처리합니다.

1. 수집하는 정보
본 서비스는 다음 정보를 수집합니다:
- 예비 판정을 위한 질문 응답 (세대주 여부, 소득 구간, 주택 정보 등)
- 앱 사용 기록 (방문 시간, 기능 사용 등)
- 기기 정보 (OS 버전, 앱 버전)

2. 정보의 사용 목적
수집된 정보는 다음 용도로만 사용됩니다:
- 전세자금대출 자격 예비 판정 제공
- 서비스 개선 및 품질 향상
- 통계 분석

3. 정보의 보관
- 판정 결과는 기기 내부에만 저장됩니다 (로컬 스토리지)
- 외부 서버로 개인 식별 정보를 전송하지 않습니다
- 사용자가 직접 삭제할 수 있습니다 (히스토리 삭제 기능)

4. 제3자 제공
본 서비스는 사용자의 개인정보를 제3자에게 제공하지 않습니다.

5. 정보 주체의 권리
사용자는 언제든지:
- 저장된 정보를 확인할 수 있습니다 (히스토리 탭)
- 저장된 정보를 삭제할 수 있습니다 (히스토리 삭제)
- 앱 삭제 시 모든 정보가 함께 삭제됩니다

6. 쿠키 및 추적 기술
본 서비스는 로컬 스토리지를 사용하여 사용자 설정 및 히스토리를 저장합니다.

7. 문의
개인정보 처리에 관한 문의: chem.en.9273@gmail.com

마지막 업데이트: 2025-10-05
''';

  static const String _termsContent = '''
이용약관

제1조 (목적)
본 약관은 전세자금대출 도우미(이하 "서비스")의 이용과 관련하여 서비스 제공자와 이용자 간의 권리, 의무 및 책임 사항을 규정함을 목적으로 합니다.

제2조 (정의)
1. "서비스"란 HUG 전세자금대출 자격 예비 판정 및 AI 상담을 제공하는 모바일/웹 애플리케이션을 의미합니다.
2. "이용자"란 본 약관에 따라 서비스를 이용하는 모든 사용자를 의미합니다.

제3조 (서비스의 제공)
1. 서비스는 다음 기능을 제공합니다:
   - 전세자금대출 자격 예비 판정
   - AI 기반 상담
   - 판정 히스토리 관리
2. 서비스는 무료로 제공되며, 광고가 포함될 수 있습니다.

제4조 (서비스의 한계)
1. 본 서비스의 판정 결과는 참고용이며, 법적 효력이 없습니다.
2. 최종 승인은 HUG 및 금융기관의 공식 심사를 통해 결정됩니다.
3. 서비스 제공자는 판정 결과의 정확성을 보장하지 않습니다.

제5조 (이용자의 의무)
1. 이용자는 정확한 정보를 입력해야 합니다.
2. 이용자는 서비스를 불법적 목적으로 사용해서는 안 됩니다.
3. 이용자는 서비스의 보안을 위협하는 행위를 해서는 안 됩니다.

제6조 (서비스의 중단)
서비스 제공자는 다음의 경우 서비스를 일시적으로 중단할 수 있습니다:
1. 시스템 유지보수
2. 기술적 문제 발생
3. 불가항력적 사유

제7조 (면책)
1. 서비스 제공자는 천재지변, 시스템 장애 등 불가항력으로 인한 서비스 중단에 대해 책임지지 않습니다.
2. 서비스 이용으로 인한 이용자의 손해에 대해 책임지지 않습니다.

제8조 (분쟁 해결)
본 약관과 관련된 분쟁은 대한민국 법률에 따라 해결됩니다.

부칙
본 약관은 2025년 10월 5일부터 시행됩니다.
''';
}

class _CenteredBody extends StatelessWidget {
  final Widget child;
  const _CenteredBody({required this.child});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 820),
        child: child,
      ),
    );
  }
}
