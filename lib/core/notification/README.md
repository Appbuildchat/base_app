# Notification

The Notification module provides comprehensive push notification functionality using Firebase Cloud Messaging (FCM) and local notifications. It handles notification configuration, delivery, and user interaction management.

## Folder Structure

```
lib/core/notification/
├── NOTIFICATION_README.md      # Existing Korean documentation
├── config/                     # Configuration files
├── entities/                   # Data models for notifications
└── function/                   # Business logic functions
```

## Key Features

### 1. Firebase Cloud Messaging (FCM)
- **Remote Notifications**: Server-sent push notifications
- **Token Management**: Device registration and token handling
- **Topic Subscriptions**: Group messaging capabilities
- **Background Processing**: Handle notifications when app is not active

### 2. Local Notifications
- **Scheduled Notifications**: Time-based local alerts
- **Custom Styling**: Branded notification appearance
- **Action Buttons**: Interactive notification responses
- **Sound and Vibration**: Custom alert patterns

### 3. Notification Management
- **Permission Handling**: Request and manage notification permissions
- **Delivery Tracking**: Monitor notification delivery status
- **User Preferences**: Notification settings and preferences
- **Analytics Integration**: Track notification engagement

## Package Dependencies

Required packages in `pubspec.yaml`:
```yaml
dependencies:
  firebase_messaging: ^15.1.10
  flutter_local_notifications: ^19.4.0
```

## Configuration

### Android Setup
Configure Android notification channels and permissions in:
- `android/app/src/main/AndroidManifest.xml`
- `android/app/build.gradle`

### iOS Setup
Configure iOS notification settings in:
- `ios/Runner/Info.plist`
- Enable push notifications in Xcode capabilities

## Usage

### Initialize Notifications
```dart
import '../core/notification/function/notification_service.dart';

// Initialize notification service
await NotificationService.initialize();

// Request permissions
await NotificationService.requestPermissions();
```

### Send Local Notification
```dart
import '../core/notification/function/local_notification.dart';

await LocalNotification.show(
  id: 1,
  title: 'Local Notification',
  body: 'This is a local notification',
  payload: 'custom_data',
);
```

### Schedule Notification
```dart
import '../core/notification/function/scheduled_notification.dart';

await ScheduledNotification.schedule(
  id: 2,
  title: 'Scheduled Notification',
  body: 'This notification was scheduled',
  scheduledDate: DateTime.now().add(Duration(hours: 1)),
);
```

### Handle FCM Messages
```dart
import '../core/notification/function/fcm_handler.dart';

// Handle foreground messages
FirebaseMessaging.onMessage.listen((RemoteMessage message) {
  FCMHandler.handleForegroundMessage(message);
});

// Handle background messages
FirebaseMessaging.onBackgroundMessage(FCMHandler.backgroundMessageHandler);
```

### Get FCM Token
```dart
import '../core/notification/function/token_manager.dart';

String? token = await TokenManager.getFCMToken();
if (token != null) {
  // Send token to your server
  await sendTokenToServer(token);
}
```

### Subscribe to Topics
```dart
import '../core/notification/function/topic_manager.dart';

// Subscribe to topic
await TopicManager.subscribeToTopic('news_updates');

// Unsubscribe from topic
await TopicManager.unsubscribeFromTopic('news_updates');
```

## Notification Types

### Push Notifications
Server-sent notifications via FCM:
- Marketing messages
- User engagement notifications
- System alerts
- Real-time updates

### Local Notifications
App-generated notifications:
- Reminders and alarms
- Scheduled content
- Offline notifications
- App state changes

### Interactive Notifications
Notifications with action buttons:
- Quick reply functionality
- Accept/decline actions
- Custom response options
- Deep linking support

## Permission Management

### Request Permissions
```dart
import '../core/notification/function/permission_manager.dart';

NotificationPermissionStatus status = await PermissionManager.requestPermissions();

switch (status) {
  case NotificationPermissionStatus.granted:
    // Notifications enabled
    break;
  case NotificationPermissionStatus.denied:
    // Handle denied permissions
    break;
  case NotificationPermissionStatus.restricted:
    // Handle restricted permissions
    break;
}
```

### Check Permission Status
```dart
bool hasPermission = await PermissionManager.hasNotificationPermission();
if (!hasPermission) {
  // Guide user to enable notifications
}
```

