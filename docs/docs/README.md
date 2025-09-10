# Docs — Information Architecture

Status: canonical (Docs Index)
last_updated: 2025-09-10

이 디렉터리는 제품/규칙/UI/카피/인테이크/운영/측정/개발 문서를 범주별로 정리합니다. 문서는 하위 폴더로 물리 이동되었습니다.

## 빠른 길잡이
- 제품 개요/로드맵: product/PRD_v1.md, product/PRODUCT_PLAN_MVP.md
- 규칙/정책(근거): rules/RULES_HUG_v1.md, RULES_HUG_mapping.yaml, HUG_POLICY_DOCS/*
- 인테이크 스크립트: intake/INTAKE_FLOW.md
- UI 스펙/토큰: ui/COMPONENT_SPECS.md, ui/UI_BLUEPRINT.yaml, ui/DESIGN_TOKENS.yaml
- 카피/템플릿: copy/COPY_GUIDE.md, copy/RESULT_CARD_COPY.md, copy/QNA_TEMPLATES.md
- 측정 계획: measurement/MEASUREMENT_PLAN.md
- 운영/법/광고: ops/OPERATIONS_RUNBOOK.md, ops/LEGAL_CHECKLIST.md, ops/ADS_POLICY.md
- 진행/TODO: dev/DEV_PROGRESS_HUG_INTAKE.md, dev/DEV_TODO_HUG_INTAKE.md

## 카테고리(물리)
- Product: product/PRD_v1.md, product/PRODUCT_PLAN_MVP.md, product/PRODUCT_BRIEF.md, product/ARCHITECTURE.md
- Rules: rules/RULES_HUG_v1.md, RULES_HUG_mapping.yaml, HUG_POLICY_DOCS/*, rules/RAG_POLICY.md
- Intake: intake/INTAKE_FLOW.md
- UI: ui/COMPONENT_SPECS.md, ui/UI_BLUEPRINT.yaml, ui/DESIGN_TOKENS.yaml, ui/UI_UX_GUIDE.md, ui/FLUTTER_DESIGN_SYSTEM.md, ui/FIGMA_SPEC.md, ui/APP_SCREEN_PLAN.md, ui/SCREEN_SPECS.md, ui/WIREFRAMES.md, ui/SPLASH_GUIDE.md
- Copy: copy/COPY_GUIDE.md, copy/RESULT_CARD_COPY.md, copy/QNA_TEMPLATES.md
- Measurement: measurement/MEASUREMENT_PLAN.md
- Ops: ops/OPERATIONS_RUNBOOK.md, ops/LEGAL_CHECKLIST.md, ops/ADS_POLICY.md, ops/RELEASE_PLAN.md, ops/DEPLOY_LOCAL_WEB.md
- Dev: dev/DEV_PROGRESS_HUG_INTAKE.md, dev/DEV_TODO_HUG_INTAKE.md, dev/CONTRIBUTING_DOCS.md, dev/PROJECT.md, dev/BACKLOG_EPICS_USER_STORIES.md, dev/USER_TEST_PLAN.md

## 연계성(의존 관계)
- product/PRD_v1.md → rules/RULES_HUG_v1.md → RULES_HUG_mapping.yaml(HUG_POLICY_DOCS/*) → 앱 로직
- intake/INTAKE_FLOW.md ↔ ui/COMPONENT_SPECS.md(인테이크 컴포넌트) ↔ copy/COPY_GUIDE.md(질문 문구)
- rules/RULES_HUG_v1.md ↔ copy/RESULT_CARD_COPY.md(Q&A 템플릿 포함) ↔ measurement/MEASUREMENT_PLAN.md(사유/이벤트 키)
- ops/* ↔ dev/*(운영 절차와 작업 현황)

중요: HUG_POLICY_DOCS/* 는 정책 ‘실데이터’로 간주합니다. 경로는 변경될 수 있으나 파일 내용은 변경하지 않습니다(불변). 변경 시 CI에서 차단됩니다.

자세한 목록은 DOCS_INDEX.md를 참고하세요.
