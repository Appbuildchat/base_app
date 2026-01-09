/// =============================================================================
/// NOTIFICATION CONFIG (알림 설정)
/// =============================================================================
///
/// 알림 시스템의 모든 설정값을 관리하는 중앙 설정 클래스입니다.
///
/// 사용법:
/// 1. FCM 프로젝트 ID 및 서비스 계정 경로 설정
/// 2. Android/iOS 알림 채널 및 카테고리 설정
/// 3. FCM 데이터 키 상수 사용
///
/// 설정 변경 시:
/// - FCM 프로젝트 변경 시 fcmDefaultProjectId 수정
/// - 알림 채널 변경 시 Android 관련 상수 수정
/// - 데이터 키 추가 시 fcmDataKey 접두사로 추가
/// =============================================================================
class NotificationConfig {
  // FCM 설정
  static const String fcmDefaultProjectId =
      'appbuildchat-module-abc'; // 프로젝트 ID를 현재 프로젝트에 맞게 수정해주세요.
  static const String fcmServiceAccountCredentialsPath =
      'assets/data/auth.json';

  // Firestore 컬렉션
  static const String firestoreLogsCollection = 'notification_logs';

  // Android 알림 채널 설정
  static const String androidDefaultChannelId =
      'default_notification_channel_id';
  static const String androidDefaultChannelName = 'Default Notifications';
  static const String androidDefaultChannelDescription =
      'Channel for default app notifications';

  // iOS 알림 카테고리 및 사운드 설정
  static const String iosDefaultCategoryId = 'default_notification_category';
  static const String iosDefaultCategoryName = 'Default Notifications';
  static const String iosDefaultSound = 'default';
  static const int iosDefaultBadge = 1;

  // FCM 데이터 키
  static const String fcmDataKeyImageUrl = 'image_url';
  static const String fcmDataKeyRedirectUrl = 'redirect_url';
  static const String fcmDataKeyScreen = 'screen';
  static const String fcmDataKeyNotificationId = 'notification_id';
}

/// 앱에서 사용하는 모든 FCM 토픽을 중앙에서 관리합니다.
/// 토픽을 추가/제거할 때는 여기만 수정하면 됩니다.

class NotificationTopics {
  // 생성자 사용 불가 (static class)
  const NotificationTopics._();

  /// 앱에서 사용하는 모든 토픽 목록
  static const List<String> all = [
    'alarm', // 모든 알림
    'chat',
  ];

  /// 개별 토픽 상수들
  static const String alarm = 'alarm';
  static const String chat = 'chat';

  /// 토픽이 유효한지 확인
  static bool isValidTopic(String topic) {
    return all.contains(topic);
  }
}
