# RULES_HUG_v1 — HUG 자격 판정 규칙(초안)

마지막 업데이트: 2025-09-02
주의: 본 문서는 내부 규정 문서(섹션/키) 기준으로 작성됩니다. 구체 임계값·예외는 내부 문서 값으로만 채웁니다(외부 링크 미사용).

## 규칙 체계(개요)
- 평가 순서: 결격 사유 → 필수 충족 요건 → 조건 확인 항목.
- 불확실 처리: 하나라도 ‘확인불가’이면 최종 결과는 ‘불가(정보 부족)’로 귀결.
- 출력: 가능 / 불가(정보 부족 포함). 사유 목록(충족/미충족/확인불가), 다음 단계, 마지막 확인일.

## 데이터 모델(요약)
- applicant: household_status, marital, dependents, income_type, income_band, employment_months, existing_loans, credit_flags
- property: type, floor_area_band, region, deposit_band, contract_status, movein_band, encumbrance
- special: youth, newlyweds, multi_children, low_income

## 규칙 카테고리

### C1. 결격 사유(즉시 불가)
- R-C1-001: 무주택 요건 불충족
  - if applicant.household_status in {‘1주택’, …} → DISQUALIFY
  - message_key: ineligible_household
  - source: INTERNAL(HUG.SectionA.1)
- R-C1-002: 중대한 신용 문제
  - if applicant.credit_flags in {‘장기연체’, ‘회생’, ‘파산’, ‘면책’} → DISQUALIFY
  - message_key: ineligible_credit
  - source: INTERNAL(HUG.SectionA.2)
- R-C1-003: 목적물 비허용 유형/면적 초과
  - if property.type in {‘비주거’, …} or floor_area over INTERNAL.THRESHOLDS.FLOORAREA → DISQUALIFY
  - message_key: ineligible_property_type_or_area
  - source: INTERNAL(HUG.SectionB.1)
- R-C1-004: 보증금 한도 초과
  - if property.deposit_band over INTERNAL.THRESHOLDS.DEPOSIT(region) → DISQUALIFY
  - message_key: deposit_over_limit
  - source: INTERNAL(HUG.SectionB.2)

### C2. 필수 충족 요건(모두 확인 필요)
- R-C2-001: 무주택+세대주 확인
  - require applicant.household_status == ‘무주택+세대주’ else UNKNOWN → 불가(정보 부족)
  - message_key: require_household_status
  - source: INTERNAL(HUG.SectionA.1)
- R-C2-002: 소득 형태/구간 확인
  - require applicant.income_type and applicant.income_band else UNKNOWN → 불가(정보 부족)
  - message_key: require_income_band
  - source: INTERNAL(HUG.SectionA.3)
- R-C2-003: 재직/사업 기간 확인
  - require applicant.employment_months != UNKNOWN else 불가(정보 부족)
  - message_key: require_employment_months
  - source: INTERNAL(HUG.SectionA.4)
- R-C2-004: 주택 유형/면적/지역/보증금 확인
  - require property.type, floor_area_band, region, deposit_band else 불가(정보 부족)
  - message_key: require_property_details
  - source: INTERNAL(HUG.SectionB)

### C3. 조건 확인(경고/주의)
- R-C3-001: 계약 전 상태
  - if property.contract_status == ‘계약 전’ → WARN only, 예비판정 가능(주의 문구)
  - message_key: pre_contract_warning
  - source: INTERNAL(HUG.SectionC.1)
- R-C3-002: 근저당 존재
  - if property.encumbrance == ‘있음’ → WARN or DISQUALIFY per INTERNAL rules
  - message_key: encumbrance_warning
  - source: INTERNAL(HUG.SectionC.2)

## 메시지 사전(예시 문안)
- ineligible_household: “무주택 요건을 충족하지 않아 신청이 불가합니다. 세대원/주택 보유 여부를 확인해주세요.”
- ineligible_credit: “최근 신용 이력으로 인해 신청이 불가합니다. 상세 내역 확인이 필요합니다.”
- ineligible_property_type_or_area: “해당 목적물 유형/면적은 보증 대상이 아닙니다.”
- deposit_over_limit: “전세보증금이 허용 한도를 초과합니다.”
- require_household_status: “무주택 및 세대주 여부가 확인되어야 합니다.”
- require_income_band: “소득 형태와 구간 확인이 필요합니다.”
- require_employment_months: “재직/사업 기간 정보를 입력해주세요.”
- require_property_details: “주택 유형/면적/지역/보증금 정보를 입력해주세요.”
- pre_contract_warning: “계약 전 상태로 예비판정입니다. 계약 체결 전 필수 확인 사항을 점검하세요.”
- encumbrance_warning: “등기상 근저당이 있어 주의가 필요합니다. 조건에 따라 불가가 될 수 있습니다.”

## 평가 의사코드(요약)
```
function evaluate(input):
  reasons = []
  unknown = []

  # C1: Disqualifiers
  for rule in C1:
    if rule.trigger(input):
      return Result(status='불가', tl_dr=make_tldr('결격 사유'), reasons=[rule.message_key], meta=meta())

  # C2: Required confirmations
  for field in REQUIRED_FIELDS:
    if is_unknown(input[field]):
      unknown.append(field)
  if unknown:
    return Result(status='불가', tl_dr=make_tldr('정보 부족'), reasons=label_unknowns(unknown), meta=meta())

  # C3: Warnings
  for rule in C3:
    if rule.trigger(input):
      reasons.append(rule.message_key)

  return Result(status='가능', tl_dr=make_tldr('가능'), reasons=reasons, meta=meta())
```

## 메타데이터
- last_verified: YYYY-MM-DD (내부 문서 최신화 기준)
- version: v1.0
- source_map: docs/RULES_HUG_mapping.yaml 를 참조하여 섹션/임계값을 주입

## 변경 이력
- 2025-09-02: 초기 규칙 체계/메시지 사전/의사코드 작성.
 - 2025-09-02: 매핑 파일 추가(docs/RULES_HUG_mapping.yaml) 및 참조 경로 명시.
