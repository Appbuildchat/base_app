import 'package:cloud_functions/cloud_functions.dart' as functions;
import 'package:logger/logger.dart';
import '../../../core/result.dart';
import '../../../core/app_error_code.dart';
import '../entities/payment_intent_entity.dart';
import 'save_payment_record.dart';
import '../models/payment_status.dart';

class VerifyPayment {
  static final Logger _logger = Logger();

  static Future<Result<PaymentIntentEntity>> verifyPaymentIntent({
    required String paymentIntentId,
  }) async {
    try {
      _logger.d('Starting verifyPaymentIntent with ID: $paymentIntentId');

      final firebaseFunctions = functions.FirebaseFunctions.instance;
      final callable = firebaseFunctions.httpsCallable('verifyPaymentIntent');

      final response = await callable.call({
        'paymentIntentId': paymentIntentId,
      });

      _logger.d('Raw response: ${response.data}');
      _logger.d('Response type: ${response.data.runtimeType}');

      final data = <String, dynamic>{};
      if (response.data is Map) {
        data.addAll(Map<String, dynamic>.from(response.data as Map));
      } else {
        _logger.e('Response data is not a Map: ${response.data}');
        return Result.failure(
          AppErrorCode.paymentProcessingError,
          message: 'Invalid response format from server',
        );
      }

      _logger.d('Parsed data: $data');
      _logger.d('Success value: ${data['success']}');

      if (data['success'] == true) {
        _logger.d('Payment intent data: ${data['paymentIntent']}');
        _logger.d(
          'Payment intent data type: ${data['paymentIntent'].runtimeType}',
        );

        // Safely cast the payment intent data
        final paymentIntentData = <String, dynamic>{};
        if (data['paymentIntent'] is Map) {
          final rawData = data['paymentIntent'] as Map;
          rawData.forEach((key, value) {
            if (key is String) {
              paymentIntentData[key] = value;
            }
          });
        }

        _logger.d('Converted payment intent data: $paymentIntentData');

        final paymentIntent = PaymentIntentEntity.fromJson(paymentIntentData);
        _logger.i('PaymentIntentEntity created successfully');
        return Result.success(paymentIntent);
      } else {
        final errorMessage = data['message'] ?? 'Failed to verify payment';
        _logger.e('Verification failed: $errorMessage');
        return Result.failure(
          AppErrorCode.paymentProcessingError,
          message: errorMessage,
        );
      }
    } on functions.FirebaseFunctionsException catch (e) {
      _logger.e(
        'Firebase Functions Exception - Code: ${e.code}, Message: ${e.message}',
      );

      AppErrorCode errorCode;
      String message = e.message ?? 'Failed to verify payment';

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
      _logger.e('General Exception in verifyPaymentIntent: $e');
      return Result.failure(
        AppErrorCode.paymentProcessingError,
        message: e.toString(),
      );
    }
  }

  static Future<Result<bool>> verifyAndUpdatePayment({
    required String paymentIntentId,
    required String paymentId,
  }) async {
    try {
      final verifyResult = await verifyPaymentIntent(
        paymentIntentId: paymentIntentId,
      );

      if (!verifyResult.isSuccess) {
        return Result.failure(
          verifyResult.error!,
          message: verifyResult.message,
        );
      }

      final paymentIntent = verifyResult.data!;
      PaymentStatus status;

      _logger.d('Determining payment status from verification');
      _logger.d('Payment Intent status: ${paymentIntent.status}');
      _logger.d('Amount refunded: ${paymentIntent.amountRefunded}');
      _logger.d('Is refunded: ${paymentIntent.isRefunded}');
      _logger.d('Is fully refunded: ${paymentIntent.isFullyRefunded}');
      _logger.d('Is succeeded: ${paymentIntent.isSucceeded}');

      // Priority order: refunded -> succeeded -> failed -> processing -> pending
      if (paymentIntent.isRefunded) {
        status = PaymentStatus.refunded;
        _logger.d('Setting status to refunded');
      } else if (paymentIntent.isSucceeded) {
        status = PaymentStatus.succeeded;
        _logger.d('Setting status to succeeded');
      } else if (paymentIntent.isFailed) {
        status = PaymentStatus.failed;
        _logger.d('Setting status to failed');
      } else if (paymentIntent.isProcessing) {
        status = PaymentStatus.processing;
        _logger.d('Setting status to processing');
      } else {
        status = PaymentStatus.pending;
        _logger.d('Setting status to pending');
      }

      final updateResult = await SavePaymentRecord.updatePaymentStatus(
        paymentId: paymentId,
        status: status,
      );

      if (!updateResult.isSuccess) {
        return Result.failure(
          updateResult.error!,
          message: updateResult.message,
        );
      }

      return Result.success(paymentIntent.isSucceeded);
    } catch (e) {
      return Result.failure(
        AppErrorCode.paymentProcessingError,
        message: e.toString(),
      );
    }
  }

