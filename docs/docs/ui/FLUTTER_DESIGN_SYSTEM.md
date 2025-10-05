# FLUTTER_DESIGN_SYSTEM — Flutter UI 작성 가이드(실행 지향)
Status: derived (Implementation guide). Canonical: DESIGN_TOKENS.yaml, COMPONENT_SPECS.md, UI_UX_GUIDE.md

마지막 업데이트: 2025-09-08
범위: 디자인 토큰 → ThemeData/ThemeExtension 매핑 → 컴포넌트 규약 → 접근성/반응형/테스트.

## 목적
- Figma 없이도 Flutter에서 일관된 UI를 빠르게 구현하도록 표준을 제공합니다.
- 문서-코드 간 일치: 토큰(YAML) → Dart Theme 확장으로 자동/반자동 매핑.

## 참고: 디렉터리 구조
- 세부 구조/권장은 ARCHITECTURE.md 및 AGENTS.md(Repository Guidelines)를 참조하세요.
- 본 문서는 UI 구현 관점만 다루며, 폴더 구조 결정은 아키텍처 문서의 표준을 따릅니다.

## 디자인 토큰(소스)
- 파일: `DESIGN_TOKENS.yaml` (색/타입/스페이싱/라운드/쉐도우)
- 변환: 현재 수동 매핑. 토큰 변경 시 `lib/ui/theme/app_theme.dart` 갱신 필요(스크립트 미사용).

## Theme 구성 원칙
- ColorScheme 우선: `ColorScheme.fromSeed(seedColor)` 기반, 의미론적 컬러만 사용
- Seed 컬러(현 구현): 크림톤 `0xFFF4E6C1`
- TextTheme: Google Fonts Inter 적용, 제목 가중치 상향, 본문 line-height 1.5
- ThemeExtension: Spacing(x1..x10), Corners(sm=10, md=14)
- 컴포넌트 고정값은 지양, Theme/Extension에서 가져오기(테스트 용이성↑)

### 예시: Theme + Extension (현 구현 발췌)
```dart
// lib/ui/theme/app_theme.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

@immutable
class Spacing extends ThemeExtension<Spacing> {
  final double x1; // 4
  final double x2; // 8
  final double x3; // 12
  final double x4; // 16
  final double x6; // 24
  final double x8; // 32
  final double x10; // 40
  const Spacing({this.x1=4,this.x2=8,this.x3=12,this.x4=16,this.x6=24,this.x8=32,this.x10=40});
  @override Spacing copyWith({double? x1,double? x2,double? x3,double? x4,double? x6,double? x8,double? x10}) =>
    Spacing(x1: x1??this.x1, x2: x2??this.x2, x3: x3??this.x3, x4: x4??this.x4, x6: x6??this.x6, x8: x8??this.x8, x10: x10??this.x10);
  @override Spacing lerp(ThemeExtension<Spacing>? other, double t) => this;
}

@immutable
class Corners extends ThemeExtension<Corners> {
  final double sm; // 10
  final double md; // 14
  const Corners({this.sm=10,this.md=14});
  @override Corners copyWith({double? sm,double? md}) => Corners(sm: sm??this.sm, md: md??this.md);
  @override Corners lerp(ThemeExtension<Corners>? other, double t) => this;
}

ThemeData buildAppTheme(Brightness brightness) {
  const cream = Color(0xFFF4E6C1);
  final scheme = ColorScheme.fromSeed(seedColor: cream, brightness: brightness);
  final base = ThemeData(colorScheme: scheme, useMaterial3: true);
  final interText = GoogleFonts.interTextTheme(base.textTheme);
  return base.copyWith(
    textTheme: interText.copyWith(
      titleLarge: base.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
      titleMedium: base.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
      bodyMedium: interText.bodyMedium?.copyWith(height: 1.5),
      labelLarge: interText.labelLarge?.copyWith(letterSpacing: 0.15),
    ),
    chipTheme: base.chipTheme.copyWith(
      labelStyle: base.textTheme.labelLarge?.copyWith(letterSpacing: 0.1),
      padding: const EdgeInsetsDirectional.symmetric(horizontal: 12, vertical: 8),
      side: BorderSide(color: scheme.outlineVariant),
      selectedColor: scheme.primaryContainer,
      backgroundColor: scheme.surfaceContainerHighest,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      showCheckmark: false,
    ),
    inputDecorationTheme: const InputDecorationTheme(border: OutlineInputBorder()),
    elevatedButtonTheme: ElevatedButtonThemeData(style: ElevatedButton.styleFrom(
      minimumSize: const Size(48, 48), shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
    )),
    extensions: const <ThemeExtension<dynamic>>[
      Spacing(), Corners(),
    ],
  );
}
```

