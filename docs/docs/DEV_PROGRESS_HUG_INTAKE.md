# HUG 기반 인테이크/판정 — 진행 현황과 다음 단계

last_updated: 2025-09-08
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
  - A1 세대주, A2 무주택, A3 나이(성년/청년), A4 혼인(신혼), A5 출산(신생아 특례), A6 소득, A7 자산, C1 결격(신용/공공임대)
  - P1 계약+5%, P2 지역, P3 주택 유형, P5 보증금
  - 분기: P4 면적, P4a 읍·면(86–100㎡만), S1 피해자, S1a 임차권등기(S1=예)
  - 모든 질문 ‘모름’ 제공
- 브랜칭/판정 로직(Bloc)
  - C1(미성년/무주택 미충족/결격/소득·자산 초과) → 불가(결격)
  - 대상 주택 불가, 면적 초과(읍·면 예외 포함) → 불가(결격)
  - 지역+보증금 상한(수도권 3억/신혼 4억, 비수도권 2억/신혼 3억). 경계구간은 보수적으로 정보 부족
  - ‘모름’ 포함 시 → 불가(정보 부족) + 확인 가이드
- RAG/출처
  - Reason에 SourceRef(list) 부착(문서/섹션 키)
  - 정적 매핑: `rule_citations.dart` (household/credit/property/area/region/income/asset/damages/youth/newly/newborn)
- 결과 카피
  - TL;DR: “{지역} {유형}은(는) ‘해당’합니다.” + 최대 2줄 특례 힌트(피해자 → 신생아 → 신혼 → 청년)
  - 다음 단계: 특례별(피해자/신생아/신혼) 준비물 선반영 + 공통 체크리스트
  - 사유: 충족/미충족/확인불가 + 프로그램별 한 줄(청년/신혼/신생아/피해자)
- UI/이벤트
  - ResultCard: last_verified 배지/사유·다음단계 토글, 토글/클릭 로깅(reasons_expand, next_step_click)
  - ChatBubble: citations 칩 표시(Q&A 서버 응답 기반)
- 규정 매핑 파일
  - `docs/docs/RULES_HUG_mapping.yaml` → HUG_POLICY.md 기준으로 갱신(면적/보증금 상한 기본값, 계약 5% 경고)

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

## 향후 진행 계획 (Next)
- [ ] 프로그램별 카피 정제(톤/단문):
  - 가능 TL;DR에 상황별 한 줄 추가(선택): “신혼 경로 우선 검토 권장” 등
  - 사유 문구를 결과 카드 템플릿(`RESULT_CARD_COPY.md`)에 더 가깝게 다듬기
- [ ] 상한/예외 정밀화:
  - 비수도권 세분(광역시 vs 기타) 필요 시 규칙 추가
  - 신혼 외 예외(2자녀 상향 등) 분기 반영(질문 보강 필요 여부 검토)
- [ ] Q&A 연동 강화:
  - 판정 사유의 `Reason.sources` → Q&A 후속 답변에도 선택적으로 삽입(근거 강화)
  - 판정→Q&A 질문 템플릿 연계(FAQ/다음 단계 링크)
- [ ] QA/회귀(20 케이스):
  - 경계값(보증금/면적/연령), 특례 라우팅, 모름 포함, 결격 조합, 지역×보증금 조합
  - 이벤트 로깅 정상 여부 확인(퍼널/토글/클릭)
- [ ] 데모/카피 스냅샷 갱신:
  - `demo_gallery.dart` 예제 라벨 전반 동기화(현재 A1만 교정됨)

## 운영 가이드
- 빌드/검사: `flutter analyze` / `dart format .` / `flutter test`
- 실행(웹): `flutter run -d chrome`
- 정책 갱신 플로우(Ops):
  1) `docs/docs/HUG_POLICY_DOCS/*` 갱신
  2) `rules_mapping.yaml` 검토/수정
  3) last_verified 갱신(문서/앱 결과)
  4) 회귀 테스트(20 케이스)

## 참고 링크
- PRD/정책/인테이크/카피/측정 문서 일람: `docs/docs/DOCS_INDEX.md`
- 결과 카드 카피 가이드: `docs/docs/RESULT_CARD_COPY.md`
- RAG 정책: `docs/docs/RAG_POLICY.md`

