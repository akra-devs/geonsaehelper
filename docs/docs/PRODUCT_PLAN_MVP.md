# PRODUCT_PLAN_MVP — 앱 전체(MVP) 종합 기획서

마지막 업데이트: 2025-09-02

## 1) 비전/한줄 소개
- “전세자금대출(HUG 우선) 자격을 빠르고 명확하게 판정하고, 이후 필요한 정보(한도/서류/절차)를 대화형으로 안내하는 챗봇 중심 앱.”

## 2) 타깃/페르소나/JTBD
- 타깃: 전세/이사/갱신 준비 20–40대, 첫 전세 경험자 중심
- JTBD: “내 상황/집이 조건에 맞는지 즉시 알고, 다음 준비를 명확히 하고 싶다.”

## 3) 범위/비범위(스코프)
- In: HUG 예비판정(본인·목적물), 결과 카드, 후속 Q&A, 체크리스트, 히스토리, 설정, 광고(비간섭)
- Out(이번): 계정/로그인, 푸시, 결제, 다기관(HF/SGI) 비교, 은행/신용 연동, 실거래/지도, 서버 측 추천 시스템

## 4) 성공지표(KPI)
- 퍼널: 판정 완주율 ≥ 70%, 최초 판정 ≤ 90초
- 품질: 결과 만족(👍) ≥ 70%, “사유 보기” ≥ 40%, 정정 요청 ≤ 5%
- 리텐션: 후속 Q&A 진입 ≥ 50%, D7 재방문 ≥ 25%

Status: canonical (Plan & Roadmap)

## 5) 정보 구조(IA)/네비게이션
- 기본 진입: Conversation(대화)
- 보조 화면: DocsChecklist, History, Settings
- 하단 탭: 4-탭(시작/체크리스트/히스토리/설정) — 구현과 일치(AppShell 기준)

## 6) 핵심 플로우
- 인테이크 → 결과 카드 인라인 → Q&A → 체크리스트/한도/확인 방법 → 히스토리 저장/재방문

## 7) 기능 세트(에픽)
- E1 대화형 인테이크(선택형 칩, 진행도/로딩/에러)
- E2 판정 결과 카드(TL;DR/사유/다음 단계/last_verified)
- E3 Q&A(RAG) — Spring AI 연동, 인용 칩, 최신성 배지
- E4 체크리스트 — 준비물/발급처/순서, 완료 토글/공유
- E5 히스토리 — 최근 판정/대화, 검색/정렬
- E6 설정 — 테마/데이터/고지
- E7 측정/피드백 — MEASUREMENT_PLAN 이벤트, 👍/정정
- E8 광고 — 비간섭 슬롯(결과/챗 하단), ‘광고’ 라벨

## 8) 요구사항(요약) 및 수용기준
- 인테이크: 모든 문항에 ‘모름’ 제공, 하나라도 있으면 결과는 불가(정보 부족)
- 판정: 결격(C1)→필수(C2)→경고(C3) 순서 평가, 결과 타입 3종
- Q&A: 내부 문서 근거, 외부 링크 금지, 인용 메타 표기, last_verified 노출
- 샘플 GWT는 BACKLOG_EPICS_USER_STORIES.md 참조

## 9) UI/UX 기준
- UI_UX_GUIDE.md, APP_SCREEN_PLAN.md, SCREEN_SPECS.md, UI_BLUEPRINT.yaml, DESIGN_TOKENS.yaml, COMPONENT_SPECS.md, COPY_GUIDE.md/RESULT_CARD_COPY.md 준수

## 10) 기술/연동
- 프론트: Flutter + BLoC + Theme Extensions, 로컬저장(shared_preferences)
- 규칙엔진: RULES_HUG_v1 + RULES_HUG_mapping.yaml 주입형
- Q&A: Spring AI API(`/chat/session`, `/chat/messages`, `/chat/complete`)
- 계측: MEASUREMENT_PLAN 이벤트 스키마

## 11) 데이터/보안/법/광고
- 데이터: 민감정보 미수집, 판정 히스토리 로컬 우선, 서버 저장 시 익명화
- 법: 예비판정/자문 아님/마지막 확인일 고지, 접근성(A11y) 확보
- 광고: 결과/챗 하단 1개, 스크롤 후 노출, 전면/팝업 금지, 고위험 카테고리 차단

## 12) 리스크/가드레일
- 정보 부족 증가 → 확인 방법 강화/질문 순서 개선
- 최신성 이슈 → last_verified 표시/30일 경고 배지/운영 루틴
- 규칙 상충 → 보수적 ‘확인불가’, 결정 로그 관리

## 13) 마일스톤/일정(제안)
- 알파(2주): 챗 인테이크 전 문항 + 결과 카드 + Q&A 목업 + 측정 기본 + 광고 슬롯
- 베타(4주): Spring AI 연동, 규칙 매핑/버전, 히스토리/체크리스트 저장, 카피 정제, 접근성 개선
- GA: 퍼널/성능/접근성 개선, 온보딩, 릴리스 노트/지원문서

## 14) 산출물/완료 기준
- DoR: UI 스펙/카피/이벤트 확정, 리스크/의존성/추정치 명시
- DoD: 수용기준/QA 체크/측정 검증/접근성/릴리스 노트 업데이트

## 15) 오픈 이슈/결정 로그(초안)
- 한도 추정 범위/표현 방식
- 히스토리 서버 동기화 여부/범위
- Spring AI 응답 제한/요약 규칙(길이/톤)

## 16) 참조
- PRD_v1.md, PRODUCT_BRIEF.md, INTAKE_FLOW.md, RULES_HUG_v1.md, RULES_HUG_mapping.yaml, RAG_POLICY.md, UI_UX_GUIDE.md, APP_SCREEN_PLAN.md, SCREEN_SPECS.md, UI_BLUEPRINT.yaml, DESIGN_TOKENS.yaml, COMPONENT_SPECS.md, COPY_GUIDE.md, RESULT_CARD_COPY.md, MEASUREMENT_PLAN.md, OPERATIONS_RUNBOOK.md, ADS_POLICY.md, LEGAL_CHECKLIST.md
