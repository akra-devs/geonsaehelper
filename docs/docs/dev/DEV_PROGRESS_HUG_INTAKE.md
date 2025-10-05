# HUG 기반 인테이크/판정 — 진행 현황과 다음 단계

last_updated: 2025-09-10
owner: convo/intake

## 배경
- 기존 프로토타입 인테이크(임의 구간/라벨)를 HUG 정책 기반(내부 문서)으로 재설계/구현.
- 목표: 예비판정 정확도·완주율·속도 개선(≤90s), ‘모름→불가(정보 부족)’ 일관 처리, 출처 메타 유지.

## 설계 원칙
- 규칙 우선순위: 결격(C1) → 필수 확인(C2) → 조건/경고(C3)
- ‘모름’ 포함 시 최종 판정은 불가(정보 부족), 해당 항목 ‘확인불가’ 표기
- 내부 문서만 근거(RAG), citations {docId, sectionKey} 부착, last_verified 노출(+30일 배지)

## 현재 구현 상태 (Done)
- 질문 세트(12 + 분기)
  - A1 세대주, A2 무주택, A3 나이(성년/청년), A4 혼인(신혼), A5 출산(신생아 특례)
  - A6 소득(≤5천/≤6천/≤7.5천/≤1.3억/≤2억/초과), A7 자산(≤3.37/≤4.88/초과)
  - A8 맞벌이(신생아 특례용), A9 자녀 수(2자녀 이상 우대), A10 우대 사유(혁신도시/이주·재개발/위험건축물)
  - C1 결격(신용·공공임대), C2 중복대출(기금 전세/은행 전세/주담대)
  - P1 계약+5%, P2 지역, P3 주택 유형, P5 보증금, P7 근저당
  - 분기: P4 면적, P4a 읍·면(86–100㎡만), S1 피해자, S1a 임차권등기(S1=예), A8(A5=예일 때), A9/A10(A6=≤6천일 때)
  - 모든 질문 ‘모름’ 제공
- 브랜칭/판정 로직(Bloc)
  - C1/C2(미성년/무주택 미충족/신용·공공임대/중복대출/소득·자산 초과) → 불가(결격)
  - 대상 주택 불가, 면적 초과(읍·면 예외 포함) → 불가(결격)
  - 지역×보증금 상한(표준: 수도권 3억/비수도권 2억, 신혼: 4억/3억)
    - 신생아 특례: 수도권 3억 초과 결격(대출 2.4억≈보증금 3억 기준)
    - 청년 전용: 1.5억 경계(1.5~2.0억 정보부족)
    - 전세피해자: 수도권 3~5억/비수도권 3~4억 경계는 정보부족
    - 신혼 예외: 수도권 3~4억 경계는 정보부족
  - ‘모름’ 포함 시 → 불가(정보 부족) + 확인 가이드
- RAG/출처
  - Reason에 SourceRef(list) 부착(문서/섹션 키). HUG_POLICY_DOCS 기반 섹션으로 정합화
  - 정적 매핑: `rule_citations.dart` (household/credit/property/area/deposit_upper_bound/income/asset/damages/youth/newly/newborn/encumbrance/duplicateLoans)
- 결과 카피
  - TL;DR: “{지역} {유형}은(는) ‘해당’합니다.” + 최대 2줄 특례 힌트(피해자 → 신생아 → 신혼 → 청년)
  - 다음 단계: 특례별(피해자/신생아/신혼) 준비물 선반영 + 공통 체크리스트
  - 사유: 충족/미충족/확인불가 + 프로그램별 한 줄(청년/신혼/신생아/피해자)
- UI/이벤트
  - ResultCard: last_verified 배지/사유·다음단계 토글, 토글/클릭 로깅(reasons_expand, next_step_click)
  - ChatBubble: citations 칩 표시(Q&A 서버 응답 + 판정 사유 기반 제안 답변에 삽입)
- 규정 매핑 파일
  - `docs/docs/RULES_HUG_mapping.yaml` → HUG_POLICY.md 기준으로 갱신(면적/보증금 상한 기본값, 계약 5% 경고)

