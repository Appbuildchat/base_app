// =============================================================================
// GET SINGLE USER DETAILS (단일 사용자 정보 조회)
// =============================================================================
//
// 이 파일에는 한 명의 유저 ID를 받아서,
// Firestore에서 해당 유저의 정보를 불러오는 함수 fetchUserDetails 가 들어 있습니다.
// 유저 프로필을 조회할 때 사용할 수 있습니다.
//
// 새 프로젝트 적용법:
// 1. 사용자 ID (`String`) 를 함수에 전달하여 해당 사용자 정보를 가져옵니다.
// 2. Firestore에서 문서를 조회하며, 존재하지 않거나 오류가 발생하면 실패 처리됩니다.
// 3. 결과는 `Result<UserEntity>` 형태로 반환되며, 성공/실패를 분리하여 핸들링할 수 있습니다.
// =============================================================================

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../../../core/result.dart';
import '../../../core/app_error_code.dart';
import '../entities/user_entity.dart';

// Firestore에서 단일 사용자 정보를 조회하는 함수
//
// [userId] : 조회할 사용자의 ID
// 성공 시 `Result.success(UserEntity)` 를, 실패 시 `Result.failure(...)` 를 반환합니다.
Future<Result<UserEntity>> fetchUserDetails(String userId) async {
  // 1. 입력값 유효성 검사
  if (userId.isEmpty) {
    return Result.failure(
      AppErrorCode.unknownError,
      message: "User ID cannot be empty.",
    );
  }

  final usersCollection = FirebaseFirestore.instance.collection('users');

  try {
    // 2. Firestore 문서 조회
    final docSnapshot = await usersCollection.doc(userId).get();

    if (docSnapshot.exists && docSnapshot.data() != null) {
      // 3. 정상적으로 사용자 데이터를 파싱
      final userData = UserEntity.fromJson(docSnapshot.data()!);
      return Result.success(userData);
    } else {
      // 문서가 없거나 데이터가 null일 경우
      debugPrint("User document not found for ID: $userId");
      return Result.failure(
        AppErrorCode.backendResourceNotFound,
        message: "User profile not found.",
      );
    }
  } on FirebaseException catch (e) {
    // Firebase 관련 에러 처리
    debugPrint("Firebase error fetching user details for $userId: $e");
    return Result.failure(
      AppErrorCode.backendUnknownError,
      message: "Failed to fetch user details: ${e.message}",
    );
  } catch (e) {
    // 예기치 못한 에러 처리
    debugPrint("Unknown error fetching user details for $userId: $e");
    return Result.failure(
      AppErrorCode.unknownError,
      message: "An unknown error occurred while fetching user details.",
    );
  }
}
