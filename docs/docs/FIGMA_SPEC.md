# FIGMA_SPEC — 디자인·핸드오프 사양(제품 중심)

마지막 업데이트: 2025-09-02
범위: HUG 자격 예비판정 + AI Q&A. 개발 아키텍처 언급 없음.
참조: COPY_GUIDE.md, INTAKE_FLOW.md, RESULT_CARD_COPY.md, RULES_HUG_v1.md, MEASUREMENT_PLAN.md, RAG_POLICY.md

## 파일 구조(Figma Pages)
- 00 Foundations: 컬러/타이포/간격/아이콘/그리드/토큰(Variables)
- 10 Components: 원자·분자 컴포넌트와 Variant, Props 문서화
- 20 Patterns: 인테이크 질문/결과 카드/챗 메시지 패턴
- 30 Screens: 온보딩/홈/인테이크/결과/챗/피드 화면
- 40 Prototypes: 사용자 흐름(탭·전환·오버레이) 연결
- 90 Archive: 폐기/히스토리

## 파운데이션(Variables)
- Color(semantic):
  - primary, onPrimary, surface, onSurface, success, warning, error, info, outline, badgeUnknown
- Typography(scale):
  - display, headline, title, body, label(각각 sm/md/lg). 줄간·자간 명시
- Spacing/Elevation/Radius:
  - spacing: 4pt scale(4/8/12/16/24/32…)
  - elevation: 0/1/2/4/8
  - radius: 4/8/12
- Grid:
  - Mobile Portrait 360×800 기준, 4/8pt 베이스, layout grid 4
- Iconography:
  - 24dp 기준. 내보내기: SVG. 아이콘 컴포넌트화

## 핵심 컴포넌트(Variants/Props)
- Comp/IntakeQuestion
  - props: qid(A1..S1), type(single|multi|numeric|text), state(default|error|unknown), helper, required(true/false)
  - variants: hasTooltip(true/false), hasUnknown(true/false)
- Comp/ResultCard
  - props: status(possible|not_possible_info|not_possible_disq), hasWarnings(true/false), lastVerified(date)
  - slots: TLDR(text), Reasons(list with icons), NextSteps(list), Meta(text)
- Comp/ChatBubble
  - props: role(user|bot), hasCitations(true/false)
  - slots: content(text), citations(docId/sectionKey chips)
- Comp/Badge
  - variants: unknown, lastVerified, info, warning
- Comp/Button
  - variants: primary/secondary/tertiary, size(md/sm), state(default/hover/pressed/disabled)
- Comp/Chip(Choice)
  - variants: selected/disabled, withIcon

## 패턴(문서화 보드)
- Pattern/Intake Flow: 질문 진행바, ‘모름’ 처리, 이전/다음 네비
- Pattern/Unknown Handling: 경고 토스트 + ‘확인 방법’ 시트
- Pattern/Reasons List: 충족/미충족/확인불가 아이콘 차등 표시
- Pattern/Next Steps: 체크리스트 스타일, 외부 링크 미표기 규칙

## 화면(프레임 명명 규칙)
- Naming: [PLAT]-[PAGE]-[STATE]-[BREAKPOINT]
  - ex) AND-INTAKE-DEFAULT-360, WEB-RESULT-POSSIBLE-1280
- Onboarding: 약관·고지 → 프로필(선택)
- Home: 검색바 + 주제 카드(자격/한도/서류/절차)
- Intake: A1..S1 질문(최대 14), 진행바 표시
- Result: 가능 / 불가(정보 부족/결격) 카드 + 후속 CTA
- Chat: 질문 입력 → 답변(요약/근거 chips/다음 단계)
- Feed(옵션): 정책 변경 요약 카드

## 프로토타입(Interaction)
- 링크: Home→Intake→Result→Chat 주요 흐름
- 트리거: tap/click, Enter to send, overlay(bottom sheet) for ‘확인 방법’
- 애니메이션: smart animate 150–250ms, easing standard

## 레드라인/핸드오프
- Auto Layout: 모든 컨테이너 8pt 간격 규칙 준수
- 최소 터치 타깃: 44×44
- 대비: 본문 4.5:1 이상, 버튼 3:1 이상
- Safe Area: 상단/하단 인셋 고려(모바일)
- Export: 아이콘/일러스트 SVG, 비트맵은 2x/3x 필요 시
- Dev Notes(Dev Mode):
  - Flutter 기준 dp 단위, spacing token 매핑(4,8,12…)
  - 컬러/타입 토큰 이름 → Theme mapping 표기

## 카피/콘텐츠 연계
- COPY_GUIDE 문구를 컴포넌트에 바인딩(예: TL;DR, 고지)
- RESULT_CARD_COPY의 변수 자리: 텍스트 스타일과 바인딩 명시
- INTAKE_FLOW의 qid를 질문 컴포넌트 prop으로 표기

## 계측 태깅(디자인 주석)
- 스티커 표기 규칙:
  - event:intake_answer qid=A1
  - event:ruling_shown status=not_possible_info
  - event:qna_ask topic=docs
- 해당 스티커를 컴포넌트 옆에 부착, MEASUREMENT_PLAN 키와 1:1 매핑

## 접근성 체크리스트
- Focus order, 키보드 탭 이동(웹 고려)
- 동적 폰트 크기 확대 시 레이아웃 붕괴 방지
- 에러/경고 아이콘에 텍스트 대체 제공

## 베리에이션/엣지 사례
- 초과 길이 TL;DR 3줄 말줄임
- 긴 이유 목록 5개 이상 시 접기/펼치기
- Unknown만 다수일 때 전용 Empty 상태

## 산출물 체크리스트(DoD)
- Foundations 변수 완성(컬러/타입/스페이싱)
- 컴포넌트 Variant/Props 문서화 완료
- 주요 화면 6종(온보딩/홈/인테이크/결과×3/챗) 완료
- 프로토타입 링크 연결, 이벤트 태깅 주석 부착
- Dev Mode 노트 및 토큰 매핑 표기

## 변경 이력
- 2025-09-02: 초기 작성
