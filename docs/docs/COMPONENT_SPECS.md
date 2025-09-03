# COMPONENT_SPECS — 공용 위젯 사양(Flutter API 초안)
Status: canonical (Component APIs)

마지막 업데이트: 2025-09-02

## 공통 규약
- const 생성자, 필수값은 required, 나머지 기본값 제공
- Theme/Extension 토큰 사용(색/패딩/라운드 등 하드코딩 금지)
- Keys: `Key('WidgetName.Part')` 테스트 키 제공
- A11y: Semantics(label/hint), 색상 외 구분(아이콘/텍스트)

## IntakeQuestion
- 파일: `lib/ui/components/intake_question.dart`
- 시그니처:
```dart
class IntakeQuestion extends StatelessWidget {
  final String qid; // A1..S1
  final String label;
  final List<Choice> options; // text, value, icon?
  final String? selected; // value
  final bool showUnknown; // ‘모름’ 표시
  final ValueChanged<String?> onChanged;
  final String? helper; // 보조문구
  final String? errorText;
  const IntakeQuestion({super.key, required this.qid, required this.label, required this.options, required this.onChanged, this.selected, this.showUnknown=true, this.helper, this.errorText});
}
```
- 상태: error/unknown 시 시각·텍스트로 구분

## ResultCard
- 파일: `lib/ui/components/result_card.dart`
- 시그니처:
```dart
enum RulingStatus { possible, notPossibleInfo, notPossibleDisq }
class ReasonItem { final IconData icon; final String text; final String type; const ReasonItem(this.icon,this.text,this.type); }
class ResultCard extends StatelessWidget {
  final RulingStatus status;
  final String tldr;
  final List<ReasonItem> reasons; // 충족/미충족/확인불가
  final List<String> nextSteps;
  final String lastVerified; // YYYY-MM-DD
  final VoidCallback? onExpand; // 사유 펼치기
  const ResultCard({super.key, required this.status, required this.tldr, required this.reasons, required this.nextSteps, required this.lastVerified, this.onExpand});
}
```
- 배지: `lastVerified`/unknown 뱃지 제공

## ChatBubble
- 파일: `lib/ui/components/chat_bubble.dart`
- 시그니처:
```dart
enum ChatRole { user, bot }
class Citation { final String docId; final String sectionKey; const Citation(this.docId,this.sectionKey); }
class ChatBubble extends StatelessWidget {
  final ChatRole role;
  final String content;
  final List<Citation> citations; // 내부 문서 인용 chips
  const ChatBubble({super.key, required this.role, required this.content, this.citations=const []});
}
```
- A11y: role별 Semantics 분리, 인용은 Chips로 음성 대체 텍스트 포함

## Micro Components (신규 제안)
- ProgressInline
  - 파일: `lib/ui/components/progress_inline.dart`(제안)
  - 시그니처:
```dart
class ProgressInline extends StatelessWidget {
  final int current;
  final int total;
  final bool showBar; // 텍스트만 or LinearProgress 포함
  const ProgressInline({super.key, required this.current, required this.total, this.showBar=false});
}
```
- TypingIndicator
  - 파일: `lib/ui/components/typing_indicator.dart`(제안)
  - 시그니처:
```dart
class TypingIndicator extends StatelessWidget {
  final bool active; // bot 타이핑 중 여부
  const TypingIndicator({super.key, this.active=true});
}
```
- ErrorBubble
  - 파일: `lib/ui/components/error_bubble.dart`(제안)
  - 시그니처:
```dart
class ErrorBubble extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  const ErrorBubble({super.key, required this.message, this.onRetry});
}
```
- SummaryToggle
  - 파일: `lib/ui/components/summary_toggle.dart`(제안)
  - 시그니처:
```dart
class SummaryToggle extends StatelessWidget {
  final bool expanded;
  final ValueChanged<bool> onChanged;
  const SummaryToggle({super.key, required this.expanded, required this.onChanged});
}
```
- AdSlot
  - 파일: `lib/ui/components/ad_slot.dart`(제안)
  - 시그니처:
```dart
enum AdPlacement { resultBottom, chatBottom }
class AdSlot extends StatelessWidget {
  final AdPlacement placement;
  final bool visible; // optional 노출
  const AdSlot({super.key, required this.placement, this.visible=true});
}
```

### Keys(테스트 식별자) — Micro
- ProgressInline: `Key('ProgressInline.Text')`, `Key('ProgressInline.Bar')`
- TypingIndicator: `Key('TypingIndicator')`
- ErrorBubble: `Key('ErrorBubble')`, `Key('ErrorBubble.Retry')`
- SummaryToggle: `Key('SummaryToggle')`
- AdSlot: `Key('AdSlot.Result')`, `Key('AdSlot.Chat')`

## Buttons/Chips
- ElevatedButton/OutlinedButton/TextButton을 사용, 스타일은 Theme에서 일괄 지정
- ChoiceChip: 선택/비선택 대비 확보, 최소 폭 44dp

## 리스트/스크롤
- Reasons/NextSteps는 `ListView.separated` 또는 `Column`+`SizedBox(height: spacing)`

## Keys(테스트 식별자)
- ResultCard: `Key('ResultCard.TLDR')`, `Key('ResultCard.Reasons')`, `Key('ResultCard.Next')`
- IntakeQuestion: `Key('Intake.$qid')`, 옵션 `Key('Intake.$qid.$value')`
- ChatBubble: `Key('Chat.$role')`, 인용 `Key('Chat.Citation.$index')`
