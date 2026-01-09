// 알림 관련 설정 초기화 코드

import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../config/notification_config.dart'; // NotificationConfig 임포트
import 'notification_core.dart';
import 'notification_settings_function.dart';
import '../../router/app_router.dart';

final _logger = Logger();

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  _logger.d("🔔 Handling a background message: ${message.messageId}");
  _logger.d("   Background Notification Title: ${message.notification?.title}");
  _logger.d("   Background Notification Body: ${message.notification?.body}");
  _logger.d("   Background Notification Data: ${message.data}");
}

/// =============================================================================
/// NOTIFICATION INITIALIZER (알림 초기화)
/// =============================================================================
///
/// 앱 시작 시 알림 시스템을 초기화하고 설정하는 클래스입니다.
///
/// 주요 기능:
/// 1. FCM 백그라운드 메시지 핸들러 설정
/// 2. 포그라운드 메시지 수신 처리
/// 3. 알림 클릭 시 네비게이션 처리 (go_router 사용)
/// 4. 권한 요청 및 로컬 알림 초기화
///
/// 네비게이션:
/// - 알림 데이터의 'screen' 키를 통해 라우트 결정
/// - go_router의 globalRouter를 사용하여 네비게이션
/// =============================================================================
class NotificationInitializer {
  static FirebaseMessaging get _firebaseMessaging => NotificationCore.messaging;
  static final NotificationCore _notificationService = NotificationCore();

  /// 토픽 기반 알림 시스템 초기화 (main.dart에서 호출)
  static Future<void> initializeTopics(List<String> customTopics) async {
    try {
      // SharedPreferences에서 영구 플래그 확인
      final prefs = await SharedPreferences.getInstance();
      final isFirstTime = prefs.getBool('notification_first_setup') ?? true;

      final notificationService = NotificationTopicFunction();

      if (isFirstTime) {
        // 🎯 첫 실행: 모든 토픽을 기본 구독
        _logger.i('🎯 앱 최초 실행 - 모든 토픽 기본 구독');

        // 이전 구독 정보 완전 삭제 (최초 설치 시에만)
        await notificationService.clearAllLocalData();

        // 모든 커스텀 토픽 구독 (기본값으로 설정)
        await notificationService.subscribeToAllTopics();

        // 영구 플래그 저장 (다음에는 실행되지 않음)
        await prefs.setBool('notification_first_setup', false);

        _logger.i('✅ 알림 토픽 최초 설정 완료 (모든 토픽 구독됨)');
      } else {
        // 🔄 재실행: 사용자의 설정에 따라 토픽 상태 복원
        _logger.i('🔄 앱 재실행 - 사용자 설정에 따른 토픽 상태 복원');

        final subscribedTopics = await notificationService
            .getSubscribedTopics();
        final availableTopics = notificationService.availableTopics;

        _logger.i('📋 저장된 구독 토픽: $subscribedTopics');
        _logger.i('📋 사용 가능한 토픽: $availableTopics');

        // 사용자 설정에 따라 토픽 상태 동기화
        for (final topic in availableTopics) {
          final shouldBeSubscribed = subscribedTopics.contains(topic);

          if (shouldBeSubscribed) {
            // FCM에 구독 상태 재적용 (로컬 저장소 상태와 동기화)
            await notificationService.subscribeToTopic(topic);
            _logger.d('🔄 토픽 구독 복원: $topic');
          } else {
            // FCM에서 구독 해제 상태 재적용
            await notificationService.unsubscribeFromTopic(topic);
            _logger.d('🔄 토픽 구독 해제 유지: $topic');
          }
        }

        _logger.i('✅ 사용자 설정에 따른 토픽 상태 복원 완료');
      }

      _logger.i("✅ NotificationInitializer: Topics initialized successfully.");
    } catch (e, stackTrace) {
      _logger.e("❌ Error initializing topics: $e");
      _logger.e("Stack trace: $stackTrace");
    }
  }

  static Future<void> initialize() async {
    try {
      // FirebaseApp이 초기화되었는지 확인 (main.dart에서 이미 수행됨)
      if (Firebase.apps.isEmpty) {
        throw Exception(
          "Firebase.initializeApp() must be called before NotificationInitializer.initialize()",
        );
      }

      await NotificationCore.requestAllPermissions();
      await _notificationService.initializeLocalNotifications();
      await _notificationService.updateAndSaveToken();

      FirebaseMessaging.onBackgroundMessage(
        _firebaseMessagingBackgroundHandler,
      );
      _setupForegroundMessageHandler();
      await _setupInteractedMessageHandler();

      _logger.i("✅ NotificationInitializer: All notifications initialized.");
    } catch (e, stackTrace) {
      _logger.e("❌ Error initializing notifications: $e");
      _logger.e("Stack trace: $stackTrace");
    }
  }

  static void _setupForegroundMessageHandler() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _logger.d('Foreground message received: ${message.messageId}');
      _logger.d('  Message data: ${message.data}');
      _logger.d(
        '  Message notification: ${message.notification?.title} - ${message.notification?.body}',
      );

      // 포그라운드에서 로컬 알림 표시
      _notificationService.showNotificationFromFCM(message);
    });
  }

  static Future<void> _setupInteractedMessageHandler() async {
    // 앱이 종료된 상태에서 알림을 탭하여 열렸을 때 메시지 가져오기
    RemoteMessage? initialMessage = await _firebaseMessaging
        .getInitialMessage();
    if (initialMessage != null) {
      _logger.d('🔔 Initial message received: ${initialMessage.messageId}');
      _handlePayloadNavigation(jsonEncode(initialMessage.data));
    }

    // 앱이 백그라운드에 있을 때 알림을 탭하여 열렸을 때
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _logger.d('🔔 Message opened app: ${message.messageId}');
      _handlePayloadNavigation(jsonEncode(message.data));
    });
  }

  static void _handlePayloadNavigation(String payload) {
    _logger.d("Handling payload navigation: $payload");
    if (globalRouter == null) {
      _logger.w("Global router is null. Cannot navigate.");
      return;
    }

    try {
      final Map<String, dynamic> data = jsonDecode(payload);
      // NotificationConfig의 키를 사용하여 라우트 정보 추출 시도
      final String? targetRoute =
          data[NotificationConfig.fcmDataKeyScreen] ??
          data['route'] ?? // 기존 호환성 유지
          data['targetRoute'] ?? // 기존 호환성 유지
          data['click_action']; // 기존 호환성 유지

      if (targetRoute != null) {
        _logger.d("Navigating to route: $targetRoute with data: $data");

        // go_router를 사용하여 네비게이션 처리
        if (targetRoute.startsWith('/')) {
          // 경로가 '/'로 시작하면 직접 go 사용
          globalRouter!.go(targetRoute, extra: data);
        } else {
          // 경로 이름으로 가정하여 '/' 추가
          globalRouter!.go('/$targetRoute', extra: data);
        }
      } else {
        _logger.d(
          "No specific route in payload. Default navigation or action can be defined here.",
        );
        // 예: 기본 알림 목록 화면으로 이동
        // globalRouter!.go('/notifications', extra: data);
      }
    } catch (e) {
      _logger.e("Error decoding payload or navigating: $e. Payload: $payload");
    }
  }
}
