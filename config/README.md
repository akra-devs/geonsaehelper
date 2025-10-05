# Remote Configuration

이 디렉토리는 앱의 동적 설정을 포함합니다. 앱 시작 시 GitHub에서 설정을 자동으로 가져옵니다.

## 설정 파일

### `app_config.json`

앱에서 사용할 API 엔드포인트 및 경로를 정의합니다.

```json
{
  "chatApiBaseUrl": "http://localhost:8080",
  "chatStreamPath": "api/loan-advisor/stream",
  "chatHealthPath": "api/health"
}
```

## 동작 방식

1. **앱 시작 시**: `RemoteConfigLoader`가 GitHub raw content URL에서 `app_config.json`을 가져옵니다
   - URL: `https://raw.githubusercontent.com/akra-devs/geonsaehelper/main/config/app_config.json`

2. **우선순위**:
   - 1순위: 환경 변수 (`CHAT_API_BASE`)
   - 2순위: GitHub의 원격 설정
   - 3순위: 하드코딩된 fallback (`http://localhost:8080`)

3. **타임아웃**: 10초 이내에 설정을 가져오지 못하면 fallback 사용

## API URL 변경 방법

### 방법 1: GitHub 파일 수정 (권장)

1. `config/app_config.json` 파일의 `chatApiBaseUrl` 값을 수정
2. GitHub에 커밋 & 푸시
3. 앱 재시작 시 자동으로 새 URL 적용

**장점**:
- 앱 재배포 없이 API 주소 변경 가능
- 모든 사용자에게 즉시 적용

**예시**:
```json
{
  "chatApiBaseUrl": "https://api.geonsaehelper.com",
  "chatStreamPath": "api/loan-advisor/stream",
  "chatHealthPath": "api/health"
}
```

### 방법 2: 환경 변수 사용 (로컬 개발)

빌드 시 환경 변수로 오버라이드:

```bash
flutter run --dart-define=CHAT_API_BASE=http://192.168.1.100:8080
```

### 방법 3: Fallback 값 수정 (최후)

`lib/common/config/remote_config.dart`의 `RemoteConfig.fallback` 값 수정

## 로그 확인

앱 실행 시 콘솔에서 다음 로그로 설정 로드 과정 확인:

```
📡 Fetching remote config from: https://raw.githubusercontent.com/...
✅ Remote config loaded: http://localhost:8080
🎯 Using API base URL: http://localhost:8080
```

## 주의사항

- GitHub raw content는 캐싱될 수 있어 즉시 반영되지 않을 수 있습니다 (최대 5분)
- 네트워크 없이 앱 실행 시 fallback 값이 사용됩니다
- 프로덕션 배포 전 반드시 실제 API URL로 변경하세요
