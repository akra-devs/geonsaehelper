# Project Architecture Guide

## 개요
- 목표: 기능 단위로 확장 가능한 구조를 간결하게 유지합니다.
- 패턴: Flutter + BLoC(`flutter_bloc`) + Freezed 모델 + Repository(+선택: Sqflite).
- 원칙: UI → BLoC → Service/Repository → DB/Platform 단방향 의존. 생성 파일(`*.freezed.dart`, `*.g.dart`)은 수정 금지.

## 디렉터리 구조(권장)
```
lib/
  features/
    <feature>/
      ui/    # 화면/위젯
      bloc/  # Bloc, Event, State
      data/  # Repository, 모델, 매퍼
  common/    # 공용 위젯/유틸/테마/상수
```
예시
```
lib/features/rebalancing/ui/rebalancing_page.dart
lib/features/rebalancing/bloc/rebalancing_bloc.dart
lib/features/rebalancing/data/rebalancing_repository.dart
```

## 샘플(축약): Freezed + BLoC + JSON
```dart
// 이벤트/상태
@freezed
class RebalancingEvent with _$RebalancingEvent {
  const factory RebalancingEvent.load() = Load;
  const factory RebalancingEvent.changeRatio(double stock, double bond) = ChangeRatio;
}

@freezed
class RebalancingState with _$RebalancingState {
  const factory RebalancingState({
    required double stock,
    required double bond,
    @Default(false) bool loading,
  }) = _RebalancingState;
}

// Bloc
class RebalancingBloc extends Bloc<RebalancingEvent, RebalancingState> {
  final RebalancingRepository repo;
  RebalancingBloc(this.repo)
      : super(const RebalancingState(stock: 0, bond: 0)) {
    on<Load>((e, emit) async { /* load from repo */ });
    on<ChangeRatio>((e, emit) =>
        emit(state.copyWith(stock: e.stock, bond: e.bond)));
  }
}

// Freezed + JSON 모델
@freezed
class RebalanceItem with _$RebalanceItem {
  const factory RebalanceItem({
    required String id,
    required String symbol,
    required double targetRatio,
    required double currentValue,
    @Default(false) bool favorite,
  }) = _RebalanceItem;
  factory RebalanceItem.fromJson(Map<String, dynamic> json)
      => _$RebalanceItemFromJson(json);
}
// 중첩 모델은 @JsonSerializable(explicitToJson: true)로 자식 toJson() 호출을 보장합니다.
```

## 아키텍처 결정(핵심)
- 의존성 주입: `main.dart`(또는 `bootstrap.dart`)에서 Repository/Bloc를 중앙에서 생성·주입. `RepositoryProvider`/`BlocProvider`로 구성하고 전역 싱글톤은 지양.
- 오류/결과 모델: 인프라 예외→도메인 `Failure` 매핑, BLoC에는 `Result<T>`(성공/실패)만 전달. 메시지/재시도 정책을 일원화.
- 네비게이션: Navigator 2.0 또는 `go_router` 중 하나로 표준화. 라우트 정의 중앙 집중, 위젯 내부 네비게이션 로직 최소화.
- 데이터 소스: Repository 아래 `LocalDataSource(SQLite)` 분리(추후 `RemoteDataSource` 확장 전제). 캐싱/동기화 규칙은 Repository에서 캡슐화.

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
