# Repository Guidelines

## Project Structure & Module Organization
- App code: `lib/`
  - `ui/theme/`: design system and Theme extensions
  - `ui/components/`: reusable widgets (ResultCard, IntakeQuestion, ChatBubble)
  - `ui/demo/`: `DemoGallery` to preview components
  - Recommended next: `features/<feature>/{ui,bloc,data}` per docs
- Tests: `test/`
- Docs: `docs/docs/` (PRD, rules, UI blueprints, copy templates)

## Build, Test, and Development Commands
- Install deps: `flutter pub get`
- Run (web example): `flutter run -d chrome`
- Analyze: `flutter analyze` (lints configured via `analysis_options.yaml`)
- Format: `dart format .`
- Test: `flutter test`
- Codegen (if Freezed/JSON models are added):
  `dart run build_runner build --delete-conflicting-outputs`

## Coding Style & Naming Conventions
- Language: Dart, 2-space indentation, trailing commas where helpful.
- Files: `snake_case.dart`; classes `PascalCase`; methods/fields `lowerCamelCase`.
- Widgets: keep small and composable; extract into `ui/components/` when reused.
- Features: `lib/features/<feature>/{ui,bloc,data}`; BLoC files `*_bloc.dart`, events `*_event.dart`, states `*_state.dart`.

## Testing Guidelines
- Framework: `flutter_test` (unit and widget tests).
- Naming: mirror source path, e.g., `test/ui/components/result_card_test.dart`.
- Prefer widget tests for UI components; mock repositories for BLoC tests.
- Run locally with `flutter test`; keep tests deterministic and fast.

## Commit & Pull Request Guidelines
- Commits: use Conventional Commits when possible
  - Examples: `feat(ui): add ResultCard`, `fix(theme): correct color contrast`, `docs: update PRD links`.
- PRs: include concise description, motivation, screenshots/GIFs for UI, and linked issue (e.g., `Closes #123`). Ensure `flutter analyze` and tests pass.
 - 작업 단위당 커밋: 하나의 논리적 작업(파일 추가/기능 단위/리팩터링 단위)마다 최소 1 커밋으로 쪼개어 기록합니다.

## Architecture Notes
- Follow one-way deps: UI → BLoC → Repository → Data sources.
- Centralize theme and design tokens; avoid inline styling where a token exists.
- Prefer dependency injection via providers at app bootstrap.

**Product Context**
- 목적: HUG 전세자금대출 자격(본인·목적물) 예비판정 후, 후속 AI Q&A 제공.
- 범위: HUG 우선 적용, 전국/주택 유형 전반. 외부 링크 미노출, 내부 문서만 근거.
- 페르소나: 첫 전세 준비 직장인(20–30대) 중심, 신혼/청년 특례 관심.
- KPI: 완주율 ≥ 70%, 최초 판정 ≤ 90초, 만족도(👍) ≥ 70%, Q&A 진입 ≥ 50%.

**Core Rules (HUG)**
- 판정 상태: 가능 | 불가(정보 부족) | 불가(결격).
- ‘모름’: 하나라도 포함되면 최종 판정은 불가(정보 부족)로 귀결, 해당 항목에 ‘확인불가’ 라벨.
- 규칙 우선순위: 결격(C1) → 필수 확인(C2) → 조건 확인/경고(C3).
- 결과 표시: TL;DR 2–3줄 → 사유(충족/미충족/확인불가) → 다음 단계(체크리스트·확인 방법) → 마지막 확인일.
- 최신성: last_verified 표기 필수, 30일 초과 시 ‘정보 최신성 확인 필요’ 배지.

**AI Answer Policy (RAG)**
- 내부 문서만 근거: 외부 검색/링크 금지. 불확실 시 ‘확인불가’로 응답(추정 금지).
- 출처 메타: {doc: 문서ID, section: 섹션키} 형태로 표기(링크 미노출).
- 요약 톤: 실용 요약(TL;DR → 조건/예외 → 다음 단계). 수치/조건은 원문 그대로.

