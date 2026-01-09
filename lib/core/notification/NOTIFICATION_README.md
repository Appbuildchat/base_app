# Notification(알림) 모듈 가이드

## 🚀 빠른 시작 가이드

### 1. 패키지 추가
`pubspec.yaml`에 필요한 패키지를 추가하세요:
```yaml
dependencies:
  firebase_messaging: ^15.1.10
  flutter_local_notifications: ^19.4.0
  cloud_functions: ^5.2.11
  shared_preferences: ^2.5.3
  permission_handler: ^12.0.1
  # (필요시) http, googleapis_auth 등
```

### 2. 모듈 임포트
사용하고자 하는 파일에서 필요한 클래스, 함수, 엔티티를 임포트하세요:
```dart
// 알림 코어
import 'package:appbuildchat_module/shared/notification/function/notification_core.dart';
// 알림 초기화
import 'package:appbuildchat_module/shared/notification/function/notification_initializer.dart';
// 토픽 관리
import 'package:appbuildchat_module/shared/notification/function/notification_settings_function.dart';
// 알림 엔티티
import 'package:appbuildchat_module/shared/notification/entities/notification_entity.dart';
// 알림 설정
import 'package:appbuildchat_module/shared/notification/config/notification_config.dart';
```

### 3. 초기화 및 권한 요청
앱 시작 시 알림 시스템을 반드시 초기화해야 합니다:
```dart
// main.dart 등에서 Firebase 초기화 후 호출
await NotificationInitializer.initialize();
await NotificationInitializer.initializeTopics(['chat', 'alarm']);
```

## 주요 기능

### 알림 코어 (`function/notification_core.dart`)
- FCM 토큰 관리 및 Firestore 저장
- 권한 요청 및 상태 확인
- 로컬 알림 초기화 및 표시
- 포그라운드/백그라운드 알림 처리
- 알림 클릭 시 네비게이션 처리

### 알림 초기화 (`function/notification_initializer.dart`)
- 앱 시작 시 알림 시스템 전체 초기화
- FCM 백그라운드 핸들러, 포그라운드 메시지, 클릭 이벤트 처리
- 토픽 구독 상태 복원

### 토픽 관리 (`function/notification_settings_function.dart`)
- FCM 토픽 구독/해제 및 로컬 저장
- 구독 상태 동기화

### 알림 엔티티 (`entities/notification_entity.dart`)
- 알림 데이터 구조 정의 (id, senderId, receiverId, title, body, data 등)

### 알림 설정 (`config/notification_config.dart`)
- FCM 프로젝트/채널/데이터키 등 알림 관련 상수 관리
- 사용 가능한 토픽 목록 관리
- 토픽 목록 및 유효성 검사

## 사용 방법

### 토픽 설정
```dart
class NotificationTopics {
  // 생성자 사용 불가 (static class)
  const NotificationTopics._();

  /// 앱에서 사용하는 모든 토픽 목록
  static const List<String> all = [
    'alarm',
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
```
notification_config.dart 파일에서 해당 앱에서 사용할 topic들을 설정합니다.
```dart
static const List<String> all = [
    'alarm',
    'chat',
    ...,
    'post',
    ];

static const String alarm = 'alarm';
static const String chat = 'chat';
static const String ... = '...';
static const String post = 'post';
```
이런 식으로 설정해주시면 됩니다. topic 구분이 필요없을 경우, 'alarm' 하나만 넣어주세요.
해당 이름으로 settings/presentation/screens/notification_settings_screen.dart에서 구독 설정 및 해제할 수 있는 토픽들이 자동으로 갱신됩니다.


### 실제 사용 예시
```dart
Future<Result<void>> sendMessage(
  String chatRoomId,
  TextEditingController controller,
  {bool isImage = false, bool isVideo = false,}
) async {
  try {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return Result.failure(
        AppErrorCode.authNotLoggedIn,
        message: 'User not authenticated',
      );
    }

    if (controller.text.trim().isEmpty) {
      return Result.failure(
        AppErrorCode.validationError,
        message: 'Message cannot be empty',
      );
    }

    final chatRef = FirebaseFirestore.instance
        .collection('chats')
        .doc(chatRoomId);

    final chatDoc = await chatRef.get();
    if (!chatDoc.exists) {
      return Result.failure(
        AppErrorCode.backendResourceNotFound,
        message: 'Chat room not found',
      );
    }

    final messages = Map<String, dynamic>.from(
      chatDoc.data()?['messages'] ?? {},
    );
    final messageId = DateTime.now().millisecondsSinceEpoch.toString();
    messages[messageId] = {
      'text': controller.text.trim(),
      'senderId': user.uid,
      'timestamp': FieldValue.serverTimestamp(),
      'read': false, // Add read status, initially false
      'isImage': isImage,
      'isVideo': isVideo,
    };

    await chatRef.update({
      'messages': messages,
      'lastMessage': controller.text.trim(),
      'lastMessageTime': FieldValue.serverTimestamp(),
      'lastMessageSenderId': user.uid,
    });

    controller.clear();
    await markAsRead(chatRoomId);

    // ===== FCM PUSH NOTIFICATION =====
    // 1. 상대방 userId 추출
    final chatData = chatDoc.data() as Map<String, dynamic>;
    final users = List<String>.from(chatData['users'] ?? []);
    final otherUserId = users.firstWhere((id) => id != user.uid, orElse: () => '');
    if (otherUserId.isNotEmpty) {
      final userResult = await fetchUserDetails(otherUserId);
      // 내 userName 조회
      String senderName = user.displayName ?? user.email ?? 'Unknown';
      final myUserResult = await fetchUserDetails(user.uid);
      if (myUserResult.isSuccess && myUserResult.data != null && myUserResult.data!.userName.isNotEmpty) {
        senderName = myUserResult.data!.userName;
      }
      if (userResult.isSuccess && userResult.data?.fcmToken != null && userResult.data!.fcmToken!.isNotEmpty) {
        final receiverFcmToken = userResult.data!.fcmToken!;
        final content = isImage ? 'Image' : controller.text.trim();
        try {
          final HttpsCallable callable = FirebaseFunctions.instance.httpsCallable('sendNotification');
          await callable.call({
            'tokens': [receiverFcmToken],
            'title': senderName,
            'body': content,
            'topic': 'chat',
          });
        } catch (e) {
          debugPrint('FCM push notification error: ${e.toString()}');
        }
      }
    }
    // ===== END FCM PUSH =====

    return Result.success(null);
  } catch (e) {
    return Result.failure(
      AppErrorCode.backendUnknownError,
      message: 'Failed to send message: ${e.toString()}',
    );
  }
}
```
채팅을 보낼 때 FCM 메시지를 보내는 예시입니다. 'topic'에 'chat'이 들어가 있는 것을 확인해주세요.
topic을 같이 전달하지 않을 경우, 토픽 구독에 상관없이 메시지가 전송됩니다.
topic 구분이 없는 경우, 'topic': 'alarm'을 반드시 함께 넣어주어야 합니다.

## 주의사항
- Firebase 초기화 후 반드시 NotificationInitializer.initialize() 호출 필요
- FCM 토큰은 Firestore users 컬렉션에 저장됨
- Cloud Function 배포 및 권한 설정 필요
- iOS/Android 권한 설정(Info.plist, AndroidManifest.xml) 필수
- 알림 클릭 시 라우팅 처리는 go_router 기반 