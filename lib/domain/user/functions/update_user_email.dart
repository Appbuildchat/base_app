// =============================================================================
// UPDATE USER EMAIL (사용자 이메일 업데이트 및 인증 처리)
// =============================================================================
//
// 이 파일은 Firebase의 Auth 및 Firestore를 모두 반영하여 사용자의 이메일을 변경하는
// 특수 처리 함수를 포함합니다. 이메일 형식 검증과 최근 로그인 여부 확인,
// 이메일 인증 링크 전송 등 민감한 절차를 포함합니다.
//
// 사용법:
// 1. 사용자가 이메일을 변경하려고 할 때 이 함수를 호출합니다.
// 2. 내부적으로 Firestore 필드를 업데이트하고,
//    Firebase Auth의 `verifyBeforeUpdateEmail`을 호출합니다.
// 3. 이메일은 사용자가 인증 링크를 클릭한 후 실제로 Auth에 반영됩니다.
//
// 주의사항:
// - 사용자는 최근 로그인 상태여야 하며,
// - 변경된 이메일은 중복되지 않아야 합니다.
// =============================================================================

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../../../../core/result.dart';
import '../../../../core/app_error_code.dart';
import '../../../../core/validators.dart';
import 'update_user_field.dart'; // updateUserField 함수 경로

// 이메일을 업데이트하고 인증 절차를 시작하는 함수
Future<Result<void>> updateUserEmail(String newEmail) async {
  final currentUser = FirebaseAuth.instance.currentUser;
  if (currentUser == null) {
    return Result.failure(
      AppErrorCode.authNotLoggedIn,
      message: "User not logged in.",
    );
  }

  // 이메일 형식 검증
  if (Validators.email(newEmail) == null) {
    return Result.failure(
      AppErrorCode.authInvalidEmailFormat,
      message: "Invalid email format.",
    );
  }

  final userId = currentUser.uid;

  try {
    // 1. Firestore에 이메일 필드 업데이트
    final fieldUpdateResult = await updateUserField<String>(
      userId,
      'email',
      newEmail.trim(),
    );
    if (!fieldUpdateResult.isSuccess) return fieldUpdateResult;

    // 2. Firebase Auth에 이메일 인증 요청
    debugPrint("Sending verification email to $newEmail");
    await currentUser.verifyBeforeUpdateEmail(newEmail.trim());
    debugPrint("Email verification sent to $newEmail");

    // 실제 Auth 이메일은 사용자가 링크를 클릭해야 반영됨
    return Result.success(null);
  } on FirebaseAuthException catch (e) {
    debugPrint("FirebaseAuth error updating email: ${e.code} - ${e.message}");
    if (e.code == 'email-already-in-use') {
      return Result.failure(
        AppErrorCode.unknownError,
        message: "This email might already be in use by another account.",
      );
    } else if (e.code == 'invalid-email') {
      return Result.failure(
        AppErrorCode.authInvalidEmailFormat,
        message: "The new email address is invalid.",
      );
    } else if (e.code == 'requires-recent-login') {
      return Result.failure(
        AppErrorCode.authOperationNotAllowed,
        message: "Please sign in again recently to change your email.",
      );
    }

    return Result.failure(
      AppErrorCode.authUnknownError,
      message: "Failed to update email (Auth Error): ${e.message}",
    );
  } on FirebaseException catch (e) {
    debugPrint("Firestore error updating email for $userId: ${e.message}");
    return Result.failure(
      AppErrorCode.unknownError,
      message: "Failed to update email data (Firestore Error): ${e.message}",
    );
  } catch (e) {
    debugPrint("Unknown error updating email for $userId: $e");
    return Result.failure(
      AppErrorCode.unknownError,
      message: "An unknown error occurred while updating the email.",
    );
  }
}
