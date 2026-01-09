# App_Base - Flutter Base Project

AI 기반 앱 생성을 위한 경량화된 Flutter 템플릿 프로젝트입니다.
PRD와 컬러셋을 입력받아 자동으로 앱을 생성하는 시스템의 기반이 됩니다.

## 주요 특징

- **모듈형 아키텍처**: 기능별 Addon 시스템으로 필요한 기능만 활성화
- **중앙 집중식 DataSource**: Remote, Local, Secure 데이터 관리 통합
- **반응형 테마 시스템**: 디바이스별 자동 스케일링 (Mobile/Tablet/Desktop)
- **최소 권한 원칙**: 필요한 권한만 스크립트로 추가
- **AI 친화적 구조**: Claude Code 등 AI 도구가 인식하기 쉬운 구조
- **Firebase BaaS**: 별도 서버 없이 Firebase로 백엔드 운영

## 빠른 시작

### Prerequisites

- Flutter SDK 3.32.4+
- Dart SDK 3.8.1+
- Node.js v22.16.0 (Claude Code CLI용)
- Firebase CLI (`firebase login`)
- FlutterFire CLI (`dart pub global activate flutterfire_cli`)

### 1. 새 프로젝트 생성

```bash
./start.sh
```

start.sh가 자동으로:
- 패키지 이름 변경
- Firebase 프로젝트 생성 및 연결
- FlutterFire 설정 (firebase_options.dart 생성)
- GitHub 레포지토리 생성
- colorset.json 적용
- FSD 문서 생성

### 2. 권한 설정 (선택)

```bash
# 필요한 권한만 추가
./scripts/permissions-setup.sh --camera --photos --notifications

# 옵션 보기
./scripts/permissions-setup.sh
```

### 3. 실행

```bash
flutter run
```

## 프로젝트 구조

```
lib/
├── main.dart                 # 앱 진입점
├── app_config.dart           # 기능 토글 설정
├── firebase_options.dart     # Firebase 설정 (자동 생성)
│
├── core/                     # 핵심 인프라
│   ├── datasource/          # 데이터 소스 시스템
│   │   ├── datasource.dart  # DS 통합 진입점
│   │   ├── remote/          # API 통신 (Dio)
│   │   ├── local/           # 로컬 저장소 (SharedPreferences)
│   │   └── secure/          # 보안 저장소 (FlutterSecureStorage)
│   │
│   ├── themes/              # 테마 시스템
│   │   ├── app_theme.dart   # 메인 테마
│   │   ├── color_theme.dart # 색상 정의 (JSON 로드)
│   │   ├── app_typography.dart  # 타이포그래피
│   │   ├── app_spacing.dart     # 간격 토큰
│   │   ├── app_dimensions.dart  # 크기 토큰
│   │   └── responsive.dart      # 반응형 유틸리티
│   │
│   ├── router/              # 라우팅 (GoRouter)
│   ├── widgets/             # 공통 위젯
│   └── providers/           # 상태 관리
│
├── addons/                  # 선택적 기능 모듈
│   ├── addon_registry.dart  # Addon 등록/관리
│   ├── notification/        # 푸시 알림 (FCM)
│   ├── payment/             # 결제 (Stripe)
│   └── media/               # 미디어 (카메라, 갤러리)
│
└── domain/                  # 도메인 레이어 (DDD)
    ├── auth/                # 인증 (Email, Google, Apple)
    ├── user/                # 사용자 관리
    ├── settings/            # 설정
    ├── feedback/            # 피드백
    └── admin/               # 관리자
```

## 핵심 시스템

### 1. DataSource 시스템

중앙 집중식 데이터 관리 (RN의 DataSource 패턴과 유사):

```dart
// 초기화 (main.dart에서)
await DS.initialize(baseUrl: 'https://api.example.com');

// Remote - API 호출
final response = await DS.remote.get('/users');
final result = await DS.remote.post('/users', data: {'name': 'Kim'});

// Local - 로컬 저장소 (캐시)
await DS.local.set('user_settings', settingsJson);
final settings = await DS.local.get<Map>('user_settings');
await DS.local.setWithExpiry('cache_key', data, Duration(hours: 1));

// Secure - 보안 저장소 (토큰)
await DS.secure.setToken('access_token_value');
final token = await DS.secure.getToken();
await DS.secure.setRefreshToken('refresh_token_value');

// 전체 초기화 (로그아웃 시)
await DS.clearAll();
```

### 2. Addon 시스템

필요한 기능만 활성화하는 플러그인 구조:

```dart
// app_config.dart에서 토글
class AppConfig {
  static const bool enableNotification = true;
  static const bool enablePayment = false;
  static const bool enableMedia = true;
}

// main.dart에서 조건부 초기화
if (AppConfig.enableNotification) {
  AddonRegistry.register(NotificationAddon());
}
if (AppConfig.enablePayment) {
  AddonRegistry.register(PaymentAddon());
}

// 사용 시 안전하게 접근
if (NotificationHelper.isEnabled) {
  await NotificationHelper.instance?.sendNotification(
    title: 'Hello',
    body: 'World',
  );
}
```

### 3. 반응형 테마

디바이스별 자동 스케일링:

```dart
// Breakpoints
// Mobile: < 600px
// Tablet: 600px - 1024px
// Desktop: > 1024px

// Context extension 사용
if (context.isMobile) { /* 모바일 레이아웃 */ }
if (context.isTablet) { /* 태블릿 레이아웃 */ }
if (context.isDesktop) { /* 데스크톱 레이아웃 */ }

// 반응형 값 (디바이스별 다른 값)
final padding = context.responsive(
  mobile: 16.0,
  tablet: 24.0,
  desktop: 32.0,
);

// 또는 Responsive 유틸리티
final columns = Responsive.value<int>(
  context,
  mobile: 1,
  tablet: 2,
  desktop: 3,
);

// 반응형 간격 클래스
final spacing = ResponsiveSpacing(context);
Container(
  padding: spacing.pagePadding,  // 자동 스케일
  margin: spacing.cardPadding,
)
```

### 4. 테마 토큰

일관된 디자인 시스템:

```dart
// 색상 (colorset.json에서 로드)
AppColors.primary       // 메인 색상
AppColors.secondary     // 보조 색상
AppColors.background    // 배경색
AppColors.text          // 텍스트 색상
AppColors.accent        // 강조 색상

// 타이포그래피
AppTypography.headline1    // 32px Bold
AppTypography.headline2    // 24px Bold
AppTypography.bodyLarge    // 16px Regular
AppTypography.bodyRegular  // 14px Regular
AppTypography.caption      // 12px Regular

// 간격 토큰
AppSpacing.xs    // 4
AppSpacing.s     // 8
AppSpacing.m     // 12
AppSpacing.md    // 16
AppSpacing.lg    // 24
AppSpacing.xl    // 32
AppSpacing.xxl   // 40

// 위젯 간격 (SizedBox)
AppSpacing.v16   // SizedBox(height: 16)
AppSpacing.h8    // SizedBox(width: 8)

// 크기 토큰
AppDimensions.buttonHeight   // 48
AppDimensions.iconS          // 16
AppDimensions.iconM          // 24
AppDimensions.iconL          // 32
```

## 스크립트

| 스크립트 | 설명 |
|---------|------|
| `start.sh` | 새 프로젝트 초기화 (패키지명, Firebase, GitHub) |
| `scripts/permissions-setup.sh` | 플랫폼 권한 추가 |
| `scripts/flutterfire-setup.sh` | Firebase 연동 설정 |
| `scripts/firebase-setup.sh` | Firebase 프로젝트 생성 |
| `scripts/github-setup.sh` | GitHub 레포지토리 생성 |

### permissions-setup.sh 옵션

```bash
--camera        # 카메라 접근
--photos        # 사진 라이브러리 읽기/쓰기
--notifications # 푸시 알림
--location      # GPS 위치
--tracking      # 앱 추적 투명성 (iOS ATT)
--google-signin # Google 로그인 URL 스킴
--all           # 전체 권한
```

