# Notification Addon

FCM 푸시 알림 기능을 제공합니다.

## 활성화

```dart
// lib/app_config.dart
static const bool enableNotification = true;
```

```dart
// main.dart
import 'package:app/addons/addons.dart';

await AddonRegistry.initialize([
  if (AppConfig.enableNotification) NotificationAddon(),
]);
```

## 필요한 설정

### Android
`android/app/src/main/AndroidManifest.xml`:
```xml
<uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED"/>
<uses-permission android:name="android.permission.VIBRATE" />
```

### iOS
`ios/Runner/Info.plist`:
```xml
<key>UIBackgroundModes</key>
<array>
  <string>fetch</string>
  <string>remote-notification</string>
</array>
```

### Firebase
1. Firebase Console에서 프로젝트 생성
2. `google-services.json` (Android) 추가
3. `GoogleService-Info.plist` (iOS) 추가

## 사용법

### 권한 요청
```dart
import 'package:app/addons/addons.dart';

if (NotificationHelper.isEnabled) {
  await NotificationCore.requestPermission();
}
```

### 토픽 구독
```dart
await NotificationSettingsFunction.subscribeToTopic('news');
await NotificationSettingsFunction.unsubscribeFromTopic('news');
```

### FCM 토큰 가져오기
```dart
final token = await NotificationCore.getFcmToken();
```

## 파일 구조

```
notification/
├── notification_addon.dart    # Addon 진입점
└── README.md                  # 이 파일

# 원본 파일 (core/notification/)
├── config/notification_config.dart
├── entities/notification_entity.dart
└── function/
    ├── notification_core.dart
    ├── notification_initializer.dart
    └── notification_settings_function.dart
```
