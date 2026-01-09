import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:logger/logger.dart';

import '../entities/notification_entity.dart';
import '../config/notification_config.dart';

/// =============================================================================
/// NOTIFICATION CORE (알림 핵심 인프라) 🔧
/// =============================================================================
///
/// 알림 시스템의 핵심 인프라를 담당하는 서비스 클래스입니다.
/// ⚠️ 토픽 관리는 NotificationTopicService에서 처리합니다.
///
/// 주요 기능:
/// 1. 🔥 Firebase 인스턴스 중앙 관리 (FCM, Firestore)
/// 2. 🔑 FCM 토큰 관리 및 갱신
/// 3. 🛡️ iOS/Android 권한 요청 통합 처리
/// 4. 🔔 로컬 알림 초기화 및 표시
/// 5. 📱 포그라운드 알림 처리
/// 6. 📨 알림 메시지 핸들링
///
/// =============================================================================
class NotificationCore {
  static final NotificationCore _instance = NotificationCore._internal();
  factory NotificationCore() => _instance;
  NotificationCore._internal();

  // Firebase 인스턴스들을 static으로 제공하여 다른 클래스에서 사용 가능하도록 함
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final Logger _logger = Logger();
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // 다른 클래스에서 Firebase 인스턴스에 접근할 수 있도록 getter 제공
  static FirebaseMessaging get messaging => _messaging;
  static FirebaseFirestore get firestore => _firestore;

  // APNS 토큰 준비 대기 (iOS 전용)
  Future<void> ensureAPNSTokenReady() async {
    if (!Platform.isIOS) return;

    final apnsToken = await _messaging.getAPNSToken();

    if (apnsToken == null) {
      if (kDebugMode) {
        _logger.w('❌ APNS 토큰을 가져오지 못했습니다.');
      }
    } else {
      if (kDebugMode) {
        _logger.d('✅ APNS 토큰 준비됨: ${apnsToken.substring(0, 10)}...');
      }
    }
  }

  // FCM 토큰 관리
  Future<String?> getToken() async {
    if (!kIsWeb && Platform.isIOS) {
      await ensureAPNSTokenReady();
    }
    return await _messaging.getToken();
  }

  Future<void> updateAndSaveToken() async {
    try {
      String? token;

      if (!kIsWeb && Platform.isIOS) {
        // iOS에서는 APNS 토큰 확인 후 FCM 토큰 획득
        await ensureAPNSTokenReady();

        token = await _messaging.getToken();
      } else if (!kIsWeb && Platform.isAndroid) {
        // Android에서는 바로 FCM 토큰 획득
        token = await _messaging.getToken();
      }

      if (kDebugMode) {
        _logger.d('🔑 FCM Token: $token');
      }

      if (token != null) {
        await _saveToken(token);
      }

      _messaging.onTokenRefresh.listen((newToken) async {
        if (kDebugMode) {
          _logger.d('🔑 FCM Token refreshed: $newToken');
        }
        await _saveToken(newToken);
      });
    } catch (e) {
      if (kDebugMode) {
        _logger.e('Error updating FCM token: $e');
      }
    }
  }