## 커버리지 메모(문서 ↔ 구현)
- 표준(버팀목): 세대주·무주택/면적/유형/보증금 상한/소득(5천, 일부 6천 우대)/자산(3.37억) 반영
- 신혼: 소득 7.5천, 보증금 상한(4억/3억) 예외 반영
- 청년: 소득 5천, 보증금 1.5억 경계 반영
- 신생아 특례: 소득 1.3억(맞벌이 2억), 보증금 3억 기준 반영
- 전세피해자: 보증금 경계(수도권 3~5억/비수도권 3~4억) 정보부족 처리
- 근저당: 경고 사유(P7)
- 중복대출 금지: 결격(C2)

## 주요 코드 변경 파일
- 질문/로직
  - `lib/features/conversation/domain/question_flow.dart` — HUG형 질문/브랜칭(P4/P4a/S1a)
  - `lib/features/conversation/bloc/conversation_bloc.dart` — 브랜치 스킵, C1/C2/C3 판정, 지역+보증금/면적 예외, TL;DR·다음단계 생성, citations 부착
  - `lib/features/conversation/domain/rule_citations.dart` — QID→출처 매핑(신규)
  - `lib/features/conversation/domain/models.dart` — `Reason.sources`·`SourceRef` 추가
- UI/분석
  - `lib/ui/components/result_card.dart` — 토글 로깅/next step 클릭/프로그램 배지
  - `lib/common/analytics/analytics.dart` — `reasonsExpand()` 추가
  - `lib/features/conversation/ui/conversation_page.dart` — Q&A citations 표출(서버 응답)
- 문서/정책
  - `docs/docs/HUG_POLICY_DOCS/*` — 소스(참조)
  - `docs/docs/RULES_HUG_mapping.yaml` — 정규화 문서 기준으로 매핑 갱신

## 방향 전환(Program-based)
- 목표: “어떤 HUG 프로그램이 가능한지”를 프로그램 리스트로 명시(가능/정보부족/결격)
- 정책 변경: ‘모름’은 프로그램 단위로 적용(필수 필드 모름 → 해당 프로그램만 정보부족)
- TL;DR: 가능한 프로그램 요약(우선순위/추천 경로) + 프로그램별 상세 섹션

## 향후 진행 계획 (Next)
- [ ] RulesEngine 리팩터: 프로그램별 평가 구조 도입(ProgramId/ProgramResult)
- [ ] UI 확장: ResultCard에 ProgramMatches 섹션 추가(설계는 COMPONENT_SPECS 참조)
- [ ] 카피: RESULT_CARD_COPY에 프로그램 요약/행 템플릿 반영(초안 완료)
- [ ] 측정: program_* 이벤트 추가(측정 문서 갱신 완료)
- [ ] 상한/예외 정밀화(잔여):
  - 비수도권 세분(광역시 vs 기타) 필요 시 규칙 추가
  - 우대 항목 추가(추가 우대·취약군) 검토 및 질문 확장(옵션)
- [ ] QA/회귀(20+ 케이스): 경계/특례/모름/결격/지역×보증금 조합

## 운영/도구 메모
- last_verified 단일 소스: `docs/docs/RULES_HUG_mapping.yaml:last_verified`
- 동기화 스크립트: `dart run tool/sync_last_verified.dart` → `constants.rulesLastVerifiedYmd` 갱신
- 문서 경로 표준화: citations는 `HUG_POLICY_DOCS/*.MD` 섹션 키 사용

## 운영 가이드
- 빌드/검사: `flutter analyze` / `dart format .` / `flutter test`
- 실행(웹): `flutter run -d chrome`
- 정책 갱신 플로우(Ops):
  1) `docs/docs/HUG_POLICY_DOCS/*` 갱신
  2) `docs/docs/RULES_HUG_mapping.yaml` 검토/수정
  3) last_verified 갱신(문서/앱 결과)
  4) 회귀 테스트(20 케이스)

## 참고 링크
- PRD/정책/인테이크/카피/측정 문서 일람: `docs/docs/DOCS_INDEX.md`
- 결과 카드 카피 가이드: `docs/docs/RESULT_CARD_COPY.md`
- RAG 정책: `docs/docs/RAG_POLICY.md`
