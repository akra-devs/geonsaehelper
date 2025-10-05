# UI_UX_GUIDE — UI/UX 우선 설계 가이드
Status: canonical (UX Principles)

마지막 업데이트: 2025-09-02

## 목적
- 내부 로직 구현에 앞서 UI/UX를 확정하여 컴포넌트, 화면 흐름, 상태, 인터랙션을 고정합니다.
- 이후 규칙 엔진/RAG 연동은 이 가이드의 UI 계약(Props/States/Events)을 준수합니다.

## 핵심 원칙
- 챗봇형(선택형+대화형) 일관성: 인테이크 질문은 선택형 칩으로, Q&A는 자유 입력.
- 실용 요약 톤: TL;DR → 이유/예외 → 다음 단계. 외부 링크 미노출, 마지막 확인일 표기.
- 접근성/A11y: 대비/크기, Semantics 라벨, 터치 타겟 ≥ 44dp.
- 디자인 토큰 준수: 색/간격/라운드/타이포는 토큰에서만 사용.
 - 국제화: `flutter gen-l10n` 기반 문자열 분리, 하드코딩 지양

## IA/네비게이션
- 기본 진입: Conversation(대화) 화면
- 보조: DocsChecklist(체크리스트), History(히스토리), Settings(설정)
- 하단 탭: 4-탭(시작/체크리스트/히스토리/설정). AppBar 액션/CTA는 보조 이동

## 화면 구성 요소
- ChatBubble(role: user|bot, citations[]): 인용 칩은 문서ID/섹션키, 링크 미노출
- IntakeQuestion(qid, label, options[], selected?, showUnknown=true, onChanged): ‘모름’ 기본 제공
- ResultCard(status, tldr, reasons[], nextSteps[], lastVerified): 배지에 ‘마지막 확인일’ 표기
- ProgressInline: “x/y” 진행률 텍스트(+옵션: LinearProgress)
- AdSlot(optional): 결과 하단 1개, ‘광고’ 라벨, 전면/팝업 금지

## 상태/빈/에러
- 로딩: 챗봇 타이핑 인디케이터, Q&A 스켈레톤 버블
- 빈 상태: 첫 진입 안내 버블 + “시작하기”
- 에러: 네트워크/서버 오류는 bot bubble로 노출 + 재시도 버튼
- 긴 답변: “요약 먼저 보기” 토글
 - 상호작용: 버튼/칩은 최소 48×48dp 터치 타겟 확보, 잉크 효과 유지(Material 버튼/Chip 권장)

## 진행/완료 흐름
1) 봇 인사 → A1..A7, P1..P7, S1 순서로 질문(분기 허용)
2) 답변 수집 중에는 Composer 비활성화
3) 결과 카드 인라인 노출(가능/불가-정보부족/불가-결격)
4) 후속 Q&A Composer 활성화 + 추천 질문 칩

## 컴포넌트 계약(Props/Keys)
- COMPONENT_SPECS.md를 표준으로 하며 테스트 Key는 다음을 사용:
  - ResultCard: `Key('ResultCard.Container')`, `Key('ResultCard.TLDR')`, `Key('ResultCard.Reasons')`, `Key('ResultCard.Next')`
  - IntakeQuestion: `Key('Intake.$qid')`, `Key('Intake.$qid.$value')`
  - ChatBubble: `Key('Chat.$role')`, `Key('Chat.Citation.$index')`

## 디자인 토큰
- 색/타이포/간격/라운드: DESIGN_TOKENS.yaml 참조
- 화면 배치/컴포넌트 배치는 UI_BLUEPRINT.yaml 참조
 - 방향성: 여백은 EdgeInsetsDirectional 우선(RTL 대비)

## 카피/톤
- COPY_GUIDE.md, RESULT_CARD_COPY.md를 기준으로 문구 선택
- ‘모름’ 처리 안내/디스클레이머/다음 단계 문구 포함

## 측정 이벤트 매핑
- MEASUREMENT_PLAN.md의 이벤트를 UI 상호작용에 1:1 매핑
- 예: intake_answer, intake_complete, ruling_shown, qna_ask, qna_answer, next_step_click (reasons_toggle는 추후 추가)

## 문서 연관성
- 상세 화면 설계: APP_SCREEN_PLAN.md
- 청사진/토큰: UI_BLUEPRINT.yaml, DESIGN_TOKENS.yaml
- 컴포넌트 사양: COMPONENT_SPECS.md
- 카피/톤: COPY_GUIDE.md, RESULT_CARD_COPY.md
- 제품 요구사항: PRD_v1.md
