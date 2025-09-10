# RULES_HUG_v1 — HUG 자격 판정 규칙(초안)
Status: canonical (Eligibility Rules). Data: RULES_HUG_mapping.yaml

마지막 업데이트: 2025-09-10
주의: 본 문서는 내부 규정 문서(섹션/키) 기준으로 작성됩니다. 구체 임계값·예외는 내부 문서 값으로만 채웁니다(외부 링크 미사용).

## 규칙 체계(개요)
- 평가 순서(프로그램 단위): 결격 사유(C1) → 필수 확인(C2) → 조건/경고(C3).
- 불확실 처리: 특정 프로그램에 필요한 필드에 ‘모름’이 있으면 그 프로그램만 ‘정보부족’ 처리.
- 출력: 프로그램별 [가능 | 정보부족 | 결격] + 사유(충족/미충족/확인불가) + 다음 단계 + 마지막 확인일.

## 데이터 모델(요약)
- applicant: household_status, marital, dependents, income_type, income_band, employment_months, existing_loans, credit_flags
- property: type, floor_area_band, region, deposit_band, contract_status, movein_band, encumbrance
- special: youth, newlyweds, newborn, damages, favored_6k
- program: ProgramId(표준/신혼/청년/신생아/피해자), ProgramResult(status, reasons[], next_steps[], citations[])

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

## 평가 의사코드(프로그램 단위)
```
PROGRAMS = [RENT_DAMAGES, RENT_NEWBORN, RENT_NEWLYWED, RENT_YOUTH, RENT_STANDARD]

function evaluate_all(input):
  results = []
  for prog in PROGRAMS:
    r = evaluate_program(prog, input)
    results.append({ 'program': prog, 'result': r })

  eligible = [x for x in results if x.result.status == 'eligible']
  info_needed = [x for x in results if x.result.status == 'info_needed']
  ineligible = [x for x in results if x.result.status == 'ineligible']

  summary = summarize(eligible, info_needed, ineligible)
  return { 'summary': summary, 'program_results': results, 'meta': meta() }

function evaluate_program(prog, input):
  # C1: Disqualifiers first
  for rule in C1[prog]:
    if rule.trigger(input):
      return ProgramResult(status='ineligible', reasons=[rule.message_key], citations=rule.citations)

  # C2: Required confirmations (program-specific fields)
  unknown_fields = []
  for field in REQUIRED_FIELDS[prog]:
    if is_unknown(input[field]):
      unknown_fields.append(field)
  if unknown_fields:
    return ProgramResult(status='info_needed', reasons=label_unknowns(unknown_fields))

  # C3: Conditions/Warnings
  reasons = []
  for rule in C3[prog]:
    if rule.trigger(input):
      reasons.append(rule.message_key)

  return ProgramResult(status='eligible', reasons=reasons)
```

## 메타데이터
- last_verified: YYYY-MM-DD (내부 문서 최신화 기준)
- version: v1.0
- source_map: docs/docs/RULES_HUG_mapping.yaml 를 참조하여 섹션/임계값을 주입

## 변경 이력
- 2025-09-02: 초기 규칙 체계/메시지 사전/의사코드 작성.
- 2025-09-10: 프로그램 단위 평가 모델로 개정(프로그램별 C1/C2/C3 적용, per-program unknown 처리).
