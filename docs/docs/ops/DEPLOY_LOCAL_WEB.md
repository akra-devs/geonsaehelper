## 로컬에서 Chrome으로 실행/전달하기

목표: Flutter Web 빌드를 받아, 상대방이 간단히 로컬에서 열어볼 수 있도록 준비합니다.

중요: Flutter Web은 `file://`(더블클릭) 방식으로 바로 여는 것을 권장하지 않습니다. 브라우저 보안 정책/서비스워커/CanvasKit(WASM) 이슈로 실패할 수 있어, 간단한 정적 서버로 띄우는 방식을 권장합니다.

권장 옵션 A) 정적 서버로 실행(가장 쉬움)
1) 웹 빌드
   - `flutter build web --web-renderer html --pwa-strategy=none`
     - HTML 렌더러 사용(로컬 호스팅 호환성 ↑)
     - PWA 서비스워커 비활성화(로컬 캐싱/경로 이슈 ↓)
2) 로컬 서버 실행
   - macOS/Linux: `bash scripts/serve_web.sh` (기본 8080)
   - Windows: `scripts\serve_web.cmd` (기본 8080)
3) 접속: http://localhost:8080

권장 옵션 B) 패키징해서 전달(수신자도 서버 없이 실행 스크립트만)
1) 패키징
   - `bash scripts/package_web.sh`
   - 산출물: `dist/geonsaehelper_web.zip`
2) 전달 방법
   - zip을 전달하고, 수신자에게 다음 중 하나 안내:
     - macOS/Linux: 압축 해제 후 `python3 -m http.server 8080 -d web` 실행 → http://localhost:8080
     - Windows: `py -3 -m http.server 8080 -d web` 실행 → http://localhost:8080

옵션 C) Chrome을 파일 모드로 강제 실행(비권장)
- 일부 환경에서 아래 플래그로 가능하나, WASM/Fetch 제한 등으로 실패 가능성이 큼.
  - Chrome 실행 시: `--allow-file-access-from-files --disable-web-security`
- 추가로 Flutter Web의 PWA와 CanvasKit을 비활성화해야 할 수 있음.
- 실무 전달용으로는 A/B 옵션을 권장합니다.

대안) 데스크톱 앱으로 전달
- 완전 오프라인/더블클릭 실행이 필요하다면 Flutter 데스크톱 빌드 권장.
  - macOS: `flutter build macos`
  - Windows: `flutter build windows`
  - 생성된 바이너리를 전달하면 브라우저/서버 없이 실행 가능합니다.

참고
- API 통신이 필요한 기능은 로컬에서 실패할 수 있습니다. Mock 모드(기본값)로 데모하거나, API 서버 주소를 내부 네트워크에서 접근 가능한 값으로 지정해 주세요.
  - API 모드 실행 예시: `--dart-define=USE_API_CHAT=true --dart-define=CHAT_API_BASE=http://localhost:8080/api`