  Future<void> _saveToken(String token) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        await _firestore.collection('users').doc(user.uid).set({
          'fcmToken': token,
        }, SetOptions(merge: true));
        if (kDebugMode) {
          _logger.d('FCM token saved to Firestore for user ${user.uid}');
        }
      } catch (e) {
        if (kDebugMode) {
          _logger.e('Error saving FCM token to Firestore: $e');
        }
      }
    }
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('fcm_token', token);
      if (kDebugMode) {
        _logger.d('FCM token saved to SharedPreferences');
      }
    } catch (e) {
      if (kDebugMode) {
        _logger.e('Error saving FCM token to SharedPreferences: $e');
      }
    }
  }

  /// Delete FCM token (for sign out)
  Future<void> deleteToken() async {
    await FirebaseMessaging.instance.deleteToken();
  }

  // 통합 알림 권한 요청 (iOS FCM + Android 로컬 알림)
  static Future<bool> requestAllPermissions() async {
    if (kIsWeb) return true;

    bool allGranted = true;

    // iOS FCM 권한 요청
    if (Platform.isIOS) {
      final settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        announcement: false,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        if (kDebugMode) {
          _logger.i('✅ iOS FCM 권한이 승인되었습니다.');
        }
        await _messaging.setForegroundNotificationPresentationOptions(
          alert: true,
          badge: true,
          sound: true,
        );
      } else {
        if (kDebugMode) {
          _logger.w('❌ iOS FCM 권한이 거부되었습니다: ${settings.authorizationStatus}');
        }
        allGranted = false;
      }
    }

    // Android 로컬 알림 권한 요청
    if (Platform.isAndroid) {
      var status = await Permission.notification.status;
      if (status.isDenied) {
        if (kDebugMode) {
          _logger.d('🔔 Android 알림 권한 요청 중...');
        }
        status = await Permission.notification.request();
      }

      if (status.isGranted) {
        if (kDebugMode) {
          _logger.i('✅ Android 알림 권한이 승인되었습니다.');
        }
      } else {
        if (kDebugMode) {
          _logger.w('❌ Android 알림 권한이 거부되었습니다: $status');
        }
        allGranted = false;
      }
    }

    return allGranted;
  }

  // 기존 메서드 유지 (호환성)
  Future<NotificationSettings> requestPermission() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      announcement: false,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      if (kDebugMode) {
        _logger.i('✅ FCM 권한이 승인되었습니다.');
      }
      await _messaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );
    } else {
      if (kDebugMode) {
        _logger.w('❌ FCM 권한이 거부되었습니다: ${settings.authorizationStatus}');
      }
    }

    return settings;
  }

  // 알림 메시지 처리
  void handleMessage(RemoteMessage message) {
    final notification = NotificationEntity(
      id: message.messageId ?? DateTime.now().millisecondsSinceEpoch.toString(),
      senderId: message.from,
      receiverId: message.data['receiverId'] ?? '',
      title: message.notification?.title ?? '',
      body: message.notification?.body ?? '',
      data: message.data.map((key, value) => MapEntry(key, value.toString())),
      sentAt: DateTime.now(),
      isSuccess: true,
    );

    if (kDebugMode) {
      _logger.d('알림 수신: ${notification.title}');
    }
  }

  // 포그라운드 알림 처리를 위한 설정
  Future<void> setupForegroundNotification() async {
    await _messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  // 로컬 알림 초기화
  Future<void> initializeLocalNotifications() async {
    // Android 초기화 설정
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS 초기화 설정
    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        );

    const InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsIOS,
          macOS: initializationSettingsIOS,
        );

    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        _handleNotificationTap(response);
      },
    );

    // Android 알림 채널 생성
    if (Platform.isAndroid) {
      await _createNotificationChannel();
    }

    if (kDebugMode) {
      _logger.d('✅ LocalNotificationService initialized');
    }
  }

  Future<void> _createNotificationChannel() async {
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      NotificationConfig.androidDefaultChannelId,
      NotificationConfig.androidDefaultChannelName,
      description: NotificationConfig.androidDefaultChannelDescription,
      importance: Importance.high,
      sound: RawResourceAndroidNotificationSound('notification'),
    );

    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);
  }

  Future<void> showNotificationFromFCM(RemoteMessage message) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
          NotificationConfig.androidDefaultChannelId,
          NotificationConfig.androidDefaultChannelName,
          channelDescription:
              NotificationConfig.androidDefaultChannelDescription,
          importance: Importance.high,
          priority: Priority.high,
          showWhen: true,
          icon: '@mipmap/ic_launcher',
        );

    const DarwinNotificationDetails iOSPlatformChannelSpecifics =
        DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
      macOS: iOSPlatformChannelSpecifics,
    );

    final String title = message.notification?.title ?? '새 알림';
    final String body = message.notification?.body ?? '';

    // 알림 ID를 메시지 ID에서 생성 (해시코드 사용)
    final int notificationId =
        message.messageId?.hashCode ??
        DateTime.now().millisecondsSinceEpoch.toInt();

    await _flutterLocalNotificationsPlugin.show(
      notificationId,
      title,
      body,
      platformChannelSpecifics,
      payload: message.data.isNotEmpty
          ? _encodeData(_convertToStringMap(message.data))
          : null,
    );

    if (kDebugMode) {
      _logger.d('🔔 로컬 알림 표시됨: $title - $body');
    }
  }

  Future<void> showCustomNotification({
    required int id,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
          NotificationConfig.androidDefaultChannelId,
          NotificationConfig.androidDefaultChannelName,
          channelDescription:
              NotificationConfig.androidDefaultChannelDescription,
          importance: Importance.high,
          priority: Priority.high,
          showWhen: true,
          icon: '@mipmap/ic_launcher',
        );

    const DarwinNotificationDetails iOSPlatformChannelSpecifics =
        DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
      macOS: iOSPlatformChannelSpecifics,
    );

    await _flutterLocalNotificationsPlugin.show(
      id,
      title,
      body,
      platformChannelSpecifics,
      payload: data != null
          ? _encodeData(data.map((k, v) => MapEntry(k, v.toString())))
          : null,
    );

    if (kDebugMode) {
      _logger.d('🔔 커스텀 로컬 알림 표시됨: $title - $body');
    }
  }

  void _handleNotificationTap(NotificationResponse response) {
    if (kDebugMode) {
      _logger.d('알림 탭됨: ${response.payload}');
    }

    // 알림 탭 시 처리할 로직을 여기에 추가
    // 예: 특정 화면으로 이동
    if (response.payload != null) {
      _decodeData(response.payload!);
      // 네비게이션 처리 등...
    }
  }

  String _encodeData(Map<String, String> data) {
    return data.entries.map((e) => '${e.key}=${e.value}').join('&');
  }

  Map<String, String> _decodeData(String payload) {
    final Map<String, String> data = {};
    final pairs = payload.split('&');
    for (final pair in pairs) {
      final keyValue = pair.split('=');
      if (keyValue.length == 2) {
        data[keyValue[0]] = keyValue[1];
      }
    }
    return data;
  }

  Map<String, String> _convertToStringMap(Map<String, dynamic> data) {
    return data.map((key, value) => MapEntry(key, value.toString()));
  }
}
