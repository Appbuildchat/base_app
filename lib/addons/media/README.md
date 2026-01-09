# Media Addon

이미지/비디오 피커 및 업로드 기능을 제공합니다.

## 활성화

```dart
// lib/app_config.dart
static const bool enableMedia = true;
```

```dart
// main.dart
import 'package:app/addons/addons.dart';

await AddonRegistry.initialize([
  if (AppConfig.enableMedia) MediaAddon(
    storagePath: 'uploads',      // Firebase Storage 경로
    maxImageSize: 1024,          // 최대 이미지 크기 (px)
    compressionQuality: 80,      // 압축 품질 (0-100)
  ),
]);
```

## 필요한 설정

### Android
`android/app/src/main/AndroidManifest.xml`:
```xml
<uses-permission android:name="android.permission.CAMERA"/>
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"/>
```

### iOS
`ios/Runner/Info.plist`:
```xml
<key>NSCameraUsageDescription</key>
<string>카메라 접근이 필요합니다</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>사진 접근이 필요합니다</string>
<key>NSPhotoLibraryAddUsageDescription</key>
<string>사진 저장을 위해 접근이 필요합니다</string>
```

## 사용법

### 이미지 선택
```dart
import 'package:app/addons/addons.dart';

if (MediaHelper.isEnabled) {
  // 갤러리에서 선택
  final image = await MediaPickerUtils.pickImageFromGallery();

  // 카메라로 촬영
  final photo = await MediaPickerUtils.pickImageFromCamera();

  // 여러 이미지 선택
  final images = await MediaPickerUtils.pickMultipleImages();
}
```

### 이미지 압축
```dart
final compressed = await MediaPickerUtils.compressImage(
  file: imageFile,
  quality: MediaHelper.compressionQuality,
  maxSize: MediaHelper.maxImageSize,
);
```

### Firebase Storage 업로드
```dart
final url = await uploadImage(
  file: imageFile,
  path: '${MediaHelper.storagePath}/profile/${userId}.jpg',
);
```

### 이미지 크롭
```dart
final cropped = await MediaPickerUtils.cropImage(
  file: imageFile,
  aspectRatio: CropAspectRatio(ratioX: 1, ratioY: 1), // 정사각형
);
```

## 파일 구조

```
media/
├── media_addon.dart    # Addon 진입점
└── README.md           # 이 파일

# 원본 파일 (core/image_picker/)
├── media_picker_utils.dart
├── media_picker_widget.dart
├── upload_image.dart
└── custom_gallery_screen.dart
```
