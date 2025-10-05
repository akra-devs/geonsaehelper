import 'package:flutter/material.dart';
import '../../../ui/theme/app_theme.dart';

class FAQPage extends StatelessWidget {
  const FAQPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('자주 묻는 질문')),
      body: _CenteredBody(
        child: ListView(
          padding: EdgeInsets.all(context.spacing.x4),
          children: const [
            _FAQItem(
              question: '예비 판정 결과는 확정인가요?',
              answer:
                  '아니요. 본 서비스의 판정 결과는 참고용 예비 판정입니다. 최종 승인은 HUG 및 금융기관의 공식 심사를 통해 결정됩니다.',
            ),
            _FAQItem(
              question: '어떤 대출 상품을 지원하나요?',
              answer:
                  '현재 HUG 전세자금대출 상품(버팀목 전세자금대출, 신혼부부 전세자금대출, 청년 전용 전세자금대출, 신생아 특례 대출 등)을 지원합니다.',
            ),
            _FAQItem(
              question: '정보는 어디에 저장되나요?',
              answer:
                  '모든 판정 결과와 응답 정보는 사용자의 기기에만 저장됩니다(로컬 스토리지). 외부 서버로 전송되지 않으며, 언제든지 히스토리 탭에서 삭제할 수 있습니다.',
            ),
            _FAQItem(
              question: '규정이 변경되면 어떻게 되나요?',
              answer:
                  '각 판정 결과에는 "마지막 확인일"이 표시됩니다. 30일이 경과한 경우 최신 규정을 확인하라는 안내가 표시됩니다. 중요한 결정을 내리기 전에 HUG 공식 사이트에서 최신 규정을 확인하시기 바랍니다.',
            ),
            _FAQItem(
              question: 'AI 상담은 어떻게 작동하나요?',
              answer:
                  'AI 상담은 내부 문서(HUG 정책 문서)를 기반으로 자동 응답을 제공합니다. 외부 검색이나 추측은 하지 않으며, 문서에 없는 정보는 "확인불가"로 응답합니다.',
            ),
            _FAQItem(
              question: '판정 결과가 "불가(정보 부족)"으로 나왔어요.',
              answer:
                  '응답 중 "모름"을 선택한 항목이 있거나, 입력한 정보가 경계값(예: 소득 구간 경계)에 해당하여 정확한 판정이 어려운 경우입니다. 해당 항목의 정확한 정보를 확인 후 다시 진행해 주세요.',
            ),
            _FAQItem(
              question: '히스토리를 삭제하고 싶어요.',
              answer:
                  '히스토리 탭에서 개별 항목의 삭제 버튼을 누르거나, 상단의 전체 삭제 버튼을 사용할 수 있습니다. 삭제된 정보는 복구할 수 없습니다.',
            ),
            _FAQItem(
              question: '실제 대출 신청은 어떻게 하나요?',
              answer:
                  '본 서비스는 예비 판정만 제공하며, 실제 대출 신청은 HUG 또는 금융기관을 통해 진행해야 합니다. HUG 공식 사이트(www.hug.or.kr)에서 자세한 신청 방법을 확인하실 수 있습니다.',
            ),
            _FAQItem(
              question: '문의나 제안은 어디로 보내나요?',
              answer:
                  '설정 탭의 "피드백 보내기"를 통해 이메일로 문의하실 수 있습니다. 버그 신고, 기능 제안, 문의 사항 등을 보내주시면 검토 후 답변드리겠습니다.',
            ),
          ],
        ),
      ),
    );
  }
}

class _FAQItem extends StatelessWidget {
  final String question;
  final String answer;

  const _FAQItem({
    required this.question,
    required this.answer,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final spacing = context.spacing;

    return Card(
      margin: EdgeInsets.only(bottom: spacing.x3),
      child: ExpansionTile(
        title: Text(
          question,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        children: [
          Padding(
            padding: EdgeInsets.all(spacing.x4),
            child: Text(
              answer,
              style: theme.textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
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