  static Future<Result<String>> getReceiptUrl({
    required String chargeId,
  }) async {
    try {
      final firebaseFunctions = functions.FirebaseFunctions.instance;
      final callable = firebaseFunctions.httpsCallable('getReceiptUrl');

      final response = await callable.call({'chargeId': chargeId});

      final data = Map<String, dynamic>.from(response.data as Map);

      if (data['success'] == true) {
        return Result.success(data['receiptUrl'] as String);
      } else {
        return Result.failure(
          AppErrorCode.backendResourceNotFound,
          message: data['message'] ?? 'Receipt not found',
        );
      }
    } on functions.FirebaseFunctionsException catch (e) {
      AppErrorCode errorCode;

      switch (e.code) {
        case 'not-found':
          errorCode = AppErrorCode.backendResourceNotFound;
          break;
        case 'permission-denied':
          errorCode = AppErrorCode.unauthorizedAccess;
          break;
        default:
          errorCode = AppErrorCode.backendUnknownError;
      }

      return Result.failure(errorCode, message: e.message);
    } catch (e) {
      return Result.failure(
        AppErrorCode.backendUnknownError,
        message: e.toString(),
      );
    }
  }

  static Future<Result<String>> getReceiptUrlFromPaymentIntent({
    required String paymentIntentId,
  }) async {
    try {
      _logger.d(
        'Starting getReceiptUrlFromPaymentIntent with ID: $paymentIntentId',
      );

      final firebaseFunctions = functions.FirebaseFunctions.instance;
      final callable = firebaseFunctions.httpsCallable(
        'getReceiptFromPaymentIntent',
      );

      final response = await callable.call({
        'paymentIntentId': paymentIntentId,
      });

      _logger.d('Receipt response: ${response.data}');
      _logger.d('Receipt response type: ${response.data.runtimeType}');

      final data = <String, dynamic>{};
      if (response.data is Map) {
        data.addAll(Map<String, dynamic>.from(response.data as Map));
      } else {
        _logger.e('Receipt response data is not a Map: ${response.data}');
        return Result.failure(
          AppErrorCode.backendResourceNotFound,
          message: 'Invalid response format from server',
        );
      }

      _logger.d('Receipt parsed data: $data');
      _logger.d('Receipt success value: ${data['success']}');

      if (data['success'] == true) {
        final receiptUrl = data['receiptUrl'] as String?;
        _logger.d('Receipt URL: $receiptUrl');
        if (receiptUrl != null) {
          return Result.success(receiptUrl);
        } else {
          _logger.e('Receipt URL is null in response');
          return Result.failure(
            AppErrorCode.backendResourceNotFound,
            message: 'Receipt URL not found in response',
          );
        }
      } else {
        final errorMessage = data['message'] ?? 'Receipt not found';
        _logger.e('Receipt fetch failed: $errorMessage');
        return Result.failure(
          AppErrorCode.backendResourceNotFound,
          message: errorMessage,
        );
      }
    } on functions.FirebaseFunctionsException catch (e) {
      _logger.e(
        'Receipt Firebase Functions Exception - Code: ${e.code}, Message: ${e.message}',
      );

      AppErrorCode errorCode;

      switch (e.code) {
        case 'not-found':
          errorCode = AppErrorCode.backendResourceNotFound;
          break;
        case 'permission-denied':
          errorCode = AppErrorCode.unauthorizedAccess;
          break;
        case 'unauthenticated':
          errorCode = AppErrorCode.authNotLoggedIn;
          break;
        default:
          errorCode = AppErrorCode.backendUnknownError;
      }

      return Result.failure(errorCode, message: e.message);
    } catch (e) {
      _logger.e('General Exception in getReceiptUrlFromPaymentIntent: $e');
      return Result.failure(
        AppErrorCode.backendUnknownError,
        message: e.toString(),
      );
    }
  }
}
