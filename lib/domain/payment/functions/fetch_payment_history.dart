import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/result.dart';
import '../../../core/app_error_code.dart';
import '../entities/payment_entity.dart';
import '../models/payment_status.dart';

class FetchPaymentHistory {
  static Future<Result<List<PaymentEntity>>> forUser({
    required String userId,
    int limit = 50,
    PaymentStatus? statusFilter,
  }) async {
    try {
      final firestore = FirebaseFirestore.instance;
      Query query = firestore
          .collection('payments')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true);

      if (statusFilter != null) {
        query = query.where('status', isEqualTo: statusFilter.value);
      }

      query = query.limit(limit);

      final querySnapshot = await query.get();

      final payments = querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return PaymentEntity.fromJson(data);
      }).toList();

      return Result.success(payments);
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
        message: e.message ?? 'Failed to fetch payment history',
      );
    } catch (e) {
      return Result.failure(
        AppErrorCode.backendUnknownError,
        message: e.toString(),
      );
    }
  }

  static Future<Result<PaymentEntity?>> getByPaymentId({
    required String paymentId,
  }) async {
    try {
      final firestore = FirebaseFirestore.instance;
      final doc = await firestore.collection('payments').doc(paymentId).get();

      if (!doc.exists) {
        return Result.success(null);
      }

      final payment = PaymentEntity.fromJson(doc.data()!);
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
        message: e.message ?? 'Failed to fetch payment details',
      );
    } catch (e) {
      return Result.failure(
        AppErrorCode.backendUnknownError,
        message: e.toString(),
      );
    }
  }

  static Future<Result<PaymentEntity?>> getByPaymentIntentId({
    required String paymentIntentId,
  }) async {
    try {
      final firestore = FirebaseFirestore.instance;
      final querySnapshot = await firestore
          .collection('payments')
          .where('stripePaymentIntentId', isEqualTo: paymentIntentId)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        return Result.success(null);
      }

      final payment = PaymentEntity.fromJson(querySnapshot.docs.first.data());
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
        message: e.message ?? 'Failed to fetch payment by intent ID',
      );
    } catch (e) {
      return Result.failure(
        AppErrorCode.backendUnknownError,
        message: e.toString(),
      );
    }
  }
}