## 반응형/레이아웃 규칙
- 8pt 그리드, 기본 패딩 `context.spacing.x4` 사용(토큰 경유)
- Breakpoints(Material 3 권장):
  - compact < 600, medium 600–839, expanded ≥ 840
  - 참고: 단순 1단/2단/3단 레이아웃 분기에 활용
- 위젯: `LayoutBuilder`/`MediaQuery.sizeOf(context)`로 분기, 길어지는 목록은 `ListView.builder` 또는 Sliver 사용(중첩 스크롤 지양)

## 컴포넌트 규약(샘플)
- 네이밍: `XxxCard`, `XxxTile`, `XxxChip`, `XxxButton`
- 생성자: 필요한 것만 `required`, 나머지는 `@optionalTypeArgs` 또는 기본값
- 상태: `enabled/disabled`, `loading`, `error/unknown` 등 enum으로 노출
- 접근성: `Semantics(label/hint)`, `ExcludeSemantics`로 중복 제거, 키보드 포커스 고려
- 테스트: `Key('ResultCard.TLDR')` 등 TestKey 표준화
 - 방향성: 여백은 `EdgeInsetsDirectional` 우선 사용(RTL 대비)
 - 터치 타겟: 모든 상호작용 요소 최소 48×48dp 보장(Material 가이드)
 - 잉크 효과: 버튼/탭 요소는 `InkWell`/`InkResponse` 또는 표준 버튼 위젯 사용(`GestureDetector` 단독 지양)

### IntakeQuestion 사양(요약)
- props: `qid`, `label`, `options(List<Choice>)`, `onChanged`, `selected`, `showUnknown(bool)`
- states: `errorText`, `isRequired`, `isBusy`
- A11y: label을 음성으로 충분히 읽히도록, 옵션은 `ToggleButtons`/`ChoiceChip` 중 택1

### ResultCard 사양(요약)
- props: `status`, `tldr`, `reasons(List<Reason{text, kind})`, `nextSteps(List<String>)`, `lastVerified`
- states: 사유/다음 단계 ‘자세히/접기’ 토글(Stateful)
- A11y: 색상 외 구분(아이콘/텍스트), 대비 준수

## 접근성 체크
- 최소 터치 48×48, 본문 대비 4.5:1 이상
- Dynamic Type 대응: `MediaQuery.textScaler` 반영, `FittedBox` 남용 금지
- 포커스 순서: 논리적 탭 순서 설정(`FocusTraversalGroup`)
 - 선택 상태: Chip/토글 등은 `selected` 상태가 보이스오버로 읽히도록 `Semantics(selected: ...)` 또는 기본 위젯 상태 활용

## 국제화(i18n)
- `flutter gen-l10n` 사용(앱 전역 l10n), 문자열 하드코딩 지양
- 숫자/날짜/통화는 `intl` 사용, 메시지 키는 COPY_GUIDE 참조

## 성능 수칙
- 가능한 `const` 사용, `ListView.builder`/`SliverList` 활용
- Rebuild 최소화: `ValueListenableBuilder`/`BlocBuilder`로 범위 한정
- 이미지/아이콘 캐싱, Hero/애니메이션 과다 사용 자제

## 테스트
- 골든 테스트(중요 화면): 결과 카드 3종 상태, 인테이크 질문 1개 씬
- 위젯 테스트: 버튼 탭→콜백, 상태 전이, Semantics 확인

## 문서-코드 연결 체크리스트(DoD)
- DESIGN_TOKENS.yaml ↔ app_theme.dart 매핑 동기화(현재 수동)
- 컴포넌트가 Theme/Extension 토큰만 참조(하드코딩 X)
- TestKey 부착, 골든 스냅샷 통과
