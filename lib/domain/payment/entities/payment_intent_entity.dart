import 'package:logger/logger.dart';

class PaymentIntentEntity {
  static final Logger _logger = Logger();

  final String paymentIntentId;
  final String clientSecret;
  final double amount;
  final String currency;
  final String status;
  final Map<String, dynamic>? metadata;
  final String? latestCharge;
  final double amountRefunded;
  final List<Map<String, dynamic>>? refundDetails;

  PaymentIntentEntity({
    required this.paymentIntentId,
    required this.clientSecret,
    required this.amount,
    this.currency = 'usd',
    required this.status,
    this.metadata,
    this.latestCharge,
    this.amountRefunded = 0.0,
    this.refundDetails,
  });

  factory PaymentIntentEntity.fromJson(Map<String, dynamic> json) {
    _logger.d('PaymentIntentEntity.fromJson called');
    _logger.d('Input json type: ${json.runtimeType}');
    _logger.d('Input json: $json');

    try {
      Map<String, dynamic>? metadata;
      if (json['metadata'] != null) {
        _logger.d('Processing metadata field');
        _logger.d('Metadata type: ${json['metadata'].runtimeType}');
        _logger.d('Metadata value: ${json['metadata']}');

        if (json['metadata'] is Map) {
          metadata = Map<String, dynamic>.from(json['metadata'] as Map);
          _logger.d('Successfully converted metadata to Map<String, dynamic>');
        } else {
          _logger.w('Metadata is not a Map, setting to null');
          metadata = null;
        }
      } else {
        _logger.d('Metadata field is null');
        metadata = null;
      }

      // Process refund details if available
      List<Map<String, dynamic>>? refundDetails;
      if (json['refund_details'] != null && json['refund_details'] is List) {
        _logger.d('Processing refund details');
        refundDetails = [];
        for (var refund in json['refund_details']) {
          if (refund is Map) {
            final refundMap = <String, dynamic>{};
            refund.forEach((key, value) {
              if (key is String) {
                refundMap[key] = value;
              }
            });
            refundDetails.add(refundMap);
          }
        }
        _logger.d('Processed ${refundDetails.length} refund details');
      }

      final entity = PaymentIntentEntity(
        paymentIntentId: json['paymentIntentId'] ?? json['id'] ?? '',
        clientSecret: json['clientSecret'] ?? json['client_secret'] ?? '',
        amount: ((json['amount'] ?? 0) / 100.0), // Stripe amounts are in cents
        currency: json['currency'] ?? 'usd',
        status: json['status'] ?? 'pending',
        metadata: metadata,
        latestCharge: json['latest_charge'],
        amountRefunded:
            ((json['amount_refunded'] ?? 0) / 100.0), // Convert from cents
        refundDetails: refundDetails,
      );

      _logger.i('PaymentIntentEntity created successfully');
      return entity;
    } catch (e) {
      _logger.e('Error in PaymentIntentEntity.fromJson: $e');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'paymentIntentId': paymentIntentId,
      'clientSecret': clientSecret,
      'amount': amount,
      'currency': currency,
      'status': status,
      'amountRefunded': amountRefunded,
      if (metadata != null) 'metadata': metadata,
      if (latestCharge != null) 'latest_charge': latestCharge,
      if (refundDetails != null) 'refund_details': refundDetails,
    };
  }

  int get amountInCents => (amount * 100).round();
  int get amountRefundedInCents => (amountRefunded * 100).round();

  String get formattedAmount {
    return '\$${amount.toStringAsFixed(2)}';
  }

  String get formattedAmountRefunded {
    return '\$${amountRefunded.toStringAsFixed(2)}';
  }

  bool get isSucceeded => status == 'succeeded';
  bool get isProcessing =>
      status == 'processing' || status == 'requires_action';
  bool get isRequiresPaymentMethod => status == 'requires_payment_method';
  bool get isFailed => status == 'canceled' || status == 'failed';
  bool get isRefunded => amountRefunded > 0;
  bool get isFullyRefunded => amountRefundedInCents >= amountInCents;
  bool get isPartiallyRefunded =>
      amountRefunded > 0 && amountRefundedInCents < amountInCents;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PaymentIntentEntity &&
          runtimeType == other.runtimeType &&
          paymentIntentId == other.paymentIntentId;

  @override
  int get hashCode => paymentIntentId.hashCode;
}
