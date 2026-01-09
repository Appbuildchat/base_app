// =============================================================================
// GET USERS FROM IDS (유저 ID 목록으로 사용자 정보 리스트 가져오기)
// =============================================================================
//
// 이 파일은 유저 ID 목록을 받아서,
// Firestore의 'users' 컬렉션에서 해당 유저들의 정보를 한꺼번에 불러오는 함수입니다.
// 여러 명의 유저 정보를 한 번에 가져올 때 사용할 수 있습니다.
//
// 사용법:
// 1. userIds에 가져올 사용자 ID 목록을 넘기면 됩니다.
//    예: fetchUsersFromIds(['uid1', 'uid2']);
//
// 사용 예시:
// - 팔로워 또는 팔로잉 유저 목록 표시 시
// - 여러 게시글의 작성자 정보 일괄 조회 시
// - 차단한 유저들의 프로필 정보 표시 시 등
// =============================================================================

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../../../core/result.dart';
import '../../../core/app_error_code.dart';
import '../entities/user_entity.dart';

// 주어진 유저 ID 목록에 해당하는 사용자 정보 리스트를 반환
Future<Result<List<UserEntity>>> fetchUsersFromIds(List<String> userIds) async {
  if (userIds.isEmpty) return Result.success([]);

  try {
    final usersCollection = FirebaseFirestore.instance.collection('users');

    // Firestore 'in' 쿼리 제한 고려 (30개 제한)
    const chunkSize = 30;
    List<UserEntity> result = [];

    for (int i = 0; i < userIds.length; i += chunkSize) {
      final chunk = userIds.sublist(
        i,
        (i + chunkSize > userIds.length) ? userIds.length : i + chunkSize,
      );

      final querySnapshot = await usersCollection
          .where(FieldPath.documentId, whereIn: chunk)
          .get();

      for (var doc in querySnapshot.docs) {
        try {
          result.add(UserEntity.fromJson(doc.data()));
        } catch (e) {
          debugPrint('Error parsing user ${doc.id}: $e');
        }
      }
    }

    return Result.success(result);
  } on FirebaseException catch (e) {
    return Result.failure(
      AppErrorCode.backendUnknownError,
      message: e.message ?? 'Firebase error',
    );
  } catch (e) {
    return Result.failure(
      AppErrorCode.unknownError,
      message: 'An unknown error occurred',
    );
  }
}
