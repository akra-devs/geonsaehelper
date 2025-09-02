import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../components/intake_question.dart';
import '../components/result_card.dart';
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
            label: '현재 무주택이며 세대주이신가요?',
            options: const [
              Choice(value: 'owner', text: '무주택·세대주'),
              Choice(value: 'member', text: '무주택·세대원'),
              Choice(value: 'onehome', text: '1주택'),
            ],
            selected: _a1Selected,
            onChanged: (v) => setState(() => _a1Selected = v),
            helper: '모르면 ‘모름’을 선택하세요.',
          ),
          SizedBox(height: spacing.x6),

          _sectionTitle(context, 'ResultCard — 가능'),
          ResultCard(
            status: RulingStatus.possible,
            tldr: '예비판정 결과, ‘해당’합니다. 체크리스트를 확인하세요.',
            reasons: const [
              ReasonItem(Icons.check_circle, '무주택·세대주(충족)', '충족'),
              ReasonItem(Icons.check_circle, '소득 형태/구간: 근로 / 5천만원대', '충족'),
              ReasonItem(Icons.check_circle, '주택 유형/면적: 아파트 / 59㎡', '충족'),
              ReasonItem(Icons.check_circle, '지역/보증금: 수도권 / 3억', '충족'),
              ReasonItem(Icons.warning_amber, '근저당 있음 → 등기 확인 필요', '주의'),
            ],
            nextSteps: const [
              '신분증·가족/혼인관계·소득 증빙 준비',
              '임대인 등기부등본/계약서 사본',
              '은행 상담 → 심사 → 승인 → 실행',
            ],
            lastVerified: '2025-09-02',
          ),
          SizedBox(height: spacing.x6),

          _sectionTitle(context, 'ResultCard — 불가(정보 부족)'),
          ResultCard(
            status: RulingStatus.notPossibleInfo,
            tldr: '다음 정보가 없어 판정 불가입니다.',
            reasons: const [
              ReasonItem(Icons.help_outline, '세대주 여부 확인 필요', '확인불가'),
              ReasonItem(Icons.help_outline, '보증금 구간 확인 필요', '확인불가'),
              ReasonItem(Icons.help_outline, '근저당 유무 확인 필요', '확인불가'),
            ],
            nextSteps: const [
              '세대주: 정부24 확인',
              '보증금: 계약서 확인',
              '근저당: 등기부등본 열람',
            ],
            lastVerified: '2025-09-02',
          ),
          SizedBox(height: spacing.x6),

          _sectionTitle(context, 'ResultCard — 불가(결격)'),
          ResultCard(
            status: RulingStatus.notPossibleDisq,
            tldr: '아래 결격 사유로 신청이 불가합니다.',
            reasons: const [
              ReasonItem(Icons.cancel, '무주택 요건 불충족', '미충족'),
              ReasonItem(Icons.cancel, '보증금 한도 초과', '미충족'),
            ],
            nextSteps: const [
              '조건 변경(보증금 조정) 또는 타 기관 검토',
            ],
            lastVerified: '2025-09-02',
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

