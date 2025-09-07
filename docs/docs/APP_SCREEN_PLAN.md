# APP_SCREEN_PLAN — 챗봇형(선택형+대화형) 화면 기획
Status: canonical (Screen Flow)

마지막 업데이트: 2025-09-02

## 문서 연관성
- 상위 가이드: UI_UX_GUIDE.md (UI 원칙/계약/A11y/측정 총괄)
- 제품 요구사항: PRD_v1.md (수용기준/범위)
- 규칙/정책: RULES_HUG_v1.md, RAG_POLICY.md (판정/인용/최신성 기준)
- 청사진/토큰: UI_BLUEPRINT.yaml, DESIGN_TOKENS.yaml
- 컴포넌트/카피: COMPONENT_SPECS.md, COPY_GUIDE.md, RESULT_CARD_COPY.md
- 인덱스: DOCS_INDEX.md (읽기 순서 및 연관 맵)

## 목적/요약
- 목표: 선택형 인테이크를 챗 스레드 안에서 자연스럽게 진행하고, 결과 카드와 후속 Q&A를 동일한 대화 맥락에서 제공.
- 원칙: 실용 요약(TL;DR → 이유/예외 → 다음 단계), ‘모름’은 즉시 표시 및 불가(정보 부족) 귀결, 내부 문서 기반, 마지막 확인일 노출.
- 후속 대화: Spring AI 기반 API 연동(서버 측 생성/검색)으로 답변. 앱은 대화 UI/상태·이벤트·근거 표시 담당.

## IA & 네비게이션
- 하단 탭(권장 4-탭):
  - 시작(Start): 대화(Conversation) — 기본 진입점(온보딩 간단 조사 → 본판정 → 결과 → Q&A)
  - 체크리스트(DocsChecklist)
  - 히스토리(History)
  - 설정(Settings)

탭 외 이동: 상단 AppBar 액션(Help 등) + 결과/챗 내 CTA로 세부 화면 이동.

## 화면 설계

### 1) 홈(Home)
- 목적: 핵심 작업 진입(예비판정 시작, 최근 대화 재개).
- 구성:
  - 헤더: 앱 타이틀 “전세자금대출 도우미”
  - 그리드 카드: 자격(본인·집), 한도(개요), 서류 체크리스트, 절차 안내
  - 배너(옵션): 정책 변경 요약
- 이벤트: `home_open`, `home_card_click{card_id}`

### 2) 대화(Conversation) — 챗봇형 인테이크 + Q&A
- 목적: 선택형 인테이크 질문(A1..A7, P1..P7, S1)을 챗 스레드로 제시하고, 결과 카드 및 Q&A를 동일 스레드에 삽입.
- 상단(AppBar): 타이틀, 액션(History, Help)
- 본문(스레드):
  - ChatBubble(user/bot)
  - IntakeQuestion 블록(ChoiceChip, ‘모름’ 포함)
  - ProgressInline: “3/12” 진행율 표시(서브텍스트)
  - ResultCard inline 삽입(가능/불가-정보부족/불가-결격)
  - AdSlot(optional): 결과 카드 하단(‘광고’ 라벨)
- 하단(Composer):
  - 선택형 질문 중에는 비활성화 상태(placeholder: “선택지에서 답변해 주세요”).
  - 결과 노출 후 활성화, 추천 질문 칩(한도/서류/절차).
- 이벤트: `intake_start`, `intake_answer{qid, answer, is_unknown}`, `intake_complete{count, has_unknown, status}`, `ruling_shown{status}`, `qna_ask{topic}`, `qna_answer{has_disclaimer,last_verified}`, `next_step_click`, `ad_view`.
- 상태/빈/에러:
  - 로딩: 봇 타이핑 인디케이터(점멸), Q&A 대기 시 skeleton bubble.
  - 에러: 네트워크 오류 시 bot bubble로 재시도 버튼 표기.
  - 긴 답변: “요약 먼저 보기” 토글.

### 3) 결과(Result in-thread)
- ResultCard(상세):
  - 배지: 마지막 확인일(YYYY-MM-DD)
  - TL;DR(2–3줄)
  - 사유: 충족/미충족/확인불가 라벨링
  - 다음 단계: 체크리스트/확인 방법
  - CTA: “서류 체크리스트”, “확인 방법 보기”, “한도 추정”
- 광고: 카드 하단 1개(스크롤 후 노출)

### 4) 체크리스트(DocsChecklist)
- 목적: 결과 후속 액션으로 준비물/발급처/순서 제공.
- 구성:
  - 섹션: 개인/임대/절차
  - 토글: 완료 체크, 공유/저장(로컬)
- 이벤트: `next_step_click{action: checklist}`, `checklist_mark{item, done}`

