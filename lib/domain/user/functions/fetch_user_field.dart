// =============================================================================
// GET USER FIELD (사용자 문서에서 특정 필드 추출)
// =============================================================================
//
// 이 파일은 Firebase Firestore의 'users' 컬렉션에서
// 특정 사용자의 문서 내 특정 필드 값만 안전하게 추출하기 위한 공통 함수입니다.
//
// 이 함수를 사용하면 'following', 'blockedUsers', 'bio' 등 다양한 필드에 대해
// 반복적인 로직 없이 일관된 방식으로 접근할 수 있습니다.
//
// 사용 예시:
//
// 1. 사용자 팔로잉 목록 가져오기:
//    final following = await getUserField\<List\<dynamic\>\>(uid, 'following');
// 2. bio 필드 가져오기:
//    final bio = await getUserField\<String\>(uid, 'bio');
// 3. 존재하지 않거나 잘못된 경우 null 반환
//
// =============================================================================

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

// Firestore에서 특정 사용자의 단일 필드를 안전하게 가져오는 함수
Future<T?> fetchUserField<T>(String uid, String fieldName) async {
  try {
    // 해당 사용자 문서를 조회
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get();
    final data = doc.data();

    // 문서가 존재하고 필드가 포함되어 있으면 해당 값을 반환
    if (doc.exists && data != null && data.containsKey(fieldName)) {
      return data[fieldName] as T?;
    }

    // 문서 없음 또는 필드 없음 → null 반환
    return null;
  } catch (e) {
    debugPrint('Error fetching user field "$fieldName" for user $uid: $e');
    return null;
  }
}