**UX Flows & Copy**
- 인테이크: 10~12문(분기 최대 14), 모든 질문에 ‘모름’ 제공. 식별자 A1..A7, P1..P7, S1.
- 결과 카드: 가능/불가 상태, TL;DR·사유·다음 단계·last_verified, 고지(예비판정/자문 아님).
- 카피 톤: 명확/중립/친절, 과장·추정 금지. 확인 방법 버튼 제공.

**UI Components (specs)**
- `IntakeQuestion`: `qid`, `label`, `options`, `selected`, `showUnknown=true`, `onChanged`, `helper`, `errorText`.
- `ResultCard`: `status(possible|notPossibleInfo|notPossibleDisq)`, `tldr`, `reasons`, `nextSteps`, `lastVerified`, `onExpand`.
- `ChatBubble`: `role(user|bot)`, `content`, `citations[{docId,sectionKey}]`.
- 테마: 디자인 토큰 사용(간격/라운드/색), 하드코딩 지양. A11y/Keys 제공.

**Measurement (events)**
- 핵심 이벤트: `intake_start`, `intake_answer{qid, is_unknown}`, `intake_complete{has_unknown, result_status}`, `ruling_shown{status}`, `reasons_expand`, `next_step_click`, `qna_ask`, `qna_answer`, `feedback_thumb`, `correction_request`.
- 퍼널: intake_start → intake_complete → ruling_shown. 목표: 평균 ≤ 90초, 완주율 ≥ 70%.

**Operations & Freshness**
- 규정 갱신: RULES_HUG_mapping.yaml 업데이트 → last_verified 갱신 → 회귀 테스트(20케이스) → 배포.
- 충돌/불확실: 보수적으로 ‘확인불가’ 처리. 임계 초과(30일) 시 최신성 배지 노출.
- 핫픽스: 영향도 높음 시 의심 규칙을 임시 ‘확인불가→불가(정보 부족)’로 강등.

**Ads & Legal**
- 광고: 결과/Q&A 하단 1개씩, 스크롤 후 노출, ‘광고’ 라벨, 전면/팝업 금지.
- 법적 고지: 예비판정/자문 아님/마지막 확인일 표기. 고위험 광고 차단.
- 개인정보: 민감정보 미수집(세션/익명 ID만). 판정 히스토리는 로컬 우선.

**Do/Don’t (Agent)**
- Do: 내부 문서만으로 답변, 출처 메타 표기, ‘모름’→불가(정보 부족) 일관 처리, TL;DR 우선.
- Do: 디자인 토큰·컴포넌트 스펙 준수, 이벤트 로깅 포인트 유지, last_verified 노출.
- Don’t: 외부 링크/추정 제공, 결격·임계값 임의 확장, 핵심 정보 흐름을 방해하는 UI 변경.

**Key References**
- PRD: `docs/docs/PRD_v1.md`
- 규칙: `docs/docs/RULES_HUG_v1.md`, `docs/docs/RULES_HUG_mapping.yaml`
- RAG 정책: `docs/docs/RAG_POLICY.md`
- 인테이크: `docs/docs/INTAKE_FLOW.md`
- 컴포넌트: `docs/docs/COMPONENT_SPECS.md`
- UI 청사진/토큰: `docs/docs/UI_BLUEPRINT.yaml`, `docs/docs/DESIGN_TOKENS.yaml`
- 카피: `docs/docs/COPY_GUIDE.md`, `docs/docs/RESULT_CARD_COPY.md`
- 측정: `docs/docs/MEASUREMENT_PLAN.md`
- 운영/법/광고: `docs/docs/OPERATIONS_RUNBOOK.md`, `docs/docs/LEGAL_CHECKLIST.md`, `docs/docs/ADS_POLICY.md`
 - 화면 기획(챗봇형): `docs/docs/APP_SCREEN_PLAN.md`
 - UI/UX 가이드: `docs/docs/UI_UX_GUIDE.md`
 - 문서 인덱스: `docs/docs/DOCS_INDEX.md`
 - 화면 사양(트리/프롭/상태): `docs/docs/SCREEN_SPECS.md`
 - MVP 종합 기획: `docs/docs/PRODUCT_PLAN_MVP.md`
 - 백로그: `docs/docs/BACKLOG_EPICS_USER_STORIES.md`
