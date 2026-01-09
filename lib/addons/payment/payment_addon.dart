/// Payment Addon
///
/// Stripe 결제 기능을 제공합니다.
///
/// ## 활성화
/// ```dart
/// // app_config.dart
/// static const bool enablePayment = true;
///
/// // main.dart
/// await AddonRegistry.initialize([
///   if (AppConfig.enablePayment) PaymentAddon(),
/// ]);
/// ```
///
/// ## 설정 필요
/// 1. Stripe publishable key 설정
/// 2. Firebase Functions에 secret key 설정
///    `firebase functions:config:set stripe.secret_key="sk_..."`
///
/// ## 기능
/// - Payment Intent 생성
/// - 결제 처리
/// - 결제 취소
/// - 결제 내역 조회
/// - 영수증 조회
library;

import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:go_router/go_router.dart';
import '../addon_registry.dart';

// 기존 payment 모듈 re-export
export '../../domain/payment/entities/payment_entity.dart';
export '../../domain/payment/entities/payment_intent_entity.dart';
export '../../domain/payment/entities/product_entity.dart';
export '../../domain/payment/functions/create_payment_intent.dart';
export '../../domain/payment/functions/process_payment.dart';
export '../../domain/payment/functions/cancel_payment.dart';
export '../../domain/payment/functions/fetch_payment_history.dart';
export '../../domain/payment/functions/verify_payment.dart';
export '../../domain/payment/functions/save_payment_record.dart';
export '../../domain/payment/models/payment_status.dart';

/// Payment Addon
///
/// Stripe 결제 시스템을 제공합니다.
class PaymentAddon extends Addon {
  /// Stripe Publishable Key
  final String publishableKey;

  /// 테스트 모드 여부
  final bool testMode;

  PaymentAddon({
    this.publishableKey = '', // app_config에서 설정
    this.testMode = true,
  });

  @override
  String get name => 'payment';

  @override
  String get description => 'Stripe payment integration';

  @override
  Future<void> initialize() async {
    if (publishableKey.isEmpty) {
      throw Exception(
        'PaymentAddon: publishableKey is required. '
        'Set it in PaymentAddon constructor or AppConfig.',
      );
    }

    Stripe.publishableKey = publishableKey;
    await Stripe.instance.applySettings();
  }

  @override
  Future<void> dispose() async {
    // Stripe cleanup if needed
  }

  @override
  List<RouteBase> get routes => [
    // 결제 관련 라우트는 각 앱에서 필요에 따라 추가
    // GoRoute(
    //   path: '/payment',
    //   builder: (_, __) => PaymentScreen(),
    // ),
    // GoRoute(
    //   path: '/payment/history',
    //   builder: (_, __) => PaymentHistoryScreen(),
    // ),
  ];
}

/// Payment Addon 헬퍼
///
/// ```dart
/// if (PaymentHelper.isEnabled) {
///   final result = await PaymentHelper.createPaymentIntent(...);
/// }
/// ```
class PaymentHelper {
  PaymentHelper._();

  /// Addon 활성화 여부
  static bool get isEnabled => AddonRegistry.has<PaymentAddon>();

  /// Addon 인스턴스
  static PaymentAddon? get instance => AddonRegistry.get<PaymentAddon>();

  /// 테스트 모드 여부
  static bool get isTestMode => instance?.testMode ?? true;
}
