# SCREEN_SPECS — 화면별 컴포넌트 트리/프롭/상태 사양
Status: canonical (Screen Specs)

마지막 업데이트: 2025-09-02

## 문서 연관성
- 상위 가이드: UI_UX_GUIDE.md (UI 원칙/계약/A11y/측정 총괄)
- 화면 기획: APP_SCREEN_PLAN.md (플로우/상태/이벤트/API 훅)
- 청사진/토큰: UI_BLUEPRINT.yaml, DESIGN_TOKENS.yaml
- 컴포넌트: COMPONENT_SPECS.md (IntakeQuestion/ResultCard/ChatBubble), 본 문서의 서브컴포넌트
- 카피: COPY_GUIDE.md, RESULT_CARD_COPY.md
- 인덱스: DOCS_INDEX.md

---

## Shell (하단 탭)

### 구조
- `AppShell`
  - `NavigationBar`(tabs: 시작/체크리스트/히스토리/설정)
  - `IndexedStack`(각 탭 상태 유지)

### 이벤트(제안)
- `tab_change{tab}`

---

## Conversation (시작/대화)

### 컴포넌트 트리
- `Scaffold`
  - `AppBar(title: '대화형 예비판정', actions: [History, Help])`
  - `ListView`
    - `ChatBubble(role: bot)` — 인사/안내
    - 반복 블록(아래 중 하나 또는 다수 순서대로)
      - `ProgressInline(current, total)`
      - `IntakeQuestion(qid, label, options[], selected?, showUnknown, helper?, errorText?)`
      - `TypingIndicator`(bot 대기)
      - `ChatBubble(role: user)`
      - `ChatBubble(role: bot, citations[])`
      - `ResultCard(status, tldr, reasons[], nextSteps[], lastVerified)`
      - `AdSlot(placement: result)`
  - `Composer(enabled, suggestions[])`

### 주요 프롭(요약)
- `ChatBubble`
  - role: `user|bot`
  - content: `String`
  - citations: `{docId, sectionKey}[]` (bot일 때만)
- `IntakeQuestion`
  - qid: `A1..A7|P1..P7|S1`
  - label, options[], selected?, showUnknown=true, helper?, errorText?
- `ResultCard`
  - status: `possible|notPossibleInfo|notPossibleDisq`
  - tldr, reasons[{icon,text,type}], nextSteps[], lastVerified(YYYY-MM-DD)
- `ProgressInline`
  - current: number, total: number
- `Composer`
  - enabled: bool, suggestions: string[]

### 상태/변형
- 인테이크 진행: `Composer.enabled=false`, `ProgressInline` 표시, `IntakeQuestion` 노출
- 결과 이후: `Composer.enabled=true`, 추천 질문 칩 노출
- 로딩: `TypingIndicator`(bot), 긴 답변 `SummaryToggle`(TL;DR 먼저 보기)
- 에러: `ErrorBubble`(bot) + `RetryButton`
 - 접근성: 모든 터치 타겟 48×48dp 이상, 칩/버튼은 머티리얼 표준 컴포넌트 사용(잉크 효과 보존)

### 접근성
- Semantics: ChatBubble(role 라벨), ChoiceChip 라벨/포커스 이동, 배지(마지막 확인일) 읽기
- 키보드 포커스 순서: 질문→옵션 칩→다음 요소
 - 방향성: 여백/정렬은 EdgeInsetsDirectional/alignmentDirectional 사용

## 리스트/스크롤 가이드
- 중첩 스크롤 지양. 필요 시 `CustomScrollView` + Sliver 조합 사용
- 긴 리스트는 `ListView.builder`/`SliverList` 사용, `shrinkWrap` 과도 사용 금지

### 이벤트 매핑
- `intake_start`, `intake_answer{qid, is_unknown}`, `intake_complete{count, has_unknown, status}`
- `ruling_shown{status}`, `reasons_expand`, `next_step_click{action}`
- `qna_ask{topic}`, `qna_answer{has_disclaimer,last_verified}`

---

## Home (홈)

### 컴포넌트 트리
- `Scaffold`
  - `AppBar(title: '전세자금대출 도우미', actions: [Help])`
  - `ListView`
    - `SearchBar(placeholder: '질문을 입력하세요…')`
    - `Grid(cards[eligibility|limit|docs|process])`
    - `Banner(optional: policy_feed)`

### 이벤트
- `home_open`, `home_card_click{card_id}`

---

## DocsChecklist (체크리스트)

### 컴포넌트 트리
- `Scaffold`
  - `AppBar(title: '서류 체크리스트')`
  - `ListView`
    - Section `개인`: 체크 아이템들(완료 토글)
    - Section `임대`: 체크 아이템들
    - Section `절차`: 단계 가이드
  - `BottomBar(actions: 공유, 저장)`

### 프롭/상태
- Item: {id, label, done}, 섹션별 그룹
- 저장: 로컬 우선, 향후 동기화 옵션

### 이벤트
- `next_step_click{action: checklist}`, `checklist_mark{id, done}`

---

## History (히스토리)

### 컴포넌트 트리
- `Scaffold`
  - `AppBar(title: '히스토리', actions: [Filter, Sort])`
  - `ListView`
    - `HistoryCard(status, tldr, date, lastVerified)` 반복

### 이벤트
- `history_open`, `history_item_open{id}`

---

## Settings (설정)

### 컴포넌트 트리
- `Scaffold`
  - `AppBar(title: '설정')`
  - `ListView`
    - `ThemeSelector(mode: system|light|dark)`
    - `DataOptions(localOnly: bool)`
    - `LegalSection(disclaimers)`

### 이벤트
- `settings_open`, `theme_change{mode}`

---

## 마이크로 컴포넌트(제안)
- `ProgressInline(current, total)` — 텍스트/바 2가지 변형
- `TypingIndicator()` — bot 타자 애니메이션(3점 점멸)
- `ErrorBubble(message, onRetry)` — 네트워크/서버 에러
- `SummaryToggle(expanded)` — 긴 답변 요약 토글
- `AdSlot(placement)` — 결과/챗 하단 배치, ‘광고’ 라벨 필수

## 애니메이션/전환(가이드)
- 칩 선택 시 scale 0.98 → 1.0, 120ms ease-out
- ResultCard 등장: 페이드 인+위치 12dp 상승, 200ms
- TypingIndicator: 600ms 반복 점멸

## 스타일/토큰 적용
- spacing/radius/icon/typography는 DESIGN_TOKENS.yaml 준수
- 상태 색상: success/warning/error는 Theme에서 가져오기(하드코딩 금지)
