# Architecture Guide

## TL;DR
- 레이어: `UI → BLoC → Domain → Repository → DataSource`의 단방향 의존만 허용합니다.
- BLoC는 도메인 타입만 사용하며 Flutter/Material에 의존하지 않습니다.
- ‘모름’은 항상 불가(정보 부족)로 귀결하고, 사유는 `ReasonKind.unknown`으로 표시합니다.
- 결과는 TL;DR → 사유 → 다음 단계 → last_verified 순으로 노출합니다(30일 초과 시 배지).
- RAG: 내부 문서만 근거. 응답에는 `{docId, sectionKey}`와 `last_verified`를 포함합니다.

## 원칙
- 단방향 의존: `UI → BLoC → Domain → Repository → DataSource`.
- 관심사 분리: UI는 표현, BLoC는 상태/흐름, Domain은 규칙/값, Data는 I/O.
- 순수 도메인: Domain은 프레임워크(Flutter/Material) 비의존, 값 객체 중심.
- 테스트 우선: 도메인 규칙과 상태 전이를 단위 테스트 가능하게 설계.

## 디렉터리 구조
```
lib/
  features/
    <feature>/
      ui/      # 화면/위젯(표현)
      bloc/    # Cubit/Bloc, State(도메인만 참조)
      domain/  # 도메인 모델/타입/규칙(순수 Dart)
      data/    # Repository 인터페이스/구현, Remote/Local DS, 매퍼
  common/      # 테마/토큰/유틸/측정(Analytics)
```
예시
```
lib/features/conversation/ui/conversation_page.dart
lib/features/conversation/bloc/conversation_cubit.dart
lib/features/conversation/domain/models.dart
lib/features/conversation/data/chat_repository.dart
```

### 의존성 규칙
- 허용: `ui → bloc|domain|common`, `bloc → domain|data(인터페이스)`, `data → domain|common`.
- 금지: bloc에서 UI 타입/아이콘 사용, ui 타입을 bloc/data에서 import, domain의 플랫폼 의존.

## 타입/모델(도메인)
- 목적: UI와 분리된 결정/사유/선택지 표현.
- 예시
```dart
enum RulingStatus { possible, notPossibleInfo, notPossibleDisq }
enum ReasonKind { met, unmet, unknown, warning }
class Reason { final String text; final ReasonKind kind; const Reason(this.text, this.kind); }
class Choice { final String value; final String text; const Choice({required this.value, required this.text}); }
```

### Freezed 사용 가이드
- 사용처: bloc state(합타입), data(API/DTO), domain(값 동등성/사본 필요 시).
- 생성: `dart run build_runner build --delete-conflicting-outputs`.
- 예시(발췌)
```dart
// bloc state union
@freezed
class ChatState with _$ChatState {
  const factory ChatState.idle() = _Idle;
  const factory ChatState.loading() = _Loading;
  const factory ChatState.success(BotReply reply) = _Success;
  const factory ChatState.error(String message) = _Error;
}

// data json
@freezed
class BotReply with _$BotReply {
  const factory BotReply({required String content, @Default(<ChatCitation>[]) List<ChatCitation> citations, required String lastVerified}) = _BotReply;
  factory BotReply.fromJson(Map<String, dynamic> json) => _$BotReplyFromJson(json);
}
```

## 상태 관리(BLoC/Cubit)
- 선택 기준: 단순 흐름은 Cubit, 복합 이벤트/효과는 Bloc.
- 금지: IconData/색상 등 UI 세부 로직 포함.
- 권장: 입력 검증/규칙 판단/단계 전이는 Cubit에서 도메인 타입으로만 처리.
- Analytics: 사용자 인터랙션 시점(UI) 또는 공통 Observer로 수집(세부는 MEASUREMENT_PLAN.md).

## 데이터 계층(Repository/DS)
- Repository: 인터페이스로 도메인 친화 API 설계, 구현은 Remote/Local DS로 위임.
- Remote: API 호출/에러 변환/정규화. Local: 캐시/설정/키체인 등.
- 토글: `USE_API_CHAT` 등 Env로 API/Mock 전환.

## DI/부트스트랩
```dart
const useApi = bool.fromEnvironment('USE_API_CHAT', defaultValue: false);
return RepositoryProvider<ChatRepository>(
  create: (_) => useApi ? ApiChatRepository() : MockChatRepository(),
  child: MaterialApp(/* ... */),
);
```

