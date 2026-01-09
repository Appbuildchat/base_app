import 'package:flutter/material.dart';

enum AppErrorCode {
  //region Data Handling Errors
  dataParseError(
    code: 'DATA_PARSE_ERROR',
    message: 'Error processing data. Please check the format.',
    icon: Icons.sync_problem,
    solutionButtonText: 'Retry',
  ),
  dataFormatError(
    code: 'DATA_FORMAT_ERROR',
    message: 'Invalid data format received.',
    icon: Icons.warning_amber_rounded,
    solutionButtonText: 'Retry',
  ),
  typeCastError(
    code: 'TYPE_CAST_ERROR',
    message: 'Data type mismatch encountered.',
    icon: Icons.code_off,
    solutionButtonText: 'Report Issue',
  ),
  invalidFormat(
    code: 'INVALID_FORMAT',
    message: 'Invalid format received.',
    icon: Icons.warning_amber_rounded,
    solutionButtonText: 'Retry',
  ),
  //endregion

  //region Authentication Errors
  authCredentialsNotFound(
    code: 'AUTH_CREDENTIALS_NOT_FOUND',
    message: 'No account found with the provided credentials.',
    icon: Icons.person_off_outlined,
    solutionButtonText: 'Check Credentials',
  ),
  authWrongPassword(
    code: 'AUTH_WRONG_PASSWORD',
    message: 'Incorrect password. Please try again.',
    icon: Icons.lock_outline,
    solutionButtonText: 'Retry',
  ),
  authUserDisabled(
    code: 'AUTH_USER_DISABLED',
    message: 'This account has been disabled.',
    icon: Icons.block,
    solutionButtonText: 'Contact Support',
  ),
  authTooManyRequests(
    code: 'AUTH_TOO_MANY_REQUESTS',
    message: 'Too many attempts. Please try again later.',
    icon: Icons.timer_off_outlined,
    solutionButtonText: 'Wait',
  ),
  authOperationNotAllowed(
    code: 'AUTH_OPERATION_NOT_ALLOWED',
    message: 'This sign-in method is currently disabled.',
    icon: Icons.not_interested_outlined,
    solutionButtonText: 'Contact Support',
  ),
  authInvalidEmailFormat(
    code: 'AUTH_INVALID_EMAIL_FORMAT',
    message: 'Invalid email format. Please check and correct.',
    icon: Icons.alternate_email,
    solutionButtonText: 'Check Email',
  ),
  authNotLoggedIn(
    code: 'AUTH_NOT_LOGGED_IN',
    message: 'You are not logged in. Please sign in.',
    icon: Icons.login,
    solutionButtonText: 'Sign In',
  ),
  authProcessAborted(
    code: 'AUTH_PROCESS_ABORTED',
    message: 'Authentication process cancelled or failed.',
    icon: Icons.cancel_outlined,
    solutionButtonText: 'Try Again',
  ),
  authUnknownError(
    code: 'AUTH_UNKNOWN_ERROR',
    message: 'An unknown authentication error occurred.',
    icon: Icons.help_outline,
    solutionButtonText: 'Contact Support',
  ),
  //endregion

  //region Backend Errors (Database/Server)
  backendPermissionDenied(
    code: 'BACKEND_PERMISSION_DENIED',
    message: 'Insufficient permissions to access the requested resource.',
    icon: Icons.lock_person_outlined,
    solutionButtonText: 'Contact Support',
  ),
  backendServiceUnavailable(
    code: 'BACKEND_SERVICE_UNAVAILABLE',
    message: 'Backend services are temporarily unavailable.',
    icon: Icons.cloud_off_outlined,
    solutionButtonText: 'Try Again Later',
  ),
  backendResourceNotFound(
    code: 'BACKEND_RESOURCE_NOT_FOUND',
    message: 'The requested data or resource could not be found.',
    icon: Icons.search_off_outlined,
    solutionButtonText: 'Retry',
  ),
  backendTimeout(
    code: 'BACKEND_TIMEOUT',
    message: 'The request to the backend timed out.',
    icon: Icons.network_check_outlined,
    solutionButtonText: 'Try Again',
  ),
  backendUnknownError(
    code: 'BACKEND_UNKNOWN_ERROR',
    message: 'An unexpected backend error occurred.',
    icon: Icons.dns_outlined,
    solutionButtonText: 'Try Again Later',
  ),
  //endregion

