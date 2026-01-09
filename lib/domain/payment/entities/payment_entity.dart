import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/payment_status.dart';

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

  PaymentEntity({
    required this.paymentId,
    required this.userId,
    required this.productId,
    required this.amount,
    this.currency = 'usd',
    this.status = PaymentStatus.pending,
    this.stripePaymentIntentId,
    this.stripeChargeId,
    this.stripePaymentMethodId,
    required this.createdAt,
    this.completedAt,
    this.failureReason,
    this.metadata,
  });

  factory PaymentEntity.fromJson(Map<String, dynamic> json) {
    return PaymentEntity(
      paymentId: json['paymentId'] ?? '',
      userId: json['userId'] ?? '',
      productId: json['productId'] ?? '',
      amount: (json['amount'] ?? 0.0).toDouble(),
      currency: json['currency'] ?? 'usd',
      status: PaymentStatus.fromString(json['status'] ?? 'pending'),
      stripePaymentIntentId: json['stripePaymentIntentId'],
      stripeChargeId: json['stripeChargeId'],
      stripePaymentMethodId: json['stripePaymentMethodId'],
      createdAt: (json['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      completedAt: (json['completedAt'] as Timestamp?)?.toDate(),
      failureReason: json['failureReason'],
      metadata: json['metadata'] != null
          ? Map<String, dynamic>.from(json['metadata'] as Map)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'paymentId': paymentId,
      'userId': userId,
      'productId': productId,
      'amount': amount,
      'currency': currency,
      'status': status.value,
      if (stripePaymentIntentId != null)
        'stripePaymentIntentId': stripePaymentIntentId,
      if (stripeChargeId != null) 'stripeChargeId': stripeChargeId,
      if (stripePaymentMethodId != null)
        'stripePaymentMethodId': stripePaymentMethodId,
      'createdAt': Timestamp.fromDate(createdAt),
      if (completedAt != null) 'completedAt': Timestamp.fromDate(completedAt!),
      if (failureReason != null) 'failureReason': failureReason,
      if (metadata != null) 'metadata': metadata,
    };
  }

  PaymentEntity copyWith({
    String? paymentId,
    String? userId,
    String? productId,
    double? amount,
    String? currency,
    PaymentStatus? status,
    String? stripePaymentIntentId,
    String? stripeChargeId,
    String? stripePaymentMethodId,
    DateTime? createdAt,
    DateTime? completedAt,
    String? failureReason,
    Map<String, dynamic>? metadata,
  }) {
    return PaymentEntity(
      paymentId: paymentId ?? this.paymentId,
      userId: userId ?? this.userId,
      productId: productId ?? this.productId,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      status: status ?? this.status,
      stripePaymentIntentId:
          stripePaymentIntentId ?? this.stripePaymentIntentId,
      stripeChargeId: stripeChargeId ?? this.stripeChargeId,
      stripePaymentMethodId:
          stripePaymentMethodId ?? this.stripePaymentMethodId,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
      failureReason: failureReason ?? this.failureReason,
      metadata: metadata ?? this.metadata,
    );
  }

  int get amountInCents => (amount * 100).round();

  String get formattedAmount {
    return '\$${amount.toStringAsFixed(2)}';
  }

  bool get isCompleted => status == PaymentStatus.succeeded;
  bool get isFailed => status == PaymentStatus.failed;
  bool get isCancelled => status == PaymentStatus.cancelled;
  bool get isPending => status == PaymentStatus.pending;
  bool get isProcessing => status == PaymentStatus.processing;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PaymentEntity &&
          runtimeType == other.runtimeType &&
          paymentId == other.paymentId;

  @override
  int get hashCode => paymentId.hashCode;
}
