enum PaymentStatus {
  pending('pending', 'Payment Pending'),
  processing('processing', 'Processing Payment'),
  succeeded('succeeded', 'Payment Succeeded'),
  failed('failed', 'Payment Failed'),
  cancelled('cancelled', 'Payment Cancelled'),
  refunded('refunded', 'Payment Refunded');

  const PaymentStatus(this.value, this.displayName);

  final String value;
  final String displayName;

  static PaymentStatus fromString(String value) {
    return PaymentStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => PaymentStatus.pending,
    );
  }
}
