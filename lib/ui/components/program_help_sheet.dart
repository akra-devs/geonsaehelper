import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../../features/conversation/domain/citation_schema.dart';
import '../../features/conversation/domain/models.dart' as domain;
import '../../features/conversation/domain/rule_citations.dart';

class ProgramHelpSheet extends StatelessWidget {
  final domain.ProgramId programId;
  final String lastVerified;
  const ProgramHelpSheet({
    super.key,
    required this.programId,
    required this.lastVerified,
  });

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;
    final items = _helpItems(programId);
    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          spacing.x4,
          spacing.x3,
          spacing.x4,
          spacing.x4,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  _title(programId),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const Spacer(),
                Text(
                  '마지막 확인일 $lastVerified',
                  style: Theme.of(context).textTheme.labelSmall,
                ),
              ],
            ),
            SizedBox(height: spacing.x3),
            for (final it in items) ...[
              _HelpRow(text: it.text, sources: it.sources),
              SizedBox(height: spacing.x2),
            ],
            SizedBox(height: spacing.x2),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => Navigator.of(context).maybePop(),
                child: const Text('닫기'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _title(domain.ProgramId id) {
    switch (id) {
      case domain.ProgramId.RENT_DAMAGES:
        return '확인 방법 — 특례(피해자)';
      case domain.ProgramId.RENT_NEWBORN:
        return '확인 방법 — 특례(신생아)';
      case domain.ProgramId.RENT_NEWLYWED:
        return '확인 방법 — 신혼';
      case domain.ProgramId.RENT_YOUTH:
        return '확인 방법 — 청년';
      case domain.ProgramId.RENT_STANDARD:
        return '확인 방법 — 표준(버팀목)';
    }
  }

  List<_HelpItem> _helpItems(domain.ProgramId id) {
    switch (id) {
      case domain.ProgramId.RENT_STANDARD:
        return [
          _HelpItem('세대주·무주택 확인(정부24 세대원·주택 보유 조회)', const [
            RuleCitations.household,
          ]),
          _HelpItem('소득 구간 확인(소득금액증명/원천징수)', const [RuleCitations.incomeCap]),
          _HelpItem('주택 유형/면적·지역·보증금 확인(등기/건축물대장/계약서)', const [
            RuleCitations.propertyType,
            RuleCitations.floorArea,
            RuleCitations.depositUpperBound,
          ]),
          _HelpItem('근저당 여부 확인(등기부등본)', const [RuleCitations.encumbrance]),
        ];
      case domain.ProgramId.RENT_NEWLYWED:
        return [
          _HelpItem('혼인 상태 확인(혼인관계증명/예정 증빙)', const [RuleCitations.newlywed]),
          _HelpItem('소득 구간 확인(7,500만원 이하)', const [RuleCitations.newlywed]),
          _HelpItem('지역·보증금 경계(수도권 3~4억) 정확 금액 확인', const [
            RuleCitations.depositUpperBound,
          ]),
        ];
      case domain.ProgramId.RENT_YOUTH:
        return [
          _HelpItem('연령 확인(만 19–34세)', const [RuleCitations.youth]),
          _HelpItem('소득 구간 확인(5,000만원 이하)', const [RuleCitations.youth]),
          _HelpItem('보증금 경계(1.5~2.0억) 정확 금액 확인', const [RuleCitations.youth]),
        ];
      case domain.ProgramId.RENT_NEWBORN:
        return [
          _HelpItem('출산 여부 확인(최근 2년 내/증빙)', const [RuleCitations.newborn]),
          _HelpItem('소득 구간 확인(단일 1.3억/맞벌이 2억)', const [RuleCitations.newborn]),
          _HelpItem('맞벌이 여부 확인(필요 시)', const [RuleCitations.newborn]),
          _HelpItem('수도권 보증금 3억 초과 여부 확인', const [
            RuleCitations.depositUpperBound,
          ]),
        ];
      case domain.ProgramId.RENT_DAMAGES:
        return [
          _HelpItem('전세피해자 해당 여부 확인(특별법 요건)', const [RuleCitations.damages]),
          _HelpItem('수도권 보증금 3~5억/비수도권 3~4억 경계 확인', const [
            RuleCitations.depositUpperBound,
          ]),
          _HelpItem('임차권등기 설정 여부(해당 시) 확인', const [RuleCitations.damages]),
        ];
    }
  }
}

class _HelpItem {
  final String text;
  final List<domain.SourceRef> sources;
  const _HelpItem(this.text, this.sources);
}

class _HelpRow extends StatelessWidget {
  final String text;
  final List<domain.SourceRef> sources;
  const _HelpRow({required this.text, required this.sources});
  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(text, style: Theme.of(context).textTheme.bodyMedium),
        SizedBox(height: spacing.x1),
        Wrap(
          spacing: spacing.x1,
          children:
              sources
                  .map(
                    (s) => Chip(
                      visualDensity: const VisualDensity(
                        horizontal: -2,
                        vertical: -2,
                      ),
                      label: Text(
                        '${CitationSchema.displayLabel(s.docId)} · ${s.sectionKey}',
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                    ),
                  )
                  .toList(),
        ),
      ],
    );
  }
}
