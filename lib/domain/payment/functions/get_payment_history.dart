import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/result.dart';
import '../../../core/app_error_code.dart';
import '../entities/payment_entity.dart';

class GetPaymentHistory {
  static Future<Result<List<PaymentEntity>>> getUserPayments({
    required String userId,
    int limit = 20,
    PaymentEntity? startAfter,
  }) async {
    try {
      final firestore = FirebaseFirestore.instance;

      Query query = firestore
          .collection('payments')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .limit(limit);

      if (startAfter != null) {
        query = query.startAfterDocument(
          await firestore
              .collection('payments')
              .doc(startAfter.paymentId)
              .get(),
        );
      }

      final snapshot = await query.get();

      final payments = snapshot.docs.map((doc) {
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

  static Future<Result<PaymentEntity?>> getPaymentById({
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
        message: e.message ?? 'Failed to fetch payment',
      );
    } catch (e) {
      return Result.failure(
        AppErrorCode.backendUnknownError,
        message: e.toString(),
      );
    }
  }

  static Future<Result<List<PaymentEntity>>> getPaymentsByStatus({
    required String userId,
    required String status,
    int limit = 20,
  }) async {
    try {
      final firestore = FirebaseFirestore.instance;

      final snapshot = await firestore
          .collection('payments')
          .where('userId', isEqualTo: userId)
          .where('status', isEqualTo: status)
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();

      final payments = snapshot.docs.map((doc) {
        final data = doc.data();
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
        message: e.message ?? 'Failed to fetch payments by status',
      );
    } catch (e) {
      return Result.failure(
        AppErrorCode.backendUnknownError,
        message: e.toString(),
      );
    }
  }
}
