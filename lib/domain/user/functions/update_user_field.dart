// =============================================================================
// UPDATE USER FIELD (사용자 문서에서 특정 필드 업데이트)
// =============================================================================
//
// 이 파일은 Firebase Firestore의 'users' 컬렉션에서
// 특정 사용자 문서의 특정 필드를 업데이트하는 공통 함수입니다.
//
// 이 함수를 사용하면 bio, username, role 등 단일 필드를 유연하게 수정할 수 있습니다.
//
// 사용 예시:
// 1. bio 필드 업데이트:
//    await updateUserField('uid123', 'bio', '새로운 소개글');
// 2. role 필드 업데이트:
//    await updateUserField('uid123', 'role', 'role2');
// =============================================================================
//
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../../../../core/result.dart';
import '../../../../core/app_error_code.dart';

Future<Result<void>> updateUserField<T>(
  String userId,
  String fieldName,
  T newValue,
) async {
  // userId가 비어있는지 확인
  if (userId.isEmpty) {
    return Result.failure(
      AppErrorCode.unknownError,
      message: "User ID cannot be empty.",
    );
  }

  // Firestore에서 해당 사용자의 문서 참조 생성
  final userDocRef = FirebaseFirestore.instance.collection('users').doc(userId);

  try {
    // Firestore 문서의 지정된 필드를 업데이트
    await userDocRef.update({
      fieldName: newValue,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    debugPrint("Field '$fieldName' updated for user $userId.");
    return Result.success(null); // 성공 반환
  } on FirebaseException catch (e) {
    // Firestore 관련 오류 처리
    debugPrint("Firebase error updating $fieldName for $userId: $e");

    // 문서가 존재하지 않는 경우
    if (e.code == 'not-found') {
      return Result.failure(
        AppErrorCode.backendResourceNotFound,
        message: "User profile not found.",
      );
    }

    // 그 외 Firestore 오류
    return Result.failure(
      AppErrorCode.backendUnknownError,
      message: "Failed to update $fieldName: ${e.message}",
    );
  } catch (e) {
    // 알 수 없는 예외 처리
    debugPrint("Unknown error updating $fieldName for $userId: $e");
    return Result.failure(
      AppErrorCode.unknownError,
      message: "An unknown error occurred while updating the field.",
    );
  }
}
