# FLUTTER_DESIGN_SYSTEM — Flutter UI 작성 가이드(실행 지향)
Status: derived (Implementation guide). Canonical: DESIGN_TOKENS.yaml, COMPONENT_SPECS.md, UI_UX_GUIDE.md

마지막 업데이트: 2025-09-02
범위: 디자인 토큰 → ThemeData/ThemeExtension 매핑 → 컴포넌트 규약 → 접근성/반응형/테스트.

## 목적
- Figma 없이도 Flutter에서 일관된 UI를 빠르게 구현하도록 표준을 제공합니다.
- 문서-코드 간 일치: 토큰(YAML) → Dart Theme 확장으로 자동/반자동 매핑.

## 참고: 디렉터리 구조
- 세부 구조/권장은 ARCHITECTURE.md 및 AGENTS.md(Repository Guidelines)를 참조하세요.
- 본 문서는 UI 구현 관점만 다루며, 폴더 구조 결정은 아키텍처 문서의 표준을 따릅니다.

## 디자인 토큰(소스)
- 파일: `DESIGN_TOKENS.yaml` (색/타입/스페이싱/라운드/쉐도우)
- 변환: 수동/스크립트로 Dart `ThemeExtension`에 주입

## Theme 구성 원칙
- ColorScheme 우선: `ColorScheme.fromSeed(seedColor)` 기반, 의미론적 컬러만 사용
- TextTheme 표준화: 제목/본문/라벨 3축(scale sm/md/lg), 줄간/자간 고정
- ThemeExtension: 스페이싱/라운드/간격/모서리/두께 등 비표준 토큰을 확장
- 컴포넌트 고정값은 지양, Theme에서 가져오기(테스트 용이성↑)

### 예시: Theme + Extension
```dart
// lib/ui/theme/app_theme.dart
import 'package:flutter/material.dart';

@immutable
class Spacing extends ThemeExtension<Spacing> {
  final double x1; // 4
  final double x2; // 8
  final double x3; // 12
  final double x4; // 16
  final double x6; // 24
  const Spacing({this.x1=4,this.x2=8,this.x3=12,this.x4=16,this.x6=24});
  @override Spacing copyWith({double? x1,double? x2,double? x3,double? x4,double? x6}) =>
    Spacing(x1: x1??this.x1, x2: x2??this.x2, x3: x3??this.x3, x4: x4??this.x4, x6: x6??this.x6);
  @override Spacing lerp(ThemeExtension<Spacing>? other, double t) => this;
}

@immutable
class Corners extends ThemeExtension<Corners> {
  final double sm; // 8
  final double md; // 12
  const Corners({this.sm=8,this.md=12});
  @override Corners copyWith({double? sm,double? md}) => Corners(sm: sm??this.sm, md: md??this.md);
  @override Corners lerp(ThemeExtension<Corners>? other, double t) => this;
}

ThemeData buildAppTheme(Brightness brightness) {
  final isDark = brightness == Brightness.dark;
  final scheme = ColorScheme.fromSeed(
    seedColor: const Color(0xFF3B6EF5), brightness: brightness,
  );
  final base = ThemeData(colorScheme: scheme, useMaterial3: true);
  return base.copyWith(
    textTheme: base.textTheme.copyWith(
      titleLarge: base.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
      bodyMedium: base.textTheme.bodyMedium?.copyWith(height: 1.4),
      labelLarge: base.textTheme.labelLarge?.copyWith(letterSpacing: 0.2),
    ),
    inputDecorationTheme: const InputDecorationTheme(border: OutlineInputBorder()),
    elevatedButtonTheme: ElevatedButtonThemeData(style: ElevatedButton.styleFrom(
      minimumSize: const Size(48, 48), shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
    )),
    extensions: const <ThemeExtension<dynamic>>[
      Spacing(), Corners(),
    ],
  );
}
```

## 반응형/레이아웃 규칙
- 8pt 그리드, 기본 패딩 `theme.extension<Spacing>()!.x4` 사용
- Breakpoints(권장): narrow < 360, base 360–599, wide ≥ 600
- 위젯: `LayoutBuilder`로 분기, 길어지는 목록은 Sliver 사용

## 컴포넌트 규약(샘플)
- 네이밍: `XxxCard`, `XxxTile`, `XxxChip`, `XxxButton`
- 생성자: 필요한 것만 `required`, 나머지는 `@optionalTypeArgs` 또는 기본값
- 상태: `enabled/disabled`, `loading`, `error/unknown` 등 enum으로 노출
- 접근성: `Semantics(label/hint)`, `ExcludeSemantics`로 중복 제거, 키보드 포커스 고려
- 테스트: `Key('ResultCard.TLDR')` 등 TestKey 표준화

### IntakeQuestion 사양(요약)
- props: `qid`, `label`, `options(List<Choice>)`, `onChanged`, `selected`, `showUnknown(bool)`
- states: `errorText`, `isRequired`, `isBusy`
- A11y: label을 음성으로 충분히 읽히도록, 옵션은 `ToggleButtons`/`ChoiceChip` 중 택1

### ResultCard 사양(요약)
- props: `status`, `tldr`, `reasons(List<Item{icon,text,type})`, `nextSteps(List<String>)`, `lastVerified`
- states: `expanded`(사유 펼치기), `showMeta`
- A11y: 색상 외 구분(아이콘/텍스트), 대비 준수

## 접근성 체크
- 최소 터치 44×44, 본문 대비 4.5:1 이상
- Dynamic Type 대응: `MediaQuery.textScaler` 반영, `FittedBox` 남용 금지
- 포커스 순서: 논리적 탭 순서 설정(`FocusTraversalGroup`)

## 국제화(i18n)
- 숫자/날짜/통화 `intl` 사용, 텍스트 분리(l10n) — 메시지 키는 COPY_GUIDE 참조

## 성능 수칙
- 가능한 `const` 사용, `ListView.builder`/`SliverList` 활용
- Rebuild 최소화: `ValueListenableBuilder`/`BlocBuilder`로 범위 한정
- 이미지/아이콘 캐싱, Hero/애니메이션 과다 사용 자제

## 테스트
- 골든 테스트(중요 화면): 결과 카드 3종 상태, 인테이크 질문 1개 씬
- 위젯 테스트: 버튼 탭→콜백, 상태 전이, Semantics 확인

## 문서-코드 연결 체크리스트(DoD)
- DESIGN_TOKENS.yaml → ThemeExtension 매핑 확인
- 컴포넌트가 Theme/Extension 토큰만 참조(하드코딩 X)
- TestKey 부착, 골든 스냅샷 통과
