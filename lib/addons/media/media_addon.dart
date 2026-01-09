/// Media Addon
///
/// 이미지/비디오 피커 및 업로드 기능을 제공합니다.
///
/// ## 활성화
/// ```dart
/// // app_config.dart
/// static const bool enableMedia = true;
///
/// // main.dart
/// await AddonRegistry.initialize([
///   if (AppConfig.enableMedia) MediaAddon(),
/// ]);
/// ```
///
/// ## 기능
/// - 이미지 선택 (카메라/갤러리)
/// - 이미지 압축 및 크롭
/// - Firebase Storage 업로드
/// - 비디오 썸네일 생성
library;

import 'package:go_router/go_router.dart';
import '../addon_registry.dart';

// 기존 image_picker 모듈 re-export
export '../../core/image_picker/media_picker_utils.dart';
export '../../core/image_picker/media_picker_widget.dart';
export '../../core/image_picker/upload_image.dart';
export '../../core/image_picker/custom_gallery_screen.dart';

/// Media Addon
///
/// 이미지/비디오 피커 및 업로드 기능을 제공합니다.
class MediaAddon extends Addon {
  /// Firebase Storage 버킷 경로
  final String storagePath;

  /// 최대 이미지 크기 (픽셀)
  final int maxImageSize;

  /// 압축 품질 (0-100)
  final int compressionQuality;

  MediaAddon({
    this.storagePath = 'uploads',
    this.maxImageSize = 1024,
    this.compressionQuality = 80,
  });

  @override
  String get name => 'media';

  @override
  String get description => 'Image/video picker and upload';

  @override
  Future<void> initialize() async {
    // 권한 관련 초기화는 필요시 진행
  }

  @override
  Future<void> dispose() async {
    // Cleanup if needed
  }

  @override
  List<RouteBase> get routes => [
    // 필요시 갤러리 화면 등 라우트 추가
  ];
}

/// Media Addon 헬퍼
///
/// ```dart
/// if (MediaHelper.isEnabled) {
///   final image = await MediaHelper.pickImage();
/// }
/// ```
class MediaHelper {
  MediaHelper._();

  /// Addon 활성화 여부
  static bool get isEnabled => AddonRegistry.has<MediaAddon>();

  /// Addon 인스턴스
  static MediaAddon? get instance => AddonRegistry.get<MediaAddon>();

  /// 스토리지 경로
  static String get storagePath => instance?.storagePath ?? 'uploads';

  /// 최대 이미지 크기
  static int get maxImageSize => instance?.maxImageSize ?? 1024;

  /// 압축 품질
  static int get compressionQuality => instance?.compressionQuality ?? 80;
}