### 5) 히스토리(History)
- 목적: 최근 대화/판정 결과 재방문.
- 구성: 리스트 카드(상태, TL;DR, 일자), 검색/정렬
- 이벤트: `history_open`, `history_item_open`

### 6) 설정(Settings)
- 항목: 테마(시스템/라이트/다크), 데이터 저장 옵션(로컬), 고지/정책, 버전 정보
- 이벤트: `settings_open`, `theme_change{mode}`

## 컴포넌트 사양(요약)
- ChatBubble: role(user/bot), citations[{docId,sectionKey}] — RAG 정책에 따라 링크 미노출, 칩으로 출처 표기
- IntakeQuestion: qid/label/options/selected/showUnknown/onChanged/helper/errorText
- ResultCard: status/tldr/reasons/nextSteps/lastVerified(onExpand)
- ProgressInline: Text(“x/y”), LinearProgress(optional)
- AdSlot: ‘광고’ 라벨 + 시각적 구분, 전면/팝업 금지

세부 컴포넌트 트리/프롭/상태는 SCREEN_SPECS.md 참조.

## 디자인 원칙/토큰
- 색상: Material3 ColorScheme(seed — app_theme 기준), 성공/경고/오류 시맨틱 사용
- 간격/라운드: DESIGN_TOKENS 준수(spacing [4,8,12,16,24,32], radius 8)
- 타이포: display/headline/title/body/label 단계 사용
- 접근성: 대비 기준 충족, 음성 라벨(Semantics), 칩/버튼 최소 44dp

## 카피/톤
- 인테이크: “모르면 ‘모름’을 선택하세요. ‘모름’이 하나라도 있으면 판정은 ‘불가(정보 부족)’가 됩니다.”
- 결과: TL;DR → 이유/예외 → 다음 단계. “금융자문 아님”, “마지막 확인일” 노출.
- Q&A: 실용 요약, 수치/조건은 원문 그대로.

## API 연동(초안, Spring AI)
- 베이스: `/api` (예시)
- 대화 생성/유지:
  - POST `/api/chat/session` → { sessionId }
  - POST `/api/chat/messages` { sessionId, role: user|system, content, context? }
  - POST `/api/chat/complete` { sessionId, prompt } → { content, citations: [{docId,sectionKey}], lastVerified }
  - GET `/api/chat/sessions` → 최근 세션 목록
- 에러 코드: `429`(레이트), `5xx`(서버), 표준화된 `error.code`로 매핑
- 앱 처리: 타이핑 인디케이터, 재시도 버튼, 축약/전문 토글

## 상태/이벤트 매핑(측정)
- MEASUREMENT_PLAN의 이벤트 키를 화면 동작에 1:1 매핑
- 추가 이벤트:
  - `composer_enable{reason: after_ruling|after_choice}`
  - `ad_view{placement: result|chat_bottom}`

## 에지케이스/가드레일
- 중복 질문 방지: 동일 qid 재질문 금지, 정정 요청 시 ‘정정 모드’로 교체 표시
- 충돌 규칙: 내부 문서 상충 시 보수적으로 ‘확인불가’, 화면에 안내 배지
- 최신성 30일 초과: 결과/답변에 “정보 최신성 확인 필요” 배지

## 테스트 키(예)
- ChatBubble: `Key('Chat.user')` / `Key('Chat.Citation.0')`
- IntakeQuestion: `Key('Intake.$qid')` / `Key('Intake.$qid.$value')`
- ResultCard: `Key('ResultCard.TLDR')` / `Key('ResultCard.Reasons')` / `Key('ResultCard.Next')`

## 단계적 고도화(마일스톤)
- 알파: 챗봇형 인테이크(A1..A7,P1..P7,S1) + 결과 카드 inline, Q&A 목업 응답, 이벤트 로깅 기본
- 베타: Spring AI 연동(Q&A 실서비스), 규칙 매핑 연결, 히스토리/체크리스트 저장, 광고 슬롯
- GA: 온보딩/카피 정제, 접근성/성능 개선, KPI 대시보드 연동

## 참고 문서
- PRD: PRD_v1.md
- 규칙: RULES_HUG_v1.md, RULES_HUG_mapping.yaml
- RAG: RAG_POLICY.md
- 인테이크: INTAKE_FLOW.md
- 컴포넌트: COMPONENT_SPECS.md
- UI 토큰/청사진: DESIGN_TOKENS.yaml, UI_BLUEPRINT.yaml
- 측정/운영/법/광고: MEASUREMENT_PLAN.md, OPERATIONS_RUNBOOK.md, LEGAL_CHECKLIST.md, ADS_POLICY.md
