// =============================================================================
// CHANGE PASSWORD FUNCTION (비밀번호 변경 함수)
// =============================================================================
//
// 이 파일은 사용자의 비밀번호 변경 기능을 제공합니다.
//
// 주요 기능:
// 1. 현재 비밀번호로 재인증 수행
// 2. 새로운 비밀번호로 업데이트
// 3. Firebase Auth Exception 처리
//
// 함수 목록:
// - changePassword(): 비밀번호 변경하기
// =============================================================================

import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/result.dart';
import '../../../core/app_error_code.dart';
import '../../../core/validators.dart';

// 사용자의 비밀번호를 변경합니다.
//
// [currentPassword]: 현재 비밀번호
// [newPassword]: 새로운 비밀번호
// [confirmPassword]: 새로운 비밀번호 확인
Future<Result<void>> changePassword({
  required String currentPassword,
  required String newPassword,
  required String confirmPassword,
}) async {
  try {
    // 새 비밀번호 일치 여부 확인
    if (newPassword != confirmPassword) {
      return Result.failure(
        AppErrorCode.invalidFormat,
        message: 'New passwords do not match',
      );
    }

    // 새 비밀번호 유효성 검사
    final passwordError = Validators.password(newPassword);
    if (passwordError != null) {
      return Result.failure(AppErrorCode.invalidFormat, message: passwordError);
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return Result.failure(
        AppErrorCode.authNotLoggedIn,
        message: 'You are not authenticated. Please log in again.',
      );
    }

    // 현재 비밀번호로 재인증
    final credential = EmailAuthProvider.credential(
      email: user.email!,
      password: currentPassword,
    );

    await user.reauthenticateWithCredential(credential);

    // 새 비밀번호로 업데이트
    await user.updatePassword(newPassword);

    return Result.success(null);
  } on FirebaseAuthException catch (e) {
    final message = switch (e.code) {
      'wrong-password' => 'Incorrect current password.',
      'weak-password' => 'The new password is too weak.',
      'requires-recent-login' => 'Please log in again to change your password.',
      _ => 'Failed to change password: ${e.message}',
    };

    return Result.failure(AppErrorCode.authUnknownError, message: message);
  } catch (e) {
    return Result.failure(
      AppErrorCode.unknownError,
      message: 'An unexpected error occurred: $e',
    );
  }
}
