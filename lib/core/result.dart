import 'app_error_code.dart';

/// Generic wrapper representing the outcome of an asynchronous or synchronous
/// operation.
///
/// Usage examples:
///
///   // 1. Returning from a repository/service
///   Future\<Result\<User\>\> getUser(String id) async {
///     try {
///       final user = await api.fetchUser(id);
///       return Result.success(user, statusCode: 200);
///     } catch (e) {
///       return Result.failure(AppErrorCode.backendUnknownError,
///           message: e.toString(), statusCode: 500);
///     }
///   }
///
///   // 2. Consuming the result
///   final result = await getUser('123');
///   if (result.isSuccess) {
///     print('User name: \\${result.data!.name}');
///   } else {
///     showErrorDialog(result.error!, subtitle: result.message);
///   }
///
/// Members:
///   • data       – payload when the operation is successful.
///   • error      – [AppErrorCode] when the operation fails.
///   • isSuccess  – quick flag to branch logic.
///   • message    – optional human-readable description.
///   • statusCode – optional numeric code (e.g., HTTP status).
class Result<T> {
  final T? data;
  final AppErrorCode? error;
  final bool isSuccess;
  final String? message; // Optional additional message
  final int? statusCode; // Optional status code (e.g., HTTP)

  Result.success(this.data, {this.message, this.statusCode})
    : isSuccess = true,
      error = null;

  Result.failure(this.error, {this.message, this.statusCode})
    : isSuccess = false,
      data = null;
}
