import 'package:cloud_functions/cloud_functions.dart' as functions;
import 'package:logger/logger.dart';
import '../../../core/result.dart';
import '../../../core/app_error_code.dart';
import '../entities/payment_intent_entity.dart';
import '../entities/product_entity.dart';

class CreatePaymentIntent {
  static final Logger _logger = Logger();

  static Future<Result<PaymentIntentEntity>> create({
    required ProductEntity product,
    required String userId,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      _logger.d('Starting payment intent creation');
      _logger.d('Product ID: ${product.productId}');
      _logger.d('Amount in cents: ${product.priceInCents}');
      _logger.d('User ID: $userId');

      final firebaseFunctions = functions.FirebaseFunctions.instance;
      final callable = firebaseFunctions.httpsCallable('createPaymentIntent');

      final requestData = {
        'productId': product.productId,
        'amount': product.priceInCents,
        'currency': product.currency,
        'userId': userId,
        'metadata': {
          'productName': product.name,
          'userId': userId,
          ...?metadata,
        },
      };

      _logger.d('Request data: $requestData');
      _logger.d('Calling Firebase function...');

      final response = await callable.call(requestData);

      _logger.d('Raw response received');
      _logger.d('Response type: ${response.runtimeType}');
      _logger.d('Response data type: ${response.data.runtimeType}');
      _logger.d('Response data: ${response.data}');

      // More careful type handling
      if (response.data == null) {
        _logger.e('Response data is null');
        return Result.failure(
          AppErrorCode.paymentIntentCreationFailed,
          message: 'Received null response from payment service',
        );
      }

      Map<String, dynamic> data;
      try {
        data = Map<String, dynamic>.from(response.data as Map);
        _logger.d(
          'Successfully converted response data to Map<String, dynamic>',
        );
        _logger.d('Converted data: $data');
      } catch (e) {
        _logger.e('Failed to convert response data: $e');
        _logger.d('Attempting alternative conversion...');

        // Alternative conversion approach
        if (response.data is Map) {
          data = <String, dynamic>{};
          final rawMap = response.data as Map;
          for (final entry in rawMap.entries) {
            data[entry.key.toString()] = entry.value;
          }
          _logger.d('Alternative conversion successful: $data');
        } else {
          _logger.e('Response data is not a Map: ${response.data.runtimeType}');
          return Result.failure(
            AppErrorCode.paymentIntentCreationFailed,
            message: 'Invalid response format from payment service',
          );
        }
      }

      if (data['success'] == true) {
        _logger.i('Payment intent creation successful');
        _logger.d('PaymentIntent data: ${data['paymentIntent']}');
        _logger.d(
          'PaymentIntent data type: ${data['paymentIntent'].runtimeType}',
        );

        // Convert the nested paymentIntent object to Map<String, dynamic>
        Map<String, dynamic> paymentIntentData;
        if (data['paymentIntent'] is Map<String, dynamic>) {
          paymentIntentData = data['paymentIntent'];
        } else if (data['paymentIntent'] is Map) {
          paymentIntentData = Map<String, dynamic>.from(
            data['paymentIntent'] as Map,
          );
        } else {
          return Result.failure(
            AppErrorCode.paymentIntentCreationFailed,
            message: 'Invalid payment intent data format',
          );
        }

        _logger.d('PaymentIntent data converted: $paymentIntentData');
        final paymentIntent = PaymentIntentEntity.fromJson(paymentIntentData);
        _logger.i('PaymentIntentEntity created successfully');
        return Result.success(paymentIntent);
      } else {
        _logger.e('Payment intent creation failed');
        _logger.e('Error message: ${data['message']}');
        final errorCode = AppErrorCode.fromCode(
          data['error'] ?? 'PAYMENT_INTENT_CREATION_FAILED',
        );
        return Result.failure(
          errorCode,
          message: data['message'] ?? 'Failed to create payment intent',
        );
      }
    } on functions.FirebaseFunctionsException catch (e) {
      _logger.e('FirebaseFunctionsException caught');
      _logger.e('Exception code: ${e.code}');
      _logger.e('Exception message: ${e.message}');
      _logger.e('Exception details: ${e.details}');
      AppErrorCode errorCode;
      String message = e.message ?? 'Unknown error occurred';

      switch (e.code) {
        case 'unauthenticated':
          errorCode = AppErrorCode.authNotLoggedIn;
          break;
        case 'permission-denied':
          errorCode = AppErrorCode.unauthorizedAccess;
          break;
        case 'unavailable':
          errorCode = AppErrorCode.backendServiceUnavailable;
          break;
        default:
          errorCode = AppErrorCode.paymentIntentCreationFailed;
      }

      return Result.failure(errorCode, message: message);
    } catch (e) {
      return Result.failure(
        AppErrorCode.paymentIntentCreationFailed,
        message: e.toString(),
      );
    }
  }
}
