# DOCS_INDEX — 문서 인덱스 & 연관성 맵
Status: canonical (Information Architecture)

마지막 업데이트: 2025-09-02

## 읽기 순서(권장)
1) 제품 개요 — PRODUCT_BRIEF.md → PRD_v1.md
2) 규칙/정책 — RULES_HUG_v1.md, RULES_HUG_mapping.yaml, RAG_POLICY.md
3) UI/UX — UI_UX_GUIDE.md → APP_SCREEN_PLAN.md → SCREEN_SPECS.md → UI_BLUEPRINT.yaml → DESIGN_TOKENS.yaml → COMPONENT_SPECS.md → COPY_GUIDE.md / RESULT_CARD_COPY.md
4) 측정/운영/법/광고 — MEASUREMENT_PLAN.md, OPERATIONS_RUNBOOK.md, LEGAL_CHECKLIST.md, ADS_POLICY.md
5) 실행 계획 — PRODUCT_PLAN_MVP.md, BACKLOG_EPICS_USER_STORIES.md

## Canonical Set
- Product: PRD_v1.md (PRODUCT_BRIEF.md는 요약본)
- Intake: INTAKE_FLOW.md
- Rules: RULES_HUG_v1.md + RULES_HUG_mapping.yaml
- RAG: RAG_POLICY.md
- UI Design: DESIGN_TOKENS.yaml, UI_BLUEPRINT.yaml
- Component APIs: COMPONENT_SPECS.md
- Screen Flow/Specs: APP_SCREEN_PLAN.md, SCREEN_SPECS.md
- UX Guide: UI_UX_GUIDE.md, Flutter implementation: FLUTTER_DESIGN_SYSTEM.md
- Measurement: MEASUREMENT_PLAN.md
- Operations: OPERATIONS_RUNBOOK.md, Release: RELEASE_PLAN.md
- Legal/Ads: LEGAL_CHECKLIST.md, ADS_POLICY.md

## 연관성(요약)
- PRD_v1.md → 화면/컴포넌트의 수용기준과 콘텐츠 범위 정의
- RULES_HUG_v1.md → 결과 카드 상태/사유/‘모름’ 처리 규정의 근거
- RAG_POLICY.md → 챗봇 Q&A의 근거/표기/최신성 규정
- UI_UX_GUIDE.md → UI 원칙/계약(Props/Keys)/A11y/측정 기준 총괄
- APP_SCREEN_PLAN.md → 대화형 화면 플로우/상태/이벤트/API 훅 상세
- SCREEN_SPECS.md → 화면별 컴포넌트 트리/프롭/상태/에러/로딩 상세
- PRODUCT_PLAN_MVP.md → MVP 종합 계획(비전/스코프/KPI/IA/플로우/리스크/마일스톤)
- BACKLOG_EPICS_USER_STORIES.md → 에픽/유저 스토리/수용기준/DoD
- UI_BLUEPRINT.yaml → 화면 배치/레이아웃 청사진, DESIGN_TOKENS.yaml → 색/간격/라운드/타이포 토큰
- COMPONENT_SPECS.md → IntakeQuestion/ResultCard/ChatBubble API 사양
- COPY_GUIDE.md/RESULT_CARD_COPY.md → 카피/톤/템플릿

## 산출물/구현 연결
- UI 확정 후 내부 로직(규칙 엔진/RAG 연동/BLoC)은 UI 계약에 맞춰 단계적으로 연결
- 이벤트 로깅은 MEASUREMENT_PLAN의 스키마에 따라 UI 인터랙션 시점에 배치
