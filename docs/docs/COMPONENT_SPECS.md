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
- 시그니처(구현 반영):
```dart
// domain 타입 사용(아이콘/색은 UI에서 결정)
import '../../features/conversation/domain/models.dart' as domain;

class ResultCard extends StatefulWidget {
  final domain.RulingStatus status; // possible | notPossibleInfo | notPossibleDisq
  final String tldr;
  final List<domain.Reason> reasons; // Reason(text, kind: met|unmet|unknown|warning)
  final List<String> nextSteps;
  final String lastVerified; // YYYY-MM-DD
  final VoidCallback? onExpand; // (옵션) 사유 영역 확장 알림
  const ResultCard({super.key, required this.status, required this.tldr, required this.reasons, required this.nextSteps, required this.lastVerified, this.onExpand});
}
```
- 동작: 사유/다음 단계는 3개까지만 우선 표시, ‘자세히/접기’ 토글 제공(Stateful 위젯).
- 배지: `lastVerified` 표시, 30일 초과 시 ‘정보 최신성 확인 필요’ 배지 노출.

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

## Micro Components
- ProgressInline
  - 파일: `lib/ui/components/progress_inline.dart`
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
  - 파일: `lib/ui/components/typing_indicator.dart`
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
  - 파일: `lib/ui/components/ad_slot.dart`
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
- ChoiceChip: 선택/비선택 대비 확보, 최소 터치 타겟 48×48dp 보장(패딩/height로 확보)
- 잉크 효과 유지: 버튼/칩 상호작용은 표준 머티리얼 위젯 사용(커스텀 제스처로 대체 지양)

## 리스트/스크롤
- Reasons/NextSteps는 `ListView.separated` 또는 `Column`+`SizedBox(height: spacing)`
- 스크롤 중첩 지양: 스크롤러 안에는 Sliver 계열 또는 단일 스크롤만 유지(shrinkWrap 과도 사용 금지)

## Keys(테스트 식별자)
- ResultCard: `Key('ResultCard.Container')`, `Key('ResultCard.TLDR')`, `Key('ResultCard.Reasons')`, `Key('ResultCard.Next')`
- IntakeQuestion: `Key('Intake.$qid')`, 옵션 `Key('Intake.$qid.$value')`
- ChatBubble: `Key('Chat.$role')`, 인용 `Key('Chat.Citation.$index')`
