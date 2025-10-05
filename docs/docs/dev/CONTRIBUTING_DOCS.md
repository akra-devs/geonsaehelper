# CONTRIBUTING_DOCS — 문서 작성/유지 규약
Status: canonical (Docs Conventions)

마지막 업데이트: 2025-09-03

## Canonical vs. Derived
- canonical: 사실/요구사항의 단일 출처. 파생 문서가 내용을 재정의하지 않습니다.
- derived: 요약/가이드/예시. 상세·정합성은 항상 canonical을 우선합니다.

## 단일 소스 규칙
- last_verified: RULES_HUG_mapping.yaml의 값을 단일 소스로 사용합니다.
- 규칙/임계값: RULES_HUG_mapping.yaml → RULES_HUG_v1.md 순으로 참조합니다.

## 참조 표기
- docs 내부 문서 간에는 파일명만 기재합니다(예: DESIGN_TOKENS.yaml).
- 루트 README 등 외부 진입점에서는 경로를 포함합니다(예: docs/docs/PRD_v1.md).
- 외부 링크/검색은 금지합니다(RAG_POLICY).

## 변경 원칙
- 중복/상충 발견 시: canonical에만 내용을 유지하고, derived에는 요약/링크만 남깁니다.
- Status 헤더 유지: 문서 상단에 Status를 표기합니다.
- 네비게이션: 하단 4-탭(시작/체크리스트/히스토리/설정)을 기준으로 문서를 일관되게 기술합니다.

## 커밋 규칙(문서)
- Conventional Commits: docs(scope): summary
- 예: docs(ia): update index, mark canonical; docs(rules): refresh last_verified

## 점검 체크리스트
- [ ] Status 헤더 존재(canonical/derived)
- [ ] last_verified 참조가 단일 소스 규칙과 일치
- [ ] 파일명/경로 표기가 본 규약과 일치
- [ ] 중복/상충 문구 제거 또는 canonical로 집약

