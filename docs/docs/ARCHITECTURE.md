# Project Architecture Guide

## 개요
- 목표: 기능 단위로 확장 가능한 구조를 간결하게 유지합니다.
- 패턴: Flutter + BLoC(`flutter_bloc`) + Domain 모델 + Repository(+선택: Local/Remote).
- 원칙: UI → BLoC → Domain → Repository → DataSource 단방향 의존. 생성 파일(`*.freezed.dart`, `*.g.dart`)은 수정 금지.

> 본 문서는 우리 제품 맥락(HUG 예비판정 + RAG Q&A)에 맞춘 이상적 구조를 정의합니다.

## 디렉터리 구조(권장)
```
lib/
  features/
    <feature>/
      ui/    # 화면/위젯
      bloc/  # Cubit/Bloc, State
      domain/# 도메인 모델/타입(Flutter 의존 금지)
      data/  # Repository interface + impl, 매퍼, remote/local data sources
  common/    # 공용 테마/토큰/유틸/측정(Analytics)
```
예시
```
lib/features/conversation/ui/conversation_page.dart
lib/features/conversation/bloc/conversation_cubit.dart
lib/features/conversation/domain/models.dart
lib/features/conversation/data/chat_repository.dart
```

### 의존성 매트릭스(허용 방향)
- `ui` → `bloc`, `domain`, `common`
- `bloc` → `domain`, `data`(interface만)
- `domain` → (없음; 순수 Dart 타입)
- `data` → `domain`(interface/모델), `common`(로깅 선택)
- `common` → (테마/토큰/로깅 등)

금지 사항
- `bloc`에서 Flutter UI 타입/아이콘 사용 금지(Material import X)
- `ui` 타입을 `bloc`/`data`에서 import 금지(ResultCard, IntakeQuestion 등)
- Domain에 플랫폼/프레임워크 의존 금지(순수 값 객체)

## 샘플(축약): Domain + Cubit + Repository
```dart
// domain/models.dart
enum RulingStatus { possible, notPossibleInfo, notPossibleDisq }
enum ReasonKind { met, unmet, unknown, warning }
class Reason { final String text; final ReasonKind kind; const Reason(this.text, this.kind); }
class Choice { final String value; final String text; const Choice({required this.value, required this.text}); }

// bloc/conversation_cubit.dart (발췌)
class ConversationCubit extends Cubit<ConversationState> {
  void answer(String qid, String value) { /* 상태 전이/판정 */ }
  void _evaluateAndEmit() {
    // ‘모름’ 처리 → notPossibleInfo, ReasonKind.unknown
    // 결격 우선 → notPossibleDisq, ReasonKind.unmet
    // 가능 → possible, ReasonKind.met/warning
  }
}

// ui/result_card.dart (발췌)
// UI는 ReasonKind → 아이콘/색/텍스트를 매핑(프레젠테이션 책임)
IconData _icon(ReasonKind k) => switch (k) {
  ReasonKind.met => Icons.check_circle,
  ReasonKind.unmet => Icons.cancel,
  ReasonKind.warning => Icons.warning_amber,
  ReasonKind.unknown => Icons.help_outline,
};
```

## 아키텍처 결정(핵심)
- 의존성 주입: `main.dart`에서 `RepositoryProvider`/`BlocProvider`로 주입. API/Mock은 Env로 스위치(`USE_API_CHAT`).
- 도메인 경계: 도메인 타입은 Flutter/Material/Icons 비의존. UI 매핑은 컴포넌트 내부에서 수행.
- 오류/결과: 인프라 예외 → 도메인 에러로 변환 후 Cubit에서 사용자 메시지 표준화.
- 규칙 엔진(예비판정): 우선순위 C1(결격) → C2(필수 확인/모름) → C3(조건/경고). Cubit 내부에서 도메인 ReasonKind로만 판단.
- 데이터 소스: Repository 아래 Local/Remote 분리. 캐시/리트라이/백오프는 Repository에서 관리.
- 네비게이션: 화면 로직은 UI에서 최소화. BLoC 상태 전이에 기반해 UI 조합.

## 필수 명령어
- 의존성: `flutter pub get`
- 코드 생성: `dart run build_runner build --delete-conflicting-outputs`
- 정적 분석/포맷: `flutter analyze` / `dart format .`
- 테스트/실행: `flutter test` / `flutter run -d chrome`

## 필수 라이브러리
- flutter_bloc: BLoC 상태 관리 및 UI 연동
- freezed, freezed_annotation: 불변 모델/합타입 정의
- build_runner: 코드 생성 실행기(Freezed/JSON)
- json_annotation, json_serializable: 모델 직렬화/역직렬화
- sqflite, path: 로컬 DB 저장소 구현
- intl: 숫자/날짜/통화 포맷
- uuid: 고유 ID 생성
- flutter_masked_text2: 입력 포맷팅(마스킹)
- flutter_lints: 린트 규칙(analysis_options.yaml)
- flutter_test: 위젯/단위 테스트 프레임워크

## Conversation(챗봇/예비판정) 가이드(본 프로젝트 특화)
- Intake 플로우: 질문 A1..A7, P1..P7, S1. 각 질문에는 ‘모름’ 제공. Cubit이 질문/단계 전환을 소유(UI는 표시만).
- ‘모름’ 처리: 하나라도 포함되면 최종 판정은 `notPossibleInfo`(정보 부족). ReasonKind.unknown으로 사유 표기.
- 결과 카드: TL;DR → 사유(충족/미충족/확인불가/주의) → 다음 단계 → last_verified. 30일 초과 시 ‘정보 최신성 확인 필요’ 배지.
- Chat(Q&A): `ChatCubit` → `ChatRepository(Api/Mock)` 호출. RAG 정책 준수(내부 문서만, {docId, sectionKey} 유지, 외부 링크 금지).
- 출처/최신성: 응답에는 citations와 last_verified 포함. UI에서 Chip/Badge로 노출.
- 계측: `Analytics`는 UI 상호작용 시점에 배치. 핵심 이벤트는 MEASUREMENT_PLAN.md 준수.

## 테스트 전략
- 도메인: 규칙/판정 로직 단위 테스트(경계값, ‘모름’, 결격 우선순위). 시간 의존성은 주입 또는 고정 Clock 사용.
- BLoC/Cubit: 상태 전이 테스트(mock repository). 성공/실패/로딩/‘모름’ 분기 검증.
- UI: 위젯 테스트(컴포넌트 API 계약 검증, 접근성 키/레이블 확인). 스냅샷 보단 의미 기반 검사.

## Do / Don’t
- Do: UI는 Domain→프레젠테이션 매핑만 담당. 비즈니스 판단은 Cubit/도메인.
- Do: BLoC는 Flutter/Material에 의존하지 않음. Domain 타입만 사용.
- Do: Repository 인터페이스는 Domain 관점으로 설계. 구현은 DataSource 캡슐화.
- Don’t: Cubit에서 아이콘/색상 등 UI 세부 정의 금지.
- Don’t: 외부 링크/추정 제공 금지(RAG 정책). 불확실 시 ‘확인불가’ 처리.

## DI/부트스트랩(예시)
```dart
// main.dart
const useApi = bool.fromEnvironment('USE_API_CHAT', defaultValue: false);
return RepositoryProvider<ChatRepository>(
  create: (_) => useApi ? ApiChatRepository() : MockChatRepository(),
  child: MaterialApp(/* ... */),
);
```
