# MEASUREMENT_PLAN — 측정/계측 계획
Status: canonical (Analytics Schema)

마지막 업데이트: 2025-09-02

## 목표 지표(KPI)
- 퍼널: 판정 완주율, 최초 판정까지 평균 시간
- 품질: 결과 만족(👍) 비율, “사유 보기” 클릭률, 정정 요청률
- 리텐션: 후속 Q&A 진입률, D1/D7 재방문

## 이벤트 스키마(초안)
- intake_start: { session_id, ts }
- intake_answer: { qid, answer, is_unknown, ts }
- intake_complete: { question_count, duration_ms, has_unknown, result_status, ts }
- ruling_shown: { status, reasons_count, unknown_count, ts }
- reasons_expand: { ts }
- next_step_click: { action: checklist|howto|limit_estimate|similar_cases, ts }
- qna_ask: { topic, length, ts }
- qna_answer: { has_disclaimer, last_verified, ts }
- feedback_thumb: { updown, context: ruling|qna, ts }
- correction_request: { context, reason, ts }

필드 설명
- qid: A1..A7 / P1..P7 / S1 등 INTAKE_FLOW와 동일 식별자
- status: possible | not_possible_info_lack | not_possible_disqualifier

## 퍼널 정의
- F1: intake_start → intake_complete → ruling_shown
- 세부: 평균 질문 수, 평균 소요, unknown 포함 비율

## 대시보드 뷰(제안)
- Today: 주요 KPI(완주율/시간/만족도)
- Unknown Top: 확인불가 상위 항목(A?/P?)
- Disqualify Top: 결격 사유 상위 규칙
- Retention: D1/D7, 후속 Q&A 진입률

## 타깃(초안)
- 완주율 ≥ 70%, 평균 ≤ 90초, 👍 ≥ 70%, D7 ≥ 25%

## 운영 정책
- 이벤트 개인정보 미수집(세션/익명 ID). 내부 문서 최신일(마지막 확인일)만 노출.
- 측정 스키마 변경 시 버전 필드 추가: schema_version

## 변경 이력
- 2025-09-02: 초기 작성.
