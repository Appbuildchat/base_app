/// Addons Module
///
/// 선택적 기능 모듈들을 통합 관리합니다.
///
/// ## 사용법
///
/// ### 1. main.dart에서 초기화
/// ```dart
/// import 'package:app/addons/addons.dart';
///
/// void main() async {
///   WidgetsFlutterBinding.ensureInitialized();
///   await DS.initialize();
///
///   // Addons 초기화
///   await AddonRegistry.initialize([
///     if (AppConfig.enableNotification) NotificationAddon(),
///     if (AppConfig.enablePayment) PaymentAddon(
///       publishableKey: 'pk_test_...',
///     ),
///     if (AppConfig.enableMedia) MediaAddon(),
///   ]);
///
///   runApp(MyApp());
/// }
/// ```
///
/// ### 2. 라우터에 라우트 추가
/// ```dart
/// final router = GoRouter(
///   routes: [
///     ...baseRoutes,
///     ...AddonRegistry.routes, // Addon 라우트 자동 추가
///   ],
/// );
/// ```
///
/// ### 3. 기능 사용
/// ```dart
/// // Notification
/// if (NotificationHelper.isEnabled) {
///   await NotificationCore.requestPermission();
/// }
///
/// // Payment
/// if (PaymentHelper.isEnabled) {
///   final intent = await createPaymentIntent(...);
/// }
///
/// // Media
/// if (MediaHelper.isEnabled) {
///   final image = await MediaPickerUtils.pickImage();
/// }
/// ```
library;

// Registry
export 'addon_registry.dart';

// Addons
export 'notification/notification_addon.dart';
export 'payment/payment_addon.dart';
export 'media/media_addon.dart';
