// ============================================================================
// UPDATE USER USERNAME (사용자 이름 변경)
// ============================================================================
//
// 이 함수는 Firebase Firestore와 Firebase Auth의 사용자 정보를 모두 업데이트하여,
// 사용자의 표시 이름(username)을 변경합니다.
//
// 변경 내용:
// 1. Firestore 문서 내 username 필드 업데이트
// 2. Firebase Auth 프로필 내 displayName 필드 동기화
// 3. 관련된 모든 댓글의 사용자명 업데이트
//
// 사용 조건:
// - 현재 로그인된 사용자의 UID가 [userId]와 일치해야 함
// - [newUsername]은 공백이 아니고 유효해야 함 (Validators.name 사용)
//
// 사용 예시:
// await updateUserUsername("uid123", "새로운이름");
// ============================================================================
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../../../../core/result.dart';
import '../../../../core/app_error_code.dart';
import '../../../../core/validators.dart';

Future<Result<void>> updateUserUsername(String userId, String newName) async {
  // 1. 입력값 유효성 검사
  if (userId.isEmpty) {
    return Result.failure(
      AppErrorCode.unknownError,
      message: "User ID cannot be empty.",
    );
  }

  if (Validators.name(newName) != null) {
    return Result.failure(
      AppErrorCode.unknownError,
      message: "Invalid username (empty or too long).",
    );
  }

  final currentUser = FirebaseAuth.instance.currentUser;
  if (currentUser == null || currentUser.uid != userId) {
    return Result.failure(
      AppErrorCode.authNotLoggedIn,
      message: "User mismatch or not logged in.",
    );
  }

  final userDocRef = FirebaseFirestore.instance.collection('users').doc(userId);

  try {
    // 2. Firestore의 name 필드 업데이트
    debugPrint("Updating Firestore name for $userId to $newName");
    await userDocRef.update({
      'name': newName.trim(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    debugPrint("Firestore name updated.");

    // 3. Firebase Auth 프로필의 displayName 동기화
    debugPrint("Updating Firebase Auth display name for $userId");
    await currentUser.updateDisplayName(newName.trim());
    debugPrint("Firebase Auth display name updated.");

    return Result.success(null);
  } on FirebaseException catch (e) {
    debugPrint("Firebase error updating username for $userId: $e");
    if (e.code == 'not-found') {
      return Result.failure(
        AppErrorCode.backendResourceNotFound,
        message: "User profile not found in Firestore.",
      );
    }
    return Result.failure(
      AppErrorCode.backendUnknownError,
      message: "Failed to update username (Firestore Error): ${e.message}",
    );
  } catch (e) {
    debugPrint("Unknown error updating username for $userId: $e");
    return Result.failure(
      AppErrorCode.unknownError,
      message: "An unknown error occurred: $e",
    );
  }
}
