# Payment Addon

Stripe 결제 기능을 제공합니다.

## 활성화

```dart
// lib/app_config.dart
static const bool enablePayment = true;
```

```dart
// main.dart
import 'package:app/addons/addons.dart';

await AddonRegistry.initialize([
  if (AppConfig.enablePayment) PaymentAddon(
    publishableKey: 'pk_test_xxxxx', // Stripe Publishable Key
    testMode: true,
  ),
]);
```

## 필요한 설정

### 1. Stripe 대시보드
- https://dashboard.stripe.com 에서 API 키 확인
- Publishable Key: 앱에서 사용
- Secret Key: 서버(Firebase Functions)에서 사용

### 2. Firebase Functions
```bash
firebase functions:config:set stripe.secret_key="sk_test_xxxxx"
```

### 3. Android
`android/app/build.gradle`:
```gradle
android {
    defaultConfig {
        minSdkVersion 21
    }
}
```

### 4. iOS
iOS 13+ 필요

## 사용법

### 결제 생성
```dart
import 'package:app/addons/addons.dart';

if (PaymentHelper.isEnabled) {
  // 1. Payment Intent 생성
  final result = await createPaymentIntent(
    productId: 'prod_123',
    amount: 1000, // cents
    currency: 'usd',
    userId: 'user_123',
  );

  if (result.isSuccess) {
    // 2. 결제 처리
    final paymentResult = await processPayment(
      clientSecret: result.data!.clientSecret,
    );
  }
}
```

### 결제 내역 조회
```dart
final history = await fetchPaymentHistory(userId: 'user_123');
```

### 결제 취소
```dart
await cancelPayment(paymentIntentId: 'pi_xxxxx');
```

## 테스트 카드

| 카드 번호 | 결과 |
|----------|------|
| 4242 4242 4242 4242 | 성공 |
| 4000 0000 0000 0002 | 거절 |
| 4000 0000 0000 9995 | 잔액 부족 |

## 파일 구조

```
payment/
├── payment_addon.dart    # Addon 진입점
└── README.md             # 이 파일

# 원본 파일 (domain/payment/)
├── entities/
│   ├── payment_entity.dart
│   ├── payment_intent_entity.dart
│   └── product_entity.dart
├── functions/
│   ├── create_payment_intent.dart
│   ├── process_payment.dart
│   ├── cancel_payment.dart
│   ├── fetch_payment_history.dart
│   ├── verify_payment.dart
│   └── save_payment_record.dart
└── models/
    └── payment_status.dart
```
