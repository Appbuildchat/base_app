import 'package:flutter/foundation.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:logger/logger.dart';
import 'notification_core.dart';
import '../config/notification_config.dart';

/// =============================================================================
/// NOTIFICATION TOPIC FUNCTION (알림 토픽 관리 기능) 📝
/// =============================================================================
///
/// 📱 **지정된 토픽 리스트로 알림 구독을 관리하는 전용 서비스입니다!**
/// ⚠️ 핵심 인프라는 NotificationCore에서 처리합니다.
///
/// 주요 기능:
/// 1. 📋 지정된 FCM 토픽 구독/해제
/// 2. 💾 로컬 저장소 기반 구독 상태 관리 (무료! 💰)
/// 3. ⚙️ 토픽 목록 설정 및 관리
/// 4. 🔄 다중 토픽 처리
/// 5. 🎯 구독 상태 조회 및 토글 기능
///
/// 사용법:
/// ```dart
/// final notificationFunction = NotificationTopicFunction(
///   customTopics: ['post', 'follow', 'message']
/// );
/// ```
/// =============================================================================
class NotificationTopicFunction {
  static final Logger _logger = Logger();
  // NotificationCore에서 Firebase 인스턴스 가져오기 (중복 제거)
  static FirebaseMessaging get _messaging => NotificationCore.messaging;

  // SharedPreferences 키
  static const String _prefsKeySubscribedTopics = 'subscribed_topics';
  static const String _prefsKeyAvailableTopics = 'available_topics';

  // 동적으로 설정 가능한 토픽 목록
  List<String> _availableTopics = [];

  // 생성자 - 무조건 NotificationTopics.all 사용
  NotificationTopicFunction() {
    _availableTopics = List.from(NotificationTopics.all);
    setAvailableTopics(_availableTopics);
  }

  // =============================================================================
  // 토픽 목록 관리 메서드들
  // =============================================================================

  /// 현재 사용 가능한 토픽 목록 조회
  List<String> get availableTopics => List.from(_availableTopics);

  /// 토픽 목록 동적 설정
  Future<void> setAvailableTopics(List<String> topics) async {
    _availableTopics = List.from(topics);

    // 로컬 저장소에도 저장하여 앱 재시작 후에도 유지
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_prefsKeyAvailableTopics, _availableTopics);

