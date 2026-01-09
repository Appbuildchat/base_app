import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/result.dart';
import '../../../core/app_error_code.dart';
import '../entities/payment_entity.dart';
import '../models/payment_status.dart';

class SavePaymentRecord {
  static Future<Result<PaymentEntity>> save({
    required String paymentIntentId,
    required String userId,
    required String productId,
    required double amount,
    required String currency,
    String? paymentMethodId,
    String? chargeId,
    PaymentStatus status = PaymentStatus.succeeded,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final firestore = FirebaseFirestore.instance;
      final paymentId = firestore.collection('payments').doc().id;

      final payment = PaymentEntity(
        paymentId: paymentId,
        userId: userId,
        productId: productId,
        amount: amount,
        currency: currency,
        status: status,
        stripePaymentIntentId: paymentIntentId,
        stripeChargeId: chargeId,
        stripePaymentMethodId: paymentMethodId,
        createdAt: DateTime.now(),
        completedAt: status == PaymentStatus.succeeded ? DateTime.now() : null,
        metadata: metadata,
      );

      await firestore
          .collection('payments')
          .doc(paymentId)
          .set(payment.toJson());

      return Result.success(payment);
    } on FirebaseException catch (e) {
      AppErrorCode errorCode;

      switch (e.code) {
        case 'permission-denied':
          errorCode = AppErrorCode.backendPermissionDenied;
          break;
        case 'unavailable':
          errorCode = AppErrorCode.backendServiceUnavailable;
          break;
        default:
          errorCode = AppErrorCode.backendUnknownError;
      }

      return Result.failure(
        errorCode,
        message: e.message ?? 'Failed to save payment record',
      );
    } catch (e) {
      return Result.failure(
        AppErrorCode.backendUnknownError,
        message: e.toString(),
      );
    }
  }

  static Future<Result<void>> updatePaymentStatus({
    required String paymentId,
    required PaymentStatus status,
    String? failureReason,
  }) async {
    try {
      final firestore = FirebaseFirestore.instance;

      final updateData = <String, dynamic>{
        'status': status.value,
        'updatedAt': Timestamp.now(),
      };

      if (status == PaymentStatus.succeeded) {
        updateData['completedAt'] = Timestamp.now();
      }

      if (failureReason != null) {
        updateData['failureReason'] = failureReason;
      }

      await firestore.collection('payments').doc(paymentId).update(updateData);

      return Result.success(null);
    } on FirebaseException catch (e) {
      AppErrorCode errorCode;

      switch (e.code) {
        case 'not-found':
          errorCode = AppErrorCode.backendResourceNotFound;
          break;
        case 'permission-denied':
          errorCode = AppErrorCode.backendPermissionDenied;
          break;
        default:
          errorCode = AppErrorCode.backendUnknownError;
      }

      return Result.failure(
        errorCode,
        message: e.message ?? 'Failed to update payment status',
      );
    } catch (e) {
      return Result.failure(
        AppErrorCode.backendUnknownError,
        message: e.toString(),
      );
    }
  }
}