  //region Authorization Errors
  unauthorizedAccess(
    code: 'UNAUTHORIZED_ACCESS',
    message: 'You do not have permission for this action or page.',
    icon: Icons.gpp_bad_outlined,
    solutionButtonText: 'Go Back',
  ),
  //endregion

  //region General Errors
  networkError(
    code: 'NETWORK_ERROR',
    message: 'Network connection issue. Please check your connection.',
    icon: Icons.wifi_off_outlined,
    solutionButtonText: 'Check Connection',
  ),
  userCancelled(
    code: 'USER_CANCELLED',
    message: 'Operation was cancelled by user.',
    icon: Icons.cancel_outlined,
    solutionButtonText: 'Try Again',
  ),

  //region Validation & Input Errors
  validationError(
    code: 'VALIDATION_ERROR',
    message: 'Invalid input detected. Please verify entered information.',
    icon: Icons.rule,
    solutionButtonText: 'Correct',
  ),
  //endregion

  //region IO & Device Errors
  fileNotFound(
    code: 'FILE_NOT_FOUND',
    message: 'Requested file could not be located.',
    icon: Icons.insert_drive_file_outlined,
    solutionButtonText: 'Browse',
  ),
  storageOperationFailed(
    code: 'STORAGE_OPERATION_FAILED',
    message: 'Unable to complete storage operation.',
    icon: Icons.sd_storage,
    solutionButtonText: 'Retry',
  ),
  deviceError(
    code: 'DEVICE_ERROR',
    message: 'An unexpected device error occurred.',
    icon: Icons.phonelink_off,
    solutionButtonText: 'Retry',
  ),
  permissionDenied(
    code: 'PERMISSION_DENIED',
    message: 'Permission denied for this operation.',
    icon: Icons.security,
    solutionButtonText: 'Grant Permission',
  ),
  //endregion

  //region External Service Errors
  apiError(
    code: 'API_ERROR',
    message: 'Error communicating with an external service.',
    icon: Icons.cloud_sync,
    solutionButtonText: 'Retry',
  ),
  paymentFailed(
    code: 'PAYMENT_FAILED',
    message: 'The payment could not be processed.',
    icon: Icons.payment,
    solutionButtonText: 'Retry',
  ),
  paymentCancelled(
    code: 'PAYMENT_CANCELLED',
    message: 'Payment was cancelled by user.',
    icon: Icons.cancel_outlined,
    solutionButtonText: 'Try Again',
  ),
  paymentDeclined(
    code: 'PAYMENT_DECLINED',
    message: 'Payment was declined by your bank.',
    icon: Icons.credit_card_off,
    solutionButtonText: 'Check Card',
  ),
  paymentProcessingError(
    code: 'PAYMENT_PROCESSING_ERROR',
    message: 'Error occurred while processing payment.',
    icon: Icons.error_outline,
    solutionButtonText: 'Retry',
  ),
  invalidPaymentMethod(
    code: 'INVALID_PAYMENT_METHOD',
    message: 'The payment method is invalid or expired.',
    icon: Icons.credit_card_off,
    solutionButtonText: 'Update Card',
  ),
  paymentIntentCreationFailed(
    code: 'PAYMENT_INTENT_CREATION_FAILED',
    message: 'Failed to create payment intent.',
    icon: Icons.sync_problem,
    solutionButtonText: 'Try Again',
  ),
  insufficientFunds(
    code: 'INSUFFICIENT_FUNDS',
    message: 'Insufficient funds for this transaction.',
    icon: Icons.account_balance_wallet_outlined,
    solutionButtonText: 'Check Balance',
  ),
  //endregion

  unknownError(
    code: 'UNKNOWN_ERROR',
    message: 'An unexpected error occurred.',
    icon: Icons.error_outline,
    solutionButtonText: 'Retry',
  );
  //endregion

  final String code;
  final String message;
  final IconData icon;
  final String solutionButtonText;

  const AppErrorCode({
    required this.code,
    required this.message,
    required this.icon,
    required this.solutionButtonText,
  });

  /// Returns the AppErrorCode matching the given [code].
  /// Returns [unknownError] if no match is found.
  static AppErrorCode fromCode(String code) {
    final normalized = code.trim().toUpperCase();
    return AppErrorCode.values.firstWhere(
      (error) => error.code == normalized,
      orElse: () => unknownError,
    );
  }
}
