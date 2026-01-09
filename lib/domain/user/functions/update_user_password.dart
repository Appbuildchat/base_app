// ============================================================================
// UPDATE USER PASSWORD
// ============================================================================
//
// 이 함수는 Firebase Auth를 사용하여 사용자의 비밀번호를 변경합니다.
// 보안을 위해 반드시 최근 로그인 상태에서만 비밀번호를 변경할 수 있으며,
// 이메일 기반 사용자만 지원합니다.
//
// 사용 예시:
// await updateUserPassword('currentPassword123', 'newPassword456');
//
// 반환값:
// - 성공 시: Result.success(null)
// - 실패 시: Result.failure(...) → 에러 코드와 메시지 포함
// ============================================================================
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../../../../core/result.dart';
import '../../../../core/app_error_code.dart';
import '../../../../core/validators.dart';

Future<Result<void>> updateUserPassword(
  String currentPassword,
  String newPassword,
) async {
  final currentUser = FirebaseAuth.instance.currentUser;

  // 1. 로그인 상태 확인
  if (currentUser == null) {
    return Result.failure(
      AppErrorCode.authNotLoggedIn,
      message: "User not logged in.",
    );
  }

  // 2. 이메일 기반 사용자 확인
  if (currentUser.email == null) {
    return Result.failure(
      AppErrorCode.unknownError,
      message: "User email is missing, cannot re-authenticate.",
    );
  }

  // 3. 새 비밀번호 유효성 검사 (예: 6자 이상)
  if (Validators.password(newPassword) != null) {
    return Result.failure(
      AppErrorCode.unknownError,
      message: "New password is too short (minimum 6 characters).",
    );
  }

  try {
    // 4. 사용자 재인증 (보안상 필요)
    debugPrint("Re-authenticating user...");
    final AuthCredential credential = EmailAuthProvider.credential(
      email: currentUser.email!,
      password: currentPassword,
    );
    await currentUser.reauthenticateWithCredential(credential);
    debugPrint("Re-authentication successful.");

    // 5. 비밀번호 업데이트
    debugPrint("Updating password...");
    await currentUser.updatePassword(newPassword);
    debugPrint("Password updated successfully.");

    return Result.success(null);
  } on FirebaseAuthException catch (e) {
    debugPrint(
      "FirebaseAuth error updating password: ${e.code} - ${e.message}",
    );

    switch (e.code) {
      case 'user-mismatch':
      case 'user-not-found':
        return Result.failure(
          AppErrorCode.backendResourceNotFound,
          message: "User not found or mismatch.",
        );
      case 'wrong-password':
        return Result.failure(
          AppErrorCode.authWrongPassword,
          message: "Incorrect current password.",
        );
      case 'requires-recent-login':
        return Result.failure(
          AppErrorCode.authOperationNotAllowed,
          message: "Please sign in again recently to change your password.",
        );
      case 'weak-password':
        return Result.failure(
          AppErrorCode.unknownError,
          message: "New password is too weak.",
        );
      default:
        return Result.failure(
          AppErrorCode.authUnknownError,
          message: "Failed to update password (Auth Error): ${e.message}",
        );
    }
  } catch (e) {
    debugPrint("Unknown error updating password: $e");
    return Result.failure(
      AppErrorCode.unknownError,
      message: "An unknown error occurred while updating the password.",
    );
  }
}
