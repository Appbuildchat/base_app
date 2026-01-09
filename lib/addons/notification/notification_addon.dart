/// Notification Addon
///
/// FCM 푸시 알림 기능을 제공합니다.
///
/// ## 활성화
/// ```dart
/// // app_config.dart
/// static const bool enableNotification = true;
///
/// // main.dart
/// await AddonRegistry.initialize([
///   if (AppConfig.enableNotification) NotificationAddon(),
/// ]);
/// ```
///
/// ## 기능
/// - FCM 토큰 관리
/// - 로컬 알림
/// - 토픽 구독/해제
/// - 알림 권한 요청
library;

import 'package:go_router/go_router.dart';
import '../addon_registry.dart';

// 기존 notification 모듈 re-export
export '../../core/notification/config/notification_config.dart';
export '../../core/notification/entities/notification_entity.dart';
export '../../core/notification/function/notification_core.dart';
export '../../core/notification/function/notification_initializer.dart';
export '../../core/notification/function/notification_settings_function.dart';

// 기존 import
import '../../core/notification/function/notification_initializer.dart';
import '../../domain/notifications/presentation/screens/notifications_screen.dart';

/// Notification Addon
///
/// FCM + 로컬 알림 기능을 제공합니다.
class NotificationAddon extends Addon {
  @override
  String get name => 'notification';

  @override
  String get description => 'FCM push notification support';

  @override
  Future<void> initialize() async {
    // 기존 NotificationInitializer 사용
    await NotificationInitializer.initialize();
  }

  @override
  Future<void> dispose() async {
    // 필요시 cleanup
  }

  @override
  List<RouteBase> get routes => [
    GoRoute(
      path: '/notifications',
      name: 'notifications',
      builder: (context, state) => const NotificationsScreen(),
    ),
  ];
}

/// Notification Addon 헬퍼
///
/// ```dart
/// if (NotificationHelper.isEnabled) {
///   await NotificationHelper.requestPermission();
/// }
/// ```
class NotificationHelper {
  NotificationHelper._();

  /// Addon 활성화 여부
  static bool get isEnabled => AddonRegistry.has<NotificationAddon>();

  /// Addon 인스턴스
  static NotificationAddon? get instance =>
      AddonRegistry.get<NotificationAddon>();
}
