# Payment Domain

The Payment domain module handles all payment-related functionality. It provides comprehensive payment processing features using Stripe integration, including payment creation, processing, verification, and history management.

## Folder Structure

```
lib/domain/payment/
├── entities/           # Data models
│   ├── payment_entity.dart           # Main payment data model
│   ├── payment_intent_entity.dart    # Stripe payment intent model
│   └── product_entity.dart           # Product/item data model
├── functions/          # Business logic functions
│   ├── create_payment_intent.dart    # Create Stripe payment intent
│   ├── process_payment.dart          # Process payment with Stripe
│   ├── verify_payment.dart           # Verify payment completion
│   ├── cancel_payment.dart           # Cancel pending payments
│   ├── save_payment_record.dart      # Save payment to database
│   ├── fetch_payment_history.dart    # Fetch user payment history
│   └── get_payment_history.dart      # Get payment history with filters
└── models/             # Supporting models
    └── payment_status.dart           # Payment status enumeration
```

## Key Features

### 1. Payment Processing
- **Create Payment Intent** (`functions/create_payment_intent.dart`): Initialize Stripe payment intent
- **Process Payment** (`functions/process_payment.dart`): Handle payment sheet and processing
- **Verify Payment** (`functions/verify_payment.dart`): Confirm payment completion
- **Cancel Payment** (`functions/cancel_payment.dart`): Cancel pending payments

### 2. Payment Management
- **Save Records** (`functions/save_payment_record.dart`): Store payment data in Firestore
- **Payment History** (`functions/fetch_payment_history.dart`): Retrieve user payment history
- **Filtered History** (`functions/get_payment_history.dart`): Get payments with status filters

### 3. Data Models
- **Payment Entity** (`entities/payment_entity.dart`): Complete payment record
- **Payment Intent** (`entities/payment_intent_entity.dart`): Stripe payment intent data
- **Product Entity** (`entities/product_entity.dart`): Product/service information
- **Payment Status** (`models/payment_status.dart`): Payment state enumeration

## Data Models

### Payment Entity
```dart
import '../../entities/payment_entity.dart';

class PaymentEntity {
  final String paymentId;
  final String userId;
  final String productId;
  final double amount;
  final String currency;
  final PaymentStatus status;
  final String? stripePaymentIntentId;
  final String? stripeChargeId;
  final String? stripePaymentMethodId;
  final DateTime createdAt;
  final DateTime? completedAt;
  final String? failureReason;
  final Map<String, dynamic>? metadata;
}
```

### Payment Intent Entity
```dart
import '../../entities/payment_intent_entity.dart';

class PaymentIntentEntity {
  final String id;
  final String clientSecret;
  final double amount;
  final String currency;
  final String status;
  final DateTime createdAt;
}
```

### Payment Status
```dart
import '../../models/payment_status.dart';

enum PaymentStatus {
  pending,      // Payment initialized
  processing,   // Payment being processed
  succeeded,    // Payment completed successfully
  failed,       // Payment failed
  cancelled,    // Payment cancelled by user
  refunded      // Payment refunded
}
```

## Usage

### Create Payment Intent
```dart
import '../../domain/payment/functions/create_payment_intent.dart';

final result = await CreatePaymentIntent.create(
  amount: 2999, // Amount in cents
  currency: 'usd',
  userId: currentUser.uid,
  productId: 'premium_subscription'
);

if (result.isSuccess) {
  final paymentIntent = result.data!;
  // Use payment intent for processing
}
```

### Process Payment
```dart
import '../../domain/payment/functions/process_payment.dart';

final result = await ProcessPayment.withPaymentSheet(
  paymentIntent: paymentIntentEntity,
  userId: currentUser.uid,
  productId: 'premium_subscription'
);

if (result.isSuccess) {
  // Payment processed successfully
} else {
  // Handle payment failure
  print('Payment failed: ${result.errorMessage}');
}
```

### Verify Payment
```dart
import '../../domain/payment/functions/verify_payment.dart';

final result = await VerifyPayment.byIntentId(
  paymentIntentId: 'pi_1234567890'
);

if (result.isSuccess) {
  final isVerified = result.data!;
  if (isVerified) {
    // Payment verified
  }
}
```

### Cancel Payment
```dart
import '../../domain/payment/functions/cancel_payment.dart';

final result = await CancelPayment.byIntentId(
  paymentIntentId: 'pi_1234567890',
  userId: currentUser.uid
);

if (result.isSuccess) {
  // Payment cancelled successfully
}
```

### Save Payment Record
```dart
import '../../domain/payment/functions/save_payment_record.dart';

final result = await SavePaymentRecord.save(
  paymentEntity: paymentEntity
);

if (result.isSuccess) {
  // Payment record saved to database
}
```

### Fetch Payment History
```dart
import '../../domain/payment/functions/fetch_payment_history.dart';

final result = await FetchPaymentHistory.forUser(
  userId: currentUser.uid,
  limit: 20
);

if (result.isSuccess) {
  final payments = result.data!;
  // Display payment history
}
```

### Get Filtered Payment History
```dart
import '../../domain/payment/functions/get_payment_history.dart';

final result = await GetPaymentHistory.withFilters(
  userId: currentUser.uid,
  status: PaymentStatus.succeeded,
  startDate: DateTime.now().subtract(Duration(days: 30)),
  endDate: DateTime.now()
);

if (result.isSuccess) {
  final filteredPayments = result.data!;
  // Display filtered payment history
}
```

## Payment Flow

### Standard Payment Process
1. **Create Payment Intent**: Initialize payment with Stripe
2. **Process Payment**: Present payment sheet to user
3. **Verify Payment**: Confirm payment completion
4. **Save Record**: Store payment data in Firestore
5. **Handle Result**: Update UI and user state

### Payment Cancellation Flow
1. **Cancel Intent**: Cancel Stripe payment intent
2. **Update Status**: Mark payment as cancelled
3. **Clean Up**: Remove pending payment records

## Stripe Integration

The payment system uses Flutter Stripe for payment processing:
- **Payment Sheets**: Native payment UI
- **Payment Intents**: Server-side payment processing
- **Webhooks**: Real-time payment status updates
- **Security**: PCI DSS compliant payment handling

## Payment Status Management

Payment statuses track the entire payment lifecycle:
- **Pending**: Payment intent created
- **Processing**: User is completing payment
- **Succeeded**: Payment completed successfully
- **Failed**: Payment failed due to various reasons
- **Cancelled**: User cancelled the payment
- **Refunded**: Payment was refunded

## Error Handling

All payment functions implement comprehensive error handling:
- Stripe API errors
- Network connectivity issues
- User cancellation
- Invalid payment methods
- Insufficient funds
- Authentication failures

## Security Considerations

- Payment processing is handled securely through Stripe
- Sensitive payment data never stored locally
- All transactions are encrypted in transit
- Payment records include audit trails
- User authentication required for all payment operations

## Important Notes

- All functions use the Result pattern for error handling
- Payment amounts are handled in cents to avoid floating-point precision issues
- Stripe webhooks should be configured for production environments
- Payment intents have expiration times and should be handled accordingly
- All payment operations require user authentication
- Payment history is stored in Firestore for easy retrieval and analytics