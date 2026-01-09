import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import '../../../core/result.dart';
import '../../../core/app_error_code.dart';
import '../entities/payment_intent_entity.dart';
import 'save_payment_record.dart';
import 'verify_payment.dart';

class ProcessPayment {
  static Future<Result<void>> withPaymentSheet({
    required PaymentIntentEntity paymentIntent,
    required String userId,
    required String productId,
  }) async {
    try {
      // Initialize payment sheet
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: paymentIntent.clientSecret,
          merchantDisplayName: 'Flutter Basic Project',
          style: ThemeMode.system,
        ),
      );

      // Present payment sheet
      await Stripe.instance.presentPaymentSheet();

      // If we reach here, payment was successful
      // Verify the payment intent to get the latest details including charge ID
      final verifyResult = await VerifyPayment.verifyPaymentIntent(
        paymentIntentId: paymentIntent.paymentIntentId,
      );

      String? chargeId;
      if (verifyResult.isSuccess) {
        final updatedPaymentIntent = verifyResult.data!;
        // Use the latest_charge field directly
        chargeId = updatedPaymentIntent.latestCharge;

        // Fallback to metadata if latestCharge is null
        if (chargeId == null &&
            updatedPaymentIntent.metadata != null &&
            updatedPaymentIntent.metadata!.containsKey('charge_id')) {
          chargeId = updatedPaymentIntent.metadata!['charge_id'];
        }
      }

      await SavePaymentRecord.save(
        paymentIntentId: paymentIntent.paymentIntentId,
        userId: userId,
        productId: productId,
        amount: paymentIntent.amount,
        currency: paymentIntent.currency,
        chargeId: chargeId,
      );

      return Result.success(null);
    } on StripeException catch (e) {
      AppErrorCode errorCode;
      String message = e.error.localizedMessage ?? 'Payment failed';

      switch (e.error.code) {
        case FailureCode.Canceled:
          errorCode = AppErrorCode.paymentCancelled;
          break;
        case FailureCode.Failed:
          errorCode = AppErrorCode.paymentDeclined;
          break;
        case FailureCode.Timeout:
          errorCode = AppErrorCode.paymentProcessingError;
          break;
        default:
          errorCode = AppErrorCode.paymentFailed;
      }

      return Result.failure(errorCode, message: message);
    } catch (e) {
      return Result.failure(AppErrorCode.paymentFailed, message: e.toString());
    }
  }

  static Future<Result<void>> confirmPayment({
    required String clientSecret,
    required String userId,
    required String productId,
    required double amount,
    required String currency,
  }) async {
    try {
      final paymentIntent = await Stripe.instance.confirmPayment(
        paymentIntentClientSecret: clientSecret,
        data: const PaymentMethodParams.card(
          paymentMethodData: PaymentMethodData(
            billingDetails: BillingDetails(),
          ),
        ),
      );

      if (paymentIntent.status == PaymentIntentsStatus.Succeeded) {
        // Get the latest payment intent details to extract charge ID
        final verifyResult = await VerifyPayment.verifyPaymentIntent(
          paymentIntentId: paymentIntent.id,
        );

        String? chargeId;
        if (verifyResult.isSuccess) {
          chargeId = verifyResult.data!.latestCharge;
        }

        await SavePaymentRecord.save(
          paymentIntentId: paymentIntent.id,
          userId: userId,
          productId: productId,
          amount: amount,
          currency: currency,
          chargeId: chargeId,
        );

        return Result.success(null);
      } else {
        return Result.failure(
          AppErrorCode.paymentProcessingError,
          message: 'Payment confirmation failed',
        );
      }
    } on StripeException catch (e) {
      AppErrorCode errorCode;
      String message =
          e.error.localizedMessage ?? 'Payment confirmation failed';

      switch (e.error.code) {
        case FailureCode.Canceled:
          errorCode = AppErrorCode.paymentCancelled;
          break;
        case FailureCode.Failed:
          errorCode = AppErrorCode.paymentDeclined;
          break;
        case FailureCode.Timeout:
          errorCode = AppErrorCode.paymentProcessingError;
          break;
        default:
          errorCode = AppErrorCode.paymentFailed;
      }

      return Result.failure(errorCode, message: message);
    } catch (e) {
      return Result.failure(AppErrorCode.paymentFailed, message: e.toString());
    }
  }
}
