import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../components/intake_question.dart';
import '../components/result_card.dart';
import '../../features/conversation/domain/models.dart' as domain;
import '../../features/conversation/domain/constants.dart';
import '../components/chat_bubble.dart';

class DemoGallery extends StatefulWidget {
  const DemoGallery({super.key});

  @override
  State<DemoGallery> createState() => _DemoGalleryState();
}

class _DemoGalleryState extends State<DemoGallery> {
  String? _a1Selected;

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;
    return Scaffold(
      appBar: AppBar(title: const Text('UI Demo')),
      body: ListView(
        padding: EdgeInsets.all(spacing.x4),
        children: [
          _sectionTitle(context, 'IntakeQuestion'),
          IntakeQuestion(
            qid: 'A1',
            label: '현재 세대주이신가요?',
            options: const [
              domain.Choice(value: 'household_head', text: '세대주'),
              domain.Choice(
                value: 'household_head_soon',
                text: '예비 세대주(1개월 내)',
              ),
              domain.Choice(value: 'household_member', text: '세대원'),
            ],
            selected: _a1Selected,
            onChanged: (v) => setState(() => _a1Selected = v),
            helper: '모르면 ‘모름’을 선택하세요.',
          ),
          const SizedBox(height: 12),
          IntakeQuestion(
            qid: 'A2',
            label: '세대원 전원이 무주택인가요?',
            options: const [
              domain.Choice(value: 'yes', text: '예'),
              domain.Choice(value: 'no', text: '아니오'),
            ],
            selected: null,
            onChanged: (_) {},
            helper: '등기/세대원 조회로 확인 가능',
          ),
          const SizedBox(height: 12),
          IntakeQuestion(
            qid: 'P3',
            label: '주택 유형을 선택해 주세요.',
            options: const [
              domain.Choice(value: 'apartment', text: '아파트'),
              domain.Choice(value: 'officetel', text: '오피스텔(주거)'),
              domain.Choice(value: 'multi_family', text: '다가구'),
              domain.Choice(value: 'row_house', text: '연립·다세대'),
              domain.Choice(value: 'studio', text: '원룸'),
              domain.Choice(value: 'other', text: '기타'),
            ],
            selected: null,
            onChanged: (_) {},
          ),
          SizedBox(height: spacing.x6),

          _sectionTitle(context, 'ResultCard — 가능'),
          ResultCard(
            status: domain.RulingStatus.possible,
            tldr:
                '예비판정 결과, 대상 주택은 HUG 전세자금대출 대상에 ‘해당’합니다.\n핵심 요건(무주택·세대주/소득/면적/보증금)을 충족한 것으로 확인되었습니다.\n아래 준비물을 확인해 주세요.',
            reasons: const [
              domain.Reason('무주택·세대주(충족)', domain.ReasonKind.met),
              domain.Reason('소득 형태/구간: 근로 / 5천만원대', domain.ReasonKind.met),
              domain.Reason('주택 유형/면적: 아파트 / 59㎡', domain.ReasonKind.met),
              domain.Reason('지역/보증금: 수도권 / 3억', domain.ReasonKind.met),
              domain.Reason('근저당 있음 → 등기 확인 필요', domain.ReasonKind.warning),
            ],
            nextSteps: const [
              '개인: 신분증, 가족·혼인관계 증명, 소득 증빙',
              '임대: 임대인 등기부등본, 건축물대장(필요 시), 임대차계약서 사본',
              '절차: 은행 상담 예약 → 서류 제출 → 심사 → 보증 승인 → 실행',
            ],
            lastVerified: rulesLastVerifiedYmd,
          ),
          SizedBox(height: spacing.x6),

          _sectionTitle(context, 'ResultCard — 불가(정보 부족)'),
          ResultCard(
            status: domain.RulingStatus.notPossibleInfo,
            tldr: '다음 항목의 정보가 확인되지 않아 판정이 불가합니다.\n해당 정보를 확인 후 다시 진행해 주세요.',
            reasons: const [
              domain.Reason('세대주 여부 확인 필요', domain.ReasonKind.unknown),
              domain.Reason('보증금 구간 확인 필요', domain.ReasonKind.unknown),
              domain.Reason('근저당 유무 확인 필요', domain.ReasonKind.unknown),
            ],
            nextSteps: const [
              '세대주/무주택: 정부24 ‘세대원·주택 보유’ 조회',
              '보증금: 계약서(또는 가계약서) 확인',
              '근저당: 등기부등본(인터넷등기소) 열람',
              '다음 단계: 위 항목 확인 → 재판정 요청',
            ],
            lastVerified: rulesLastVerifiedYmd,
          ),
          SizedBox(height: spacing.x6),

          _sectionTitle(context, 'ResultCard — 불가(결격)'),
          ResultCard(
            status: domain.RulingStatus.notPossibleDisq,
            tldr: '아래 결격 사유로 인해 신청이 불가합니다.',
            reasons: const [
              domain.Reason('무주택 요건 불충족', domain.ReasonKind.unmet),
              domain.Reason('보증금 한도 초과', domain.ReasonKind.unmet),
            ],
            nextSteps: const ['다른 기관/상품 검토 또는 조건 변경(보증금 조정 등)'],
            lastVerified: rulesLastVerifiedYmd,
          ),
          SizedBox(height: spacing.x6),

          _sectionTitle(context, 'ChatBubble'),
          const ChatBubble(
            role: ChatRole.bot,
            content: '요약 → 조건/예외 → 다음 단계',
            citations: [Citation('HUG_internal_policy.md', 'A.1')],
          ),
          const SizedBox(height: 8),
          const ChatBubble(
            role: ChatRole.user,
            content: '오피스텔 59㎡, 수도권, 3억 가능한가요? ',
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(BuildContext context, String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: context.spacing.x2),
      child: Text(text, style: Theme.of(context).textTheme.titleLarge),
    );
  }
}
