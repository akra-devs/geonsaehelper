# DEV_TODO_HUG_INTAKE — HUG 인테이크/판정 TODO 체크리스트

last_updated: 2025-09-08
owner: convo/intake

본 문서는 HUG 기반 인테이크/판정 구현의 작업 항목을 일람표 형태로 관리합니다. 각 항목은 내부 문서(HUG_POLICY_DOCS/*, RULES_HUG_mapping.yaml)를 단일 근거로 삼습니다.

## Milestone A — 규칙/컷 정합화(완)
- [x] citations 정합화: HUG_POLICY_DOCS 하위 파일/섹션으로 일원화
- [x] A1 세대주 요건 결격 처리(세대원=불가)
- [x] 소득 컷(프로그램별) 적용: 신생아(1.3억/맞벌이 2억) > 신혼(7.5천) > 청년(5천) > 표준(5천; 우대/2자녀=6천)
- [x] 자산 컷(임차 공통) 적용: 3.37억 초과 결격
- [x] 보증금 상한 경계 처리:
  - 표준/신혼: 수도권 3억(신혼 4억), 비수도권 2억(신혼 3억); 경계(3~4/2~3)는 정보부족
  - 청년: 1.5억 경계(1.5~2.0억 정보부족)
  - 신생아: 수도권 3억 초과 결격(대출 2.4억≈보증금 3억)
  - 피해자: 수도권 3~5억/비수도권 3~4억 경계 정보부족
- [x] P7(근저당) 질문 추가 + 경고 Reason 연결
- [x] C2(중복대출) 결격 분기 추가(기금전세/은행전세/주담대)

## Milestone B — 잔여 정밀화(진행)
- [ ] 지역 세분(비수도권 내 ‘광역시 vs 기타’) 필요 시 분기 확장
- [ ] 청년/특례의 지역별 한도 차이 추가 검토(문서상 차등 존재 시 반영)
- [ ] 신혼/다자녀 등 추가 우대 항목 검토(필요 시 질문 확장)
- [ ] 보증기관·담보별 세부 한도(설명/툴팁 수준) UI 가이드 추가

## Milestone C — Q&A 연동 강화(진행)
- [x] 제안 답변(스마트 버튼) 시 판정 사유 citations 최대 3개 삽입
- [ ] 서버 Q&A 응답의 citations 스키마 정합성 점검(섹션키 표준화)
- [ ] 판정→Q&A 템플릿(FAQ/다음 단계 링크) 연결 규칙 정리

## Milestone D — UI/Copy(진행)
- [x] RESULT_CARD_COPY 템플릿에 맞춘 TL;DR/사유/다음 단계 정렬(3줄 TL;DR)
- [x] 결과 카드 하단 ‘예비판정/자문 아님’ 고지 추가
- [ ] 특례별 TL;DR 보조 한 줄(피해자/신생아/신혼/청년) 카피 다듬기

## Milestone E — Demo 스냅샷(진행)
- [x] A1/A2/A8/A9/A10/P3/P7 IntakeQuestion 예시 추가
- [ ] 경계 시나리오(ResultCard) 샘플 추가: 
  - [ ] 수도권 신혼 3~4억 정보부족 카드
  - [ ] 청년 1.5~2.0억 정보부족 카드
  - [ ] 피해자 3~5억(수도권)/3~4억(비수도권) 정보부족 카드
  - [ ] 신생아 수도권 3억 초과 결격 카드

## Milestone F — Ops/도구(진행)
- [x] last_verified 단일 소스 유지: docs/docs/RULES_HUG_mapping.yaml:last_verified
- [x] 동기화 스크립트: `dart run tool/sync_last_verified.dart`
- [ ] CI에 last_verified 동기화/검증 훅 추가(선택)
- [ ] 문서 경로/섹션키 표준 체크(스키마 린트) 스크립트(선택)

## 코드 기준/참조 경로
- 규칙/분기: `lib/features/conversation/bloc/conversation_bloc.dart`
- 질문 정의: `lib/features/conversation/domain/question_flow.dart`
- 출처 매핑: `lib/features/conversation/domain/rule_citations.dart`
- 결과 카드: `lib/ui/components/result_card.dart`
- 데모: `lib/ui/demo/demo_gallery.dart`
- 정책 소스: `docs/docs/HUG_POLICY_DOCS/*`
- 매핑/메타: `docs/docs/RULES_HUG_mapping.yaml`

## 수용 기준(각 항목 공통)
- 내부 문서(HUG_POLICY_DOCS/*, RULES_HUG_mapping.yaml)와 수치/문구 일치
- 경계 구간은 ‘정보부족’ 처리 + 확인 방법(next steps) 제공
- 결과 Reason에 citations {docId, sectionKey} 부착, 외부 링크/추정 금지
- last_verified UI 표기(30일 초과 시 배지 노출)

## 변경 로그 포맷(권장)
- feat(rules): … / fix(theme): … / chore(demo): … / docs(progress): …

