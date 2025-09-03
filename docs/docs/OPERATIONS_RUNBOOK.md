# OPERATIONS_RUNBOOK — 운영 런북(규정 갱신/정정/핫픽스)
Status: canonical (Operations)

마지막 업데이트: 2025-09-02

## 1) 규정 갱신 프로세스
1. 소스 확인: 내부 문서 개정(개정일/버전) 수신
2. 매핑 업데이트: docs/RULES_HUG_mapping.yaml 섹션/임계값 수정
3. 검토: 변경 포인트 요약 → 카피 영향 점검(COPY_GUIDE, RESULT_CARD_COPY)
4. last_verified 갱신: PRODUCT_BRIEF.md/관련 문서 일괄 업데이트
5. QA: 시나리오 20개 회귀 테스트 → 승인

## 2) 긴급 핫픽스(정책 변경/오류)
1. 영향도 판별: 결격/한도/비허용 유형 관련이면 긴급
2. 임시조치: 의심 규칙을 보수적으로 ‘확인불가→불가(정보 부족)’로 강등
3. 공지: 릴리스 노트/배지 표시(정보 최신성 확인 필요)
4. 본수정: 매핑/카피 확정 후 회귀 테스트 → 배포

## 3) 정정 요청 처리
1. 접수: 앱 내 폼 → 운영 인박스
2. 확인: 내부 문서 대조, 사실 오류/문구 개선 분류
3. 조치: 규칙/카피 반영 또는 거절 사유 회신
4. 기록: 변경 이력 업데이트

## 4) KPI 모니터링 루틴
- 일일: 완주율/시간/👍/Unknown Top/Disqualify Top
- 주간: 리텐션, Q&A 참여율, 광고 지표
- 임계 초과 시 액션: Unknown↑ → ‘확인 방법’ 가이드 강화, 질문 순서 조정

## 5) 릴리스 체크리스트(요약)
- 규정 최신성 30일 이내 / last_verified 반영
- 카피/고지 최신본 적용(COPY_GUIDE)
- 이벤트 스키마/대시보드 업데이트(MEASUREMENT_PLAN)
- 광고 정책 준수(ADS_POLICY)

## 6) 문서 버전 관리
- RULES_HUG_v1.md / RULES_HUG_mapping.yaml: version 필드, 변경 이력 유지
- PRODUCT_BRIEF.md/PRD_v1.md: 주요 결정 변경 시 업데이트

## 변경 이력
- 2025-09-02: 초기 작성.