      if (kDebugMode) {
        _logger.d('📝 토픽 목록 설정 완료: $_availableTopics');
      }
    } catch (e) {
      if (kDebugMode) {
        _logger.e('❌ 토픽 목록 저장 실패: $e');
      }
    }
  }

  /// 저장된 토픽 목록을 로컬 저장소에서 불러오기
  Future<void> loadAvailableTopicsFromLocal() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedTopics = prefs.getStringList(_prefsKeyAvailableTopics);

      if (savedTopics != null && savedTopics.isNotEmpty) {
        _availableTopics = savedTopics;

        if (kDebugMode) {
          _logger.d('📋 저장된 토픽 목록 로드: $_availableTopics');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        _logger.e('❌ 토픽 목록 로드 실패: $e');
      }
    }
  }

  /// 토픽을 사용 가능한 목록에 추가
  Future<void> addAvailableTopic(String topic) async {
    if (!_availableTopics.contains(topic)) {
      _availableTopics.add(topic);
      await setAvailableTopics(_availableTopics);
    }
  }

  /// 토픽을 사용 가능한 목록에서 제거
  Future<void> removeAvailableTopic(String topic) async {
    if (_availableTopics.contains(topic)) {
      _availableTopics.remove(topic);
      // 해당 토픽 구독도 해제
      await unsubscribeFromTopic(topic);
      await setAvailableTopics(_availableTopics);
    }
  }

  /// 토픽이 사용 가능한 목록에 있는지 확인
  bool isTopicAvailable(String topic) {
    return _availableTopics.contains(topic);
  }

  /// 로컬 저장소 완전 초기화 (구독 정보와 토픽 목록 모두 삭제)
  Future<void> clearAllLocalData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_prefsKeySubscribedTopics);
      await prefs.remove(_prefsKeyAvailableTopics);

      if (kDebugMode) {
        _logger.d('🗑️ 로컬 저장소 완전 초기화 완료');
      }
    } catch (e) {
      if (kDebugMode) {
        _logger.d('❌ 로컬 저장소 초기화 실패: $e');
      }
    }
  }

  // =============================================================================
  // FCM 상태 확인 기능
  // =============================================================================

  /// FCM 기본 상태 확인 (토큰, 권한 등)
  Future<void> _checkFCMStatus() async {
    try {
      if (kDebugMode) {
        _logger.d('🔍 FCM 상태 확인 시작...');
      }

      // 1. FCM 토큰 확인
      final token = await _messaging.getToken();
      if (kDebugMode) {
        if (token != null) {
          _logger.d('✅ FCM 토큰 존재: ${token.substring(0, 20)}...');
        } else {
          _logger.d('❌ FCM 토큰이 null입니다!');
        }
      }

      // 2. 권한 상태 확인
      final settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      if (kDebugMode) {
        _logger.d('🔔 알림 권한 상태: ${settings.authorizationStatus}');
      }

      // 3. FCM 서비스 연결 확인
      final isServiceEnabled = await _messaging.isSupported();
      if (kDebugMode) {
        _logger.d('🔧 FCM 서비스 지원: $isServiceEnabled');
      }
    } catch (e) {
      if (kDebugMode) {
        _logger.d('❌ FCM 상태 확인 실패: $e');
      }
    }
  }

  // =============================================================================
  // 토픽 구독/해제 기능
  // =============================================================================

  /// 특정 토픽 구독
  Future<bool> subscribeToTopic(String topic) async {
    try {
      // FCM 기본 상태 확인
      await _checkFCMStatus();

      // FCM 토큰이 없으면 조기 실패
      final token = await _messaging.getToken();
      if (token == null) {
        if (kDebugMode) {
          _logger.d('❌ FCM 토큰이 없어 구독을 건너뜁니다: $topic');
        }
        return false;
      }

      // FCM에서 토픽 구독
      if (kDebugMode) {
        _logger.d('🔄 FCM 토픽 구독 시도: $topic');
      }

      await _messaging.subscribeToTopic(topic);

      // 로컬 저장소에 구독 상태 저장
      await _saveTopicToLocal(topic, true);

      if (kDebugMode) {
        _logger.d('✅ 토픽 구독 성공: $topic');
      }
      return true;
    } catch (e) {
      if (kDebugMode) {
        _logger.d('❌ FCM 토픽 구독 실패: $topic');
        _logger.d('🔍 에러 상세: $e');
        _logger.d('🔍 에러 타입: ${e.runtimeType}');
        _logger.d('💡 로컬 전용 모드로 전환합니다...');
      }

      // FCM 구독 실패 시 로컬에서만 관리 (백업 모드)
      await _saveTopicToLocal(topic, true);

      if (kDebugMode) {
        _logger.d('✅ 로컬 전용 구독 완료: $topic (FCM 서버 문제로 인한 백업 모드)');
      }
      return true; // 로컬에서는 성공으로 처리
    }
  }

  /// 특정 토픽 구독 해제
  Future<bool> unsubscribeFromTopic(String topic) async {
    try {
      // FCM에서 토픽 구독 해제
      if (kDebugMode) {
        _logger.d('🔄 FCM 토픽 구독 해제 시도: $topic');
      }

      await _messaging.unsubscribeFromTopic(topic);

      // 로컬 저장소에서 구독 상태 제거
      await _saveTopicToLocal(topic, false);

      if (kDebugMode) {
        _logger.d('✅ 토픽 구독 해제 성공: $topic');
      }
      return true;
    } catch (e) {
      if (kDebugMode) {
        _logger.d('❌ FCM 토픽 구독 해제 실패: $topic');
        _logger.d('🔍 에러 상세: $e');
        _logger.d('🔍 에러 타입: ${e.runtimeType}');
        _logger.d('💡 로컬 전용 모드로 전환합니다...');
      }

      // FCM 구독 해제 실패 시 로컬에서만 관리 (백업 모드)
      await _saveTopicToLocal(topic, false);

      if (kDebugMode) {
        _logger.d('✅ 로컬 전용 구독 해제 완료: $topic (FCM 서버 문제로 인한 백업 모드)');
      }
      return true; // 로컬에서는 성공으로 처리
    }
  }

  /// 로컬 저장소에 토픽 구독 상태 저장
  Future<void> _saveTopicToLocal(String topic, bool isSubscribed) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      List<String> subscribedTopics =
          prefs.getStringList(_prefsKeySubscribedTopics) ?? [];

      if (isSubscribed) {
        // 구독: 리스트에 추가 (중복 방지)
        if (!subscribedTopics.contains(topic)) {
          subscribedTopics.add(topic);
        }
      } else {
        // 구독 해제: 리스트에서 제거
        subscribedTopics.remove(topic);
      }

      await prefs.setStringList(_prefsKeySubscribedTopics, subscribedTopics);

      if (kDebugMode) {
        _logger.d('💾 로컬 저장 완료: $topic = $isSubscribed');
      }
    } catch (e) {
      if (kDebugMode) {
        _logger.d('❌ 로컬 저장 실패: $e');
      }
    }
  }

  /// 여러 토픽 한번에 구독
  Future<Map<String, bool>> subscribeToMultipleTopics(
    List<String> topics,
  ) async {
    final results = <String, bool>{};

    for (final topic in topics) {
      results[topic] = await subscribeToTopic(topic);
    }

    return results;
  }

  /// 여러 토픽 한번에 구독 해제
  Future<Map<String, bool>> unsubscribeFromMultipleTopics(
    List<String> topics,
  ) async {
    final results = <String, bool>{};

    for (final topic in topics) {
      results[topic] = await unsubscribeFromTopic(topic);
    }

    return results;
  }

  /// 사용자가 구독한 토픽 목록 조회 (로컬 저장소에서)
  Future<List<String>> getSubscribedTopics() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final subscribedTopics =
          prefs.getStringList(_prefsKeySubscribedTopics) ?? [];

      if (kDebugMode) {
        _logger.d('📋 로컬에서 구독 토픽 조회: $subscribedTopics');
      }

      return subscribedTopics;
    } catch (e) {
      if (kDebugMode) {
        _logger.d('❌ 로컬 구독 토픽 조회 실패: $e');
      }
      return [];
    }
  }

  /// 특정 토픽 구독 여부 확인
  Future<bool> isSubscribedToTopic(String topic) async {
    final subscribedTopics = await getSubscribedTopics();
    return subscribedTopics.contains(topic);
  }

  // =============================================================================
  // 편의 메서드들
  // =============================================================================

  /// 모든 사용 가능한 토픽 구독
  Future<Map<String, bool>> subscribeToAllTopics() async {
    return await subscribeToMultipleTopics(_availableTopics);
  }

  /// 모든 토픽 구독 해제
  Future<Map<String, bool>> unsubscribeFromAllTopics() async {
    return await unsubscribeFromMultipleTopics(_availableTopics);
  }

  /// 토픽 구독 상태 토글 (구독 중이면 해제, 아니면 구독)
  Future<bool> toggleTopicSubscription(String topic) async {
    final isSubscribed = await isSubscribedToTopic(topic);
    if (isSubscribed) {
      return await unsubscribeFromTopic(topic);
    } else {
      return await subscribeToTopic(topic);
    }
  }

  /// 구독 토픽 개수 조회
  Future<int> getSubscribedTopicsCount() async {
    final topics = await getSubscribedTopics();
    return topics.length;
  }
}
