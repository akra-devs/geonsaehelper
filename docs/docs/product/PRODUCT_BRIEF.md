# 제품 기획 핵심 요약 및 진행 기록
Status: derived (Executive summary). Canonical: PRD_v1.md

마지막 업데이트: 2025-09-02

## 한줄 소개
전세자금대출(HUG 우선) 자격(본인·목적물)을 빠르게 판정하고, 이후 한도/서류/절차를 AI 챗봇으로 안내하는 앱.

## 핵심 요약
- 문제/타깃/JTBD: 복잡한 자격 요건을 20–40대 실수 없이 빠르게 확인. “내 상황·집이 조건에 맞는지 즉시 알고, 다음 준비를 명확히.”
- 정책: 내부 문서만 근거, 외부 링크 미노출. ‘모름’ 하나라도 포함 시 최종 ‘불가(정보 부족)’. 마지막 확인일(last_verified) 노출.
- 범위: HUG 우선(전국/주택 유형 전반). HF/SGI는 후속.
- 수익화: 비간섭형 광고(결과/챗 하단, ‘광고’ 라벨).

## MVP 스냅샷
- 인테이크(10~12문, 분기 최대 14, ‘모름’ 포함) → 결과 카드(TL;DR/사유/다음 단계/last_verified) → Q&A.
- 추천: 한도 추정/서류 체크리스트/확인 방법.

## KPI(핵심)
- 완주율 ≥ 70%, 최초 판정 ≤ 90초, Q&A 진입 ≥ 50%, 만족도(👍) ≥ 70%.

## 참고 문서
- 요구사항: PRD_v1.md
- 인테이크: INTAKE_FLOW.md
- 규칙/매핑: RULES_HUG_v1.md, RULES_HUG_mapping.yaml
- UX/화면: UI_UX_GUIDE.md, APP_SCREEN_PLAN.md, SCREEN_SPECS.md
- 컴포넌트/토큰: COMPONENT_SPECS.md, UI_BLUEPRINT.yaml, DESIGN_TOKENS.yaml
- 측정/운영/법·광고: MEASUREMENT_PLAN.md, OPERATIONS_RUNBOOK.md, LEGAL_CHECKLIST.md, ADS_POLICY.md

> 상세 스펙·수용기준·엣지케이스는 PRD_v1.md에서 유지하며, 본 문서는 의사결정·핵심 범위만 요약합니다.
