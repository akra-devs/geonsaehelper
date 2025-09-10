# Docs — Information Architecture

Status: canonical (Docs Index)
last_updated: 2025-09-10

이 디렉터리는 제품/규칙/UI/카피/인테이크/운영/측정/개발 문서를 범주별(논리적)로 정리합니다. 현재는 코드/문서의 경로 호환성을 위해 파일 물리 경로는 유지하며, 카테고리/연계성은 본 문서와 DOCS_INDEX.md에서 안내합니다.

## 빠른 길잡이
- 제품 개요/로드맵: PRD_v1.md, PRODUCT_PLAN_MVP.md
- 규칙/정책(근거): RULES_HUG_v1.md, RULES_HUG_mapping.yaml, HUG_POLICY_DOCS/*
- 인테이크 스크립트: INTAKE_FLOW.md
- UI 스펙/토큰: COMPONENT_SPECS.md, UI_BLUEPRINT.yaml, DESIGN_TOKENS.yaml
- 카피/템플릿: COPY_GUIDE.md, RESULT_CARD_COPY.md, QNA_TEMPLATES.md
- 측정 계획: MEASUREMENT_PLAN.md
- 운영/법/광고: OPERATIONS_RUNBOOK.md, LEGAL_CHECKLIST.md, ADS_POLICY.md
- 진행/TODO: DEV_PROGRESS_HUG_INTAKE.md, DEV_TODO_HUG_INTAKE.md

## 카테고리(논리)
- Product: PRD_v1.md, PRODUCT_PLAN_MVP.md, PRODUCT_BRIEF.md, ARCHITECTURE.md
- Rules: RULES_HUG_v1.md, RULES_HUG_mapping.yaml, HUG_POLICY_DOCS/*, RAG_POLICY.md
- Intake: INTAKE_FLOW.md
- UI: COMPONENT_SPECS.md, UI_BLUEPRINT.yaml, DESIGN_TOKENS.yaml, UI_UX_GUIDE.md, FLUTTER_DESIGN_SYSTEM.md, FIGMA_SPEC.md, APP_SCREEN_PLAN.md, SCREEN_SPECS.md, WIREFRAMES.md, SPLASH_GUIDE.md
- Copy: COPY_GUIDE.md, RESULT_CARD_COPY.md, QNA_TEMPLATES.md
- Measurement: MEASUREMENT_PLAN.md
- Ops: OPERATIONS_RUNBOOK.md, LEGAL_CHECKLIST.md, ADS_POLICY.md, RELEASE_PLAN.md, DEPLOY_LOCAL_WEB.md
- Dev: DEV_PROGRESS_HUG_INTAKE.md, DEV_TODO_HUG_INTAKE.md, CONTRIBUTING_DOCS.md, PROJECT.md, BACKLOG_EPICS_USER_STORIES.md, USER_TEST_PLAN.md

## 연계성(의존 관계)
- product/PRD_v1.md → rules/RULES_HUG_v1.md → RULES_HUG_mapping.yaml(HUG_POLICY_DOCS/*) → 앱 로직
- intake/INTAKE_FLOW.md ↔ ui/COMPONENT_SPECS.md(인테이크 컴포넌트) ↔ copy/COPY_GUIDE.md(질문 문구)
- rules/RULES_HUG_v1.md ↔ copy/RESULT_CARD_COPY.md(Q&A 템플릿 포함) ↔ measurement/MEASUREMENT_PLAN.md(사유/이벤트 키)
- ops/* ↔ dev/*(운영 절차와 작업 현황)

자세한 목록은 DOCS_INDEX.md를 참고하세요.