## Notification Channels (Android)

### Create Notification Channels
```dart
import '../core/notification/config/notification_channels.dart';

await NotificationChannels.createChannels([
  NotificationChannel(
    id: 'general',
    name: 'General Notifications',
    description: 'General app notifications',
    importance: Importance.high,
  ),
  NotificationChannel(
    id: 'promotions',
    name: 'Promotions',
    description: 'Marketing and promotional notifications',
    importance: Importance.normal,
  ),
]);
```

## Custom Notification Styles

### Big Text Style
```dart
await LocalNotification.showBigText(
  id: 3,
  title: 'Long Message',
  body: 'This is a very long notification message that will be displayed in expanded form when the user expands the notification.',
  bigText: 'Additional detailed information goes here...',
);
```

### Big Picture Style
```dart
await LocalNotification.showBigPicture(
  id: 4,
  title: 'Image Notification',
  body: 'Check out this image',
  bigPicture: 'https://example.com/image.jpg',
);
```

### Progress Style
```dart
await LocalNotification.showProgress(
  id: 5,
  title: 'Download Progress',
  body: 'Downloading file...',
  progress: 75,
  maxProgress: 100,
);
```

## Notification Actions

### Add Action Buttons
```dart
await LocalNotification.showWithActions(
  id: 6,
  title: 'Action Notification',
  body: 'Choose an action',
  actions: [
    NotificationAction(
      id: 'accept',
      title: 'Accept',
    ),
    NotificationAction(
      id: 'decline',
      title: 'Decline',
    ),
  ],
);
```

### Handle Action Responses
```dart
import '../core/notification/function/action_handler.dart';

NotificationActionHandler.onActionSelected = (String actionId, String? payload) {
  switch (actionId) {
    case 'accept':
      // Handle accept action
      break;
    case 'decline':
      // Handle decline action
      break;
  }
};
```

## Deep Linking

### Handle Notification Taps
```dart
import '../core/notification/function/deep_link_handler.dart';

// Handle notification tap when app is terminated
String? initialMessage = await FirebaseMessaging.instance.getInitialMessage();
if (initialMessage != null) {
  DeepLinkHandler.handleMessage(initialMessage);
}

// Handle notification tap when app is in background
FirebaseMessaging.onMessageOpenedApp.listen(DeepLinkHandler.handleMessage);
```

### Navigate to Specific Screens
```dart
class DeepLinkHandler {
  static void handleMessage(RemoteMessage message) {
    String? route = message.data['route'];
    String? id = message.data['id'];
    
    if (route != null) {
      GoRouter.of(context).push(route, extra: {'id': id});
    }
  }
}
```

## Analytics and Tracking

### Track Notification Events
```dart
import '../core/notification/function/notification_analytics.dart';

// Track notification received
NotificationAnalytics.trackNotificationReceived(
  notificationId: 'notification_123',
  type: 'promotion',
);

// Track notification opened
NotificationAnalytics.trackNotificationOpened(
  notificationId: 'notification_123',
  actionTaken: 'opened_app',
);
```

## Error Handling

### Common Error Scenarios
- Permission denied by user
- Network connectivity issues
- Invalid FCM tokens
- Notification delivery failures
- Channel configuration errors

### Error Recovery
```dart
import '../core/notification/function/error_handler.dart';

try {
  await NotificationService.sendNotification(notification);
} catch (e) {
  NotificationErrorHandler.handleError(e);
}
```

## Testing Notifications

### Test Local Notifications
```dart
// Test immediate notification
await LocalNotification.testNotification();

// Test scheduled notification
await ScheduledNotification.testScheduled();
```

### Test FCM Integration
- Use Firebase Console to send test messages
- Test notification delivery in different app states
- Verify deep linking functionality
- Test notification actions and responses

## Important Notes

- Notification permissions must be requested from users on both iOS and Android
- iOS requires explicit user consent for notifications
- Android notification channels are required for API level 26+
- FCM tokens can change and should be monitored for updates
- Background message handling has platform-specific limitations
- Test notifications thoroughly across different device states
- Consider user notification preferences and provide opt-out options
- Handle notification-related errors gracefully
- Follow platform-specific notification design guidelines