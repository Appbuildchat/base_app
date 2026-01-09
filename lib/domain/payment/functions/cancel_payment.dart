import 'package:cloud_functions/cloud_functions.dart' as functions;
import 'package:logger/logger.dart';
import '../../../core/result.dart';
import '../../../core/app_error_code.dart';
import 'save_payment_record.dart';
import '../models/payment_status.dart';
import '../entities/payment_entity.dart';

class CancelPayment {
  static final Logger _logger = Logger();

  static Future<Result<void>> cancel({
    required String paymentIntentId,
    String? reason,
  }) async {
    try {
      final firebaseFunctions = functions.FirebaseFunctions.instance;
      final callable = firebaseFunctions.httpsCallable('cancelPaymentIntent');

      final response = await callable.call({
        'paymentIntentId': paymentIntentId,
        'cancellationReason': reason ?? 'requested_by_customer',
      });

      final data = Map<String, dynamic>.from(response.data as Map);

      if (data['success'] == true) {
        return Result.success(null);
      } else {
        return Result.failure(
          AppErrorCode.paymentProcessingError,
          message: data['message'] ?? 'Failed to cancel payment',
        );
      }
    } on functions.FirebaseFunctionsException catch (e) {
      AppErrorCode errorCode;
      String message = e.message ?? 'Failed to cancel payment';

      switch (e.code) {
        case 'unauthenticated':
          errorCode = AppErrorCode.authNotLoggedIn;
          break;
        case 'permission-denied':
          errorCode = AppErrorCode.unauthorizedAccess;
          break;
        case 'not-found':
          errorCode = AppErrorCode.backendResourceNotFound;
          break;
        default:
          errorCode = AppErrorCode.paymentProcessingError;
      }

      return Result.failure(errorCode, message: message);
    } catch (e) {
      return Result.failure(
        AppErrorCode.paymentProcessingError,
        message: e.toString(),
      );
    }
  }

  static Future<Result<Map<String, dynamic>>> refund({
    required String paymentIntentId,
    String? reason,
    double? amount,
  }) async {
    try {
      _logger.d('Starting refund for payment intent: $paymentIntentId');
      _logger.d('Refund reason: $reason');
      _logger.d('Refund amount: $amount');

      final firebaseFunctions = functions.FirebaseFunctions.instance;
      final callable = firebaseFunctions.httpsCallable('refundPayment');

      final requestData = <String, dynamic>{
        'paymentIntentId': paymentIntentId,
        'reason': 'requested_by_customer', // Always use valid Stripe reason
      };

      if (amount != null && amount > 0) {
        requestData['amount'] = (amount * 100).round(); // Convert to cents
        _logger.d('Refund amount in cents: ${requestData['amount']}');
      }

      _logger.d('Refund request data: $requestData');

      final response = await callable.call(requestData);

      _logger.d('Refund response: ${response.data}');
      _logger.d('Refund response type: ${response.data.runtimeType}');

      final data = <String, dynamic>{};
      if (response.data is Map) {
        data.addAll(Map<String, dynamic>.from(response.data as Map));
      } else {
        _logger.e('Refund response data is not a Map: ${response.data}');
        return Result.failure(
          AppErrorCode.paymentProcessingError,
          message: 'Invalid response format from server',
        );
      }

      _logger.d('Refund parsed data: $data');
      _logger.d('Refund success value: ${data['success']}');

      if (data['success'] == true) {
        _logger.d('Processing refund data from response');
        _logger.d('Raw refund data: ${data['refund']}');
        _logger.d('Raw refund data type: ${data['refund'].runtimeType}');

        // Safely convert refund data
        final refundData = <String, dynamic>{};
        if (data['refund'] is Map) {
          final rawRefund = data['refund'] as Map;
          rawRefund.forEach((key, value) {
            if (key is String) {
              refundData[key] = value;
            }
          });
          _logger.i('Successfully converted refund data: $refundData');
          return Result.success(refundData);
        } else {
          _logger.e('Refund data is not a Map: ${data['refund']}');
          return Result.failure(
            AppErrorCode.paymentProcessingError,
            message: 'Invalid refund data format in response',
          );
        }
      } else {
        final errorMessage = data['message'] ?? 'Failed to process refund';
        _logger.e('Refund failed: $errorMessage');
        return Result.failure(
          AppErrorCode.paymentProcessingError,
          message: errorMessage,
        );
      }
    } on functions.FirebaseFunctionsException catch (e) {
      _logger.e(
        'Refund Firebase Functions Exception - Code: ${e.code}, Message: ${e.message}',
      );

      AppErrorCode errorCode;
      String message = e.message ?? 'Failed to process refund';

      switch (e.code) {
        case 'unauthenticated':
          errorCode = AppErrorCode.authNotLoggedIn;
          break;
        case 'permission-denied':
          errorCode = AppErrorCode.unauthorizedAccess;
          break;
        case 'not-found':
          errorCode = AppErrorCode.backendResourceNotFound;
          break;
        default:
          errorCode = AppErrorCode.paymentProcessingError;
      }

      return Result.failure(errorCode, message: message);
    } catch (e) {
      _logger.e('General Exception in refund: $e');
      return Result.failure(
        AppErrorCode.paymentProcessingError,
        message: e.toString(),
      );
    }
  }

  static Future<Result<void>> cancelOrRefund({
    required PaymentEntity payment,
    String? reason,
  }) async {
    try {
      _logger.d('Starting cancelOrRefund for payment: ${payment.paymentId}');
      _logger.d('Payment status: ${payment.status.value}');
      _logger.d('Payment is completed: ${payment.isCompleted}');
      _logger.d('Stripe Payment Intent ID: ${payment.stripePaymentIntentId}');

      if (payment.stripePaymentIntentId == null) {
        _logger.e('No Stripe Payment Intent ID found');
        return Result.failure(
          AppErrorCode.paymentProcessingError,
          message: 'No Stripe Payment Intent ID found',
        );
      }

      Result<void> result;

      if (payment.isCompleted) {
        _logger.d('Payment is completed, processing refund');
        // For completed payments, use refund
        final refundResult = await refund(
          paymentIntentId: payment.stripePaymentIntentId!,
          reason: 'requested_by_customer', // Use exact Stripe reason
        );

        _logger.d('Refund result success: ${refundResult.isSuccess}');
        if (refundResult.isSuccess) {
          _logger.i('Refund successful, marking as cancelled');
          // Mark as cancelled in Firestore
          final markResult = await markAsCancelled(
            paymentId: payment.paymentId,
            reason: 'Refund processed',
          );
          _logger.d('Mark as cancelled result: ${markResult.isSuccess}');
          result = Result.success(null);
        } else {
          _logger.e('Refund failed: ${refundResult.message}');
          result = Result.failure(
            refundResult.error!,
            message: refundResult.message,
          );
        }
      } else {
        _logger.d('Payment is not completed, processing cancellation');
        // For pending/processing payments, use cancel
        result = await cancel(
          paymentIntentId: payment.stripePaymentIntentId!,
          reason: reason,
        );

        _logger.d('Cancel result success: ${result.isSuccess}');
        if (result.isSuccess) {
          _logger.i('Cancel successful, marking as cancelled');
          final markResult = await markAsCancelled(
            paymentId: payment.paymentId,
            reason: 'Payment cancelled',
          );
          _logger.d('Mark as cancelled result: ${markResult.isSuccess}');
        }
      }

      return result;
    } catch (e) {
      _logger.e('General Exception in cancelOrRefund: $e');
      return Result.failure(
        AppErrorCode.paymentProcessingError,
        message: e.toString(),
      );
    }
  }

  static Future<Result<void>> markAsCancelled({
    required String paymentId,
    String? reason,
  }) async {
    return await SavePaymentRecord.updatePaymentStatus(
      paymentId: paymentId,
      status: PaymentStatus.cancelled,
      failureReason: reason,
    );
  }
}
