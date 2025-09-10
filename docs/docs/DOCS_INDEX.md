# DOCS_INDEX — 문서 인덱스(카테고리/연계)
Status: canonical (Information Architecture)

마지막 업데이트: 2025-09-10

문서를 카테고리별로 하위 폴더에 물리 정리했습니다. 아래 경로는 docs/docs 기준 상대 경로입니다.

## Product(제품/기획)
- PRD: `product/PRD_v1.md`
- MVP 종합 기획: `product/PRODUCT_PLAN_MVP.md`
- 제품 브리프: `product/PRODUCT_BRIEF.md`
- 아키텍처: `product/ARCHITECTURE.md`

## Rules(규칙/정책)
- 규칙 본문: `rules/RULES_HUG_v1.md`
- 규정 매핑: `RULES_HUG_mapping.yaml` (코드 연결)
- 정책 소스(정규화): `HUG_POLICY_DOCS/*` (코드 연결)
- 정책 소스(원문): `HUG_POLICY_RAW_DOCS/*`
- RAG 정책: `rules/RAG_POLICY.md`

## Intake/Copy
- 인테이크 플로우: `intake/INTAKE_FLOW.md`
- 카피 가이드: `copy/COPY_GUIDE.md`
- 결과 카드 카피: `copy/RESULT_CARD_COPY.md`
- Q&A 템플릿: `copy/QNA_TEMPLATES.md`

## UI/Design
- 디자인 시스템: `ui/FLUTTER_DESIGN_SYSTEM.md`
- 컴포넌트 스펙: `ui/COMPONENT_SPECS.md`
- UI 블루프린트/토큰: `ui/UI_BLUEPRINT.yaml`, `ui/DESIGN_TOKENS.yaml`
- 피그마 사양: `ui/FIGMA_SPEC.md`
- UI/UX 가이드: `ui/UI_UX_GUIDE.md`
- 화면 기획/사양/와이어프레임: `ui/APP_SCREEN_PLAN.md`, `ui/SCREEN_SPECS.md`, `ui/WIREFRAMES.md`
- 스플래시 가이드: `ui/SPLASH_GUIDE.md`

## Measurement(계측)
- 측정 계획: `measurement/MEASUREMENT_PLAN.md`

## Ops/Legal/Ads/Release
- 운영 런북: `ops/OPERATIONS_RUNBOOK.md`
- 법적 체크리스트: `ops/LEGAL_CHECKLIST.md`
- 광고 정책: `ops/ADS_POLICY.md`
- 릴리즈/배포: `ops/RELEASE_PLAN.md`, `ops/DEPLOY_LOCAL_WEB.md`

## Dev(진행/프로세스)
- 진행 현황: `dev/DEV_PROGRESS_HUG_INTAKE.md`
- TODO: `dev/DEV_TODO_HUG_INTAKE.md`
- 기여 가이드(문서): `dev/CONTRIBUTING_DOCS.md`
- 프로젝트 개요: `dev/PROJECT.md`
- 백로그: `dev/BACKLOG_EPICS_USER_STORIES.md`

## 관계도(요약)
- product/PRD_v1.md → rules/RULES_HUG_v1.md → RULES_HUG_mapping.yaml(HUG_POLICY_DOCS/*) → 앱 로직
- intake/INTAKE_FLOW.md ↔ ui/COMPONENT_SPECS.md ↔ copy/COPY_GUIDE.md/QNA_TEMPLATES.md
- rules/RULES_HUG_v1.md ↔ copy/RESULT_CARD_COPY.md ↔ measurement/MEASUREMENT_PLAN.md
- ops/* ↔ dev/*