## Firebase 설정

### 플레이스홀더 파일

프로젝트에는 빌드를 위한 플레이스홀더가 포함되어 있습니다:

| 파일 | 플랫폼 | 설명 |
|------|--------|------|
| `lib/firebase_options.dart` | Flutter | Firebase 옵션 |
| `ios/Runner/GoogleService-Info.plist` | iOS | iOS 설정 |
| `android/app/google-services.json` | Android | Android 설정 |

`start.sh` 또는 `flutterfire configure` 실행 시 실제 값으로 교체됩니다.

### 지원 Firebase 서비스

- Firebase Auth (Email, Google, Apple 로그인)
- Cloud Firestore (NoSQL 데이터베이스)
- Firebase Storage (파일 저장소)
- Firebase Messaging (푸시 알림)
- Cloud Functions (서버리스 함수)

## 플랫폼 설정

### iOS (Info.plist)

기본 구성: 최소 필수 항목만 포함
- Bundle 정보
- UI 설정 (Orientation, Launch Screen)

권한은 `permissions-setup.sh`로 필요시 추가.

### Android (AndroidManifest.xml)

기본 구성:
- `INTERNET` - 네트워크 접근
- `ACCESS_NETWORK_STATE` - 네트워크 상태 확인

추가 권한은 `permissions-setup.sh`로 필요시 추가.

## 개발 가이드

### 새 도메인 추가

```
lib/domain/my_feature/
├── entities/           # 데이터 모델
│   └── my_entity.dart
├── functions/          # 비즈니스 로직
│   └── my_function.dart
└── presentation/       # UI
    ├── screens/
    └── widgets/
```

### 새 Addon 생성

```dart
// lib/addons/my_addon/my_addon.dart
class MyAddon extends Addon {
  @override
  String get name => 'my_addon';

  @override
  Future<void> initialize() async {
    // 초기화 로직
  }

  @override
  Future<void> dispose() async {
    // 정리 로직
  }
}

// Helper 클래스 (선택)
class MyAddonHelper {
  static bool get isEnabled => AddonRegistry.has<MyAddon>();
  static MyAddon? get instance => AddonRegistry.get<MyAddon>();
}
```

### API 연동

```dart
// GET 요청
final users = await DS.remote.get<List>('/users');

// POST 요청
final newUser = await DS.remote.post<Map>(
  '/users',
  data: {'name': 'Kim', 'email': 'kim@example.com'},
);

// 에러 처리
try {
  final result = await DS.remote.get('/protected');
} on DioException catch (e) {
  if (e.response?.statusCode == 401) {
    // 토큰 만료 처리
  }
}
```

## 명령어

```bash
# 개발
flutter run                    # 실행
flutter run -d chrome         # 웹에서 실행
flutter run --release         # 릴리즈 모드

# 빌드
flutter build apk             # Android APK
flutter build ios             # iOS
flutter build web             # 웹

# 품질 관리
flutter analyze               # 코드 분석
flutter test                  # 테스트 실행

# 유지보수
flutter clean                 # 빌드 캐시 정리
flutter pub get               # 의존성 설치
flutter pub upgrade           # 의존성 업그레이드
```

## 주요 의존성

### Core
- `firebase_core`, `firebase_auth`, `cloud_firestore`, `firebase_storage`
- `go_router` - 라우팅
- `dio` - HTTP 클라이언트
- `shared_preferences` - 로컬 저장소
- `flutter_secure_storage` - 보안 저장소

### UI
- `flutter_animate` - 애니메이션
- `google_fonts` - 폰트

### Optional (Addon)
- `firebase_messaging` - 푸시 알림
- `flutter_stripe` - 결제
- `image_picker` - 이미지 선택

## 문서

- `STRUCTURE.md` - AI용 프로젝트 구조 문서
- `docs/ui_guideline.md` - UI 가이드라인
- `docs/datasource/` - DataSource 패턴 문서

## 라이선스

Private - AppBuildChat
