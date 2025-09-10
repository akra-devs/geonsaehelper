# DOCS_INDEX — 문서 인덱스(카테고리/연계)
Status: canonical (Information Architecture)

마지막 업데이트: 2025-09-10

문서를 카테고리별(논리)로 재정리했습니다. 현재는 파일 물리 경로는 루트에 유지하며, 카테고리와 연계성만 정리합니다.

## Product(제품/기획)
- PRD: `docs/docs/PRD_v1.md`
- MVP 종합 기획: `docs/docs/PRODUCT_PLAN_MVP.md`
- 제품 브리프: `docs/docs/PRODUCT_BRIEF.md`
- 아키텍처: `docs/docs/ARCHITECTURE.md`

## Rules(규칙/정책)
- 규칙 본문: `docs/docs/RULES_HUG_v1.md`
- 규정 매핑: `docs/docs/RULES_HUG_mapping.yaml` (코드 연결)
- 정책 소스(정규화): `docs/docs/HUG_POLICY_DOCS/*` (코드 연결)
- 정책 소스(원문): `docs/docs/HUG_POLICY_RAW_DOCS/*`
- RAG 정책: `docs/docs/RAG_POLICY.md`

## Intake/Copy
- 인테이크 플로우: `docs/docs/INTAKE_FLOW.md`
- 카피 가이드: `docs/docs/COPY_GUIDE.md`
- 결과 카드 카피: `docs/docs/RESULT_CARD_COPY.md`
- Q&A 템플릿: `docs/docs/QNA_TEMPLATES.md`

## UI/Design
- 디자인 시스템: `docs/docs/FLUTTER_DESIGN_SYSTEM.md`
- 컴포넌트 스펙: `docs/docs/COMPONENT_SPECS.md`
- UI 블루프린트/토큰: `docs/docs/UI_BLUEPRINT.yaml`, `docs/docs/DESIGN_TOKENS.yaml`
- 피그마 사양: `docs/docs/FIGMA_SPEC.md`
- UI/UX 가이드: `docs/docs/UI_UX_GUIDE.md`
- 화면 기획/사양/와이어프레임: `docs/docs/APP_SCREEN_PLAN.md`, `docs/docs/SCREEN_SPECS.md`, `docs/docs/WIREFRAMES.md`
- 스플래시 가이드: `docs/docs/SPLASH_GUIDE.md`

## Measurement(계측)
- 측정 계획: `docs/docs/MEASUREMENT_PLAN.md`

## Ops/Legal/Ads/Release
- 운영 런북: `docs/docs/OPERATIONS_RUNBOOK.md`
- 법적 체크리스트: `docs/docs/LEGAL_CHECKLIST.md`
- 광고 정책: `docs/docs/ADS_POLICY.md`
- 릴리즈/배포: `docs/docs/RELEASE_PLAN.md`, `docs/docs/DEPLOY_LOCAL_WEB.md`

## Dev(진행/프로세스)
- 진행 현황: `docs/docs/DEV_PROGRESS_HUG_INTAKE.md`
- TODO: `docs/docs/DEV_TODO_HUG_INTAKE.md`
- 기여 가이드(문서): `docs/docs/CONTRIBUTING_DOCS.md`
- 프로젝트 개요: `docs/docs/PROJECT.md`
- 백로그: `docs/docs/BACKLOG_EPICS_USER_STORIES.md`

## 관계도(요약)
- product/PRD_v1.md → rules/RULES_HUG_v1.md → RULES_HUG_mapping.yaml(HUG_POLICY_DOCS/*) → 앱 로직
- intake/INTAKE_FLOW.md ↔ ui/COMPONENT_SPECS.md ↔ copy/COPY_GUIDE.md/QNA_TEMPLATES.md
- rules/RULES_HUG_v1.md ↔ copy/RESULT_CARD_COPY.md ↔ measurement/MEASUREMENT_PLAN.md
- ops/* ↔ dev/*