## Feature 규칙(Conversation 특화)
- Intake: A1..A7, P1..P7, S1. 모든 질문에 ‘모름’ 제공.
- 우선순위: C1(결격) → C2(필수/모름) → C3(조건/경고).
- ‘모름’: 하나라도 있으면 최종 `notPossibleInfo`, 사유는 `ReasonKind.unknown`.
- ResultCard: TL;DR → 사유 → 다음 단계 → last_verified. 30일 초과 시 배지.

## RAG(내부 근거) 규칙 요약
- 내부 문서만 근거, 외부 링크 금지.
- 출처 메타: `{docId, sectionKey}` 유지.
- 불확실 시 ‘확인불가’로 응답(추정 금지).

## 측정(Analytics)
- 핵심 이벤트: `intake_start`, `intake_answer`, `intake_complete`, `ruling_shown`, `next_step_click`, `qna_ask`, `qna_answer` (feedback/reasons_toggle/correction는 추후 추가).
- 위치: UI 인터랙션 직후 또는 결과 표시 시점. 상세 스키마는 MEASUREMENT_PLAN.md.

## 테스트 전략
- 도메인: 규칙/경계/‘모름’/결격 우선순위 테스트.
- Cubit/Bloc: 상태 전이(성공/실패/로딩/모름) + Repository mock.
- UI: 위젯 API 계약/접근성 키/표시값 검증. 스냅샷 남용 금지.

## 스타일/네이밍(요약)
- 파일: `snake_case.dart` / 클래스: `PascalCase` / 메서드·필드: `lowerCamelCase`.
- 폴더: `features/<feature>/{ui,bloc,domain,data}`.
- 테스트: 소스 경로 미러, 예) `test/ui/components/result_card_test.dart`.
- 린트: `analysis_options.yaml` 준수. 포맷: `dart format .`.

## 체크리스트(리뷰/PR 전)
- [ ] `flutter analyze` 경고/에러 없음(Deprecated는 별도 이슈화).
- [ ] BLoC가 UI/Material에 의존하지 않음.
- [ ] ‘모름’ → `notPossibleInfo` 일관, last_verified 표기.
- [ ] RAG 준수(내부 근거만, citations 포함).
- [ ] 테스트 통과 및 주요 분기 케이스 추가.
- [ ] 문서/토큰/사양 변경 시 관련 문서 업데이트.

## 개발 명령어(요약)
- 의존성: `flutter pub get`
- 코드 생성: `dart run build_runner build --delete-conflicting-outputs`
- 정적 분석/포맷: `flutter analyze` / `dart format .`
- 테스트/실행: `flutter test` / `flutter run -d chrome`

### Freezed 사용 가이드(권장 패턴)
- 언제 쓰나: 합타입(State)·불변 값 객체·JSON 직렬화가 필요한 경우.
- 어디에 쓰나: bloc(state union), data(API/DTO), 필요 시 domain(값 동등성/`copyWith` 필요할 때).
- 주의: domain은 Flutter/Material 의존 금지. Freezed는 코드 생성 도구일 뿐 도메인 경계를 흐리지 않음.

```dart
// bloc/state (union 예시)
part 'chat_cubit.freezed.dart';
@freezed
class ChatState with _$ChatState {
  const factory ChatState.idle() = _Idle;
  const factory ChatState.loading() = _Loading;
  const factory ChatState.success(BotReply reply) = _Success;
  const factory ChatState.error(String message) = _Error;
}

// data/json (API 모델 예시)
part 'chat_models.freezed.dart';
part 'chat_models.g.dart';
@freezed
class BotReply with _$BotReply {
  const factory BotReply({
    required String content,
    @Default(<ChatCitation>[]) List<ChatCitation> citations,
    required String lastVerified,
  }) = _BotReply;
  factory BotReply.fromJson(Map<String, dynamic> json) => _$BotReplyFromJson(json);
}

// domain(선택): 값 동등성/사본 필요 시
part 'models.freezed.dart';
@freezed
class Reason with _$Reason {
  const factory Reason({required String text, required ReasonKind kind}) = _Reason;
}
@freezed
class ConversationResult with _$ConversationResult {
  const factory ConversationResult({
    required RulingStatus status,
    required String tldr,
    @Default(<Reason>[]) List<Reason> reasons,
    @Default(<String>[]) List<String> nextSteps,
    required String lastVerified,
  }) = _ConversationResult;
}
```

코드 생성
- 명령: `dart run build_runner build --delete-conflicting-outputs`
- 생성물: `*.freezed.dart`, `*.g.dart`는 커밋 대상이며 수동 수정 금지.
