## Splash(Animated) — 구성/커스터마이즈 가이드

목표: 라이브러리 기반(Lottie/SVG/이미지)으로 쉽게 교체·유지보수 가능한 스플래시를 제공합니다.

구성 요소
- 코드: `lib/features/splash/ui/splash_page.dart`
- 설정: `assets/splash/config.json`
- 도메인: `lib/features/splash/domain/splash_config.dart`
- 에셋: `assets/splash/` (Lottie JSON, SVG, PNG 등)

의존성
- `lottie`: Lottie JSON 애니메이션 재생
- `flutter_svg`: SVG 렌더링

설정 파일(config.json)
```json
{
  "durationMs": 1200,
  "nextDelayMs": 250,
  "title": "전세자금대출 도우미",
  "subtitle": "HUG 예비판정 · 내부 근거 Q&A",
  "animation": {
    "type": "svg", // svg | lottie | image
    "lightAsset": "assets/splash/logo.svg",
    "darkAsset": "assets/splash/logo.svg"
  }
}
```

변경 방법
1) Lottie로 교체
   - `assets/splash/intro.json` 추가(디자이너 제공 파일)
   - `config.json`의 `animation`을 다음과 같이 수정:
     ```json
     "animation": {
       "type": "lottie",
       "lightAsset": "assets/splash/intro.json",
       "darkAsset": "assets/splash/intro.json"
     }
     ```
2) SVG로 교체
   - `assets/splash/logo.svg` 교체 또는 다른 파일 추가 후 경로 변경
   - `type`을 `svg`로 유지
3) PNG/JPG로 교체
   - `assets/splash/logo.png` 추가
   - `type: "image"`, `lightAsset/darkAsset`에 파일 경로 지정

애니메이션 타이밍 조정
- `durationMs`: 스플래시 애니메이션 총 시간
- `nextDelayMs`: 전환(AppShell로)까지의 대기 시간

전환 효과
- 현재는 페이드 전환(FadeTransition). 필요 시 `SplashPage`의 `PageRouteBuilder`에서 전환 효과 변경 가능.

주의
- 첫 프레임(네이티브 스플래시)이 필요할 경우 `flutter_native_splash` 패키지로 네이티브 런치 스크린을 구성하고, 본 애니메이션은 그 뒤에 표시하는 것을 권장합니다.
- 웹 배포 시 Lottie JSON은 동일 경로로 번들되며, 상대 경로가 유효해야 합니다.

