# RAG_POLICY — 내부 문서 기반 검색/답변 정책

마지막 업데이트: 2025-09-02

## 원칙
- 소스 오브 트루스: 오직 제공된 내부 문서만 사용(외부 링크/웹 검색 금지).
- 근거 제시: 답변마다 문서 식별자와 섹션/키를 표기(링크 미노출).
- 최신성: ‘마지막 확인일’(last_verified)을 항상 노출. 임계(기본 30일) 초과 시 경고 배지.
- 불확실/부재: 일치 결과가 부족하면 ‘확인불가’로 명시하고 판정은 불가로 처리.

## 검색/판단 흐름(제품 관점)
1) 쿼리 전처리: 의도 추출(자격/목적물/한도/서류/절차/용어 등).
2) 내부 검색: 문서→섹션 키워드 매칭(top-k, 기본 3개) 및 점수 산출.
3) 임계값 판단: 최소 신뢰 임계 미만이면 ‘확인불가’로 응답(추정 금지).
4) 충돌 해소: 최신 개정(문서 버전/개정일)이 우선. 동점이면 보수적으로 ‘확인불가’.
5) 요약 생성: 실용 요약 톤(TL;DR → 조건/예외 → 다음 단계), 수치/조건은 원문 그대로 유지.
6) 메타 부가: last_verified, 문서 식별자/섹션 키, 내부 규정 버전.

## 인용 포맷(링크 없음)
- 출처: {doc: {{doc_id}}, section: {{section_key}}}
- 예: 출처: {doc: HUG_internal_policy.md, section: A.1}

## 불확실 처리
- 매칭 결과 없음/저신뢰: ‘확인불가’ 표기 + 확인 방법 안내 → 판정은 불가(정보 부족).
- 회색지대: 상충/비문 일치 시 보수적으로 ‘확인불가’.

## 최신성 규칙
- 기준: docs/RULES_HUG_mapping.yaml 의 last_verified 사용.
- 임계: 30일 초과 시 ‘정보 최신성 확인 필요’ 배지 노출.

## 텔레메트리(측정 연계)
- retrieval_query: { intent, ts }
- retrieval_results: { topk, best_score, below_threshold, ts }
- retrieval_abstain: { reason: no_match|low_conflict|stale, ts }

## 운영/갱신
- 매핑: RULES_HUG_mapping.yaml 의 section/key/임계값을 갱신하면 즉시 반영.
- 문서 추가: documents.primary.file 갱신 또는 documents 배열 확장(멀티 문서 지원).
- 용어/카피: QNA_TEMPLATES.md, RESULT_CARD_COPY.md 에 반영.

## 수용기준(샘플)
- Given 내부 문서에 해당 규정이 없음,
  When 유저가 관련 규정을 질문,
  Then 답변은 ‘확인불가’로 표시하고 확인 방법을 안내한다(추정/추측 금지).

- Given 내부 문서의 두 섹션이 상충,
  When 답변 생성,
  Then 최신 개정 기준을 우선하고, 판정에 직접 영향 시 보수적으로 ‘확인불가’ 처리한다.

- Given last_verified 가 30일 초과,
  When 답변 렌더링,
  Then ‘정보 최신성 확인 필요’ 배지를 노출한다.

## 변경 이력
- 2025-09-02: 내부문서 기반 RAG 정책 초안 작성.
