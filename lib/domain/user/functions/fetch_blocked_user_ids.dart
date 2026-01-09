// =============================================================================
// GET BLOCKED USER IDS (차단 유저 ID 목록 가져오기)
// =============================================================================
//
// 이 파일은 현재 로그인한 사용자를 기준으로,
// 1. 내가 차단한 유저들의 ID (`blockedUsers` 필드)
// 2. 나를 차단한 유저들의 ID (`arrayContains`)
// 를 모두 가져오는 유틸 함수입니다.
//
// 사용법:
// 1. 로그인된 사용자가 있어야 하며, 비동기로 `fetchBlockedUserIds()`를 호출합니다.
// 2. 반환 값은 차단 관련된 모든 사용자 ID들의 리스트입니다.
//
// 사용 예시:
// - 댓글/채팅 목록에서 차단된 사용자 제외하기
// - 홈 피드에 차단된 사용자의 게시글 숨기기
// =============================================================================

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// 현재 로그인된 사용자가 차단했거나, 나를 차단한 유저들의 ID를 모두 가져옵니다.
Future<List<String>> fetchBlockedUserIds() async {
  final currentUser = FirebaseAuth.instance.currentUser;
  if (currentUser == null) return [];

  // 1. 내가 차단한 유저 ID
  final myDoc = await FirebaseFirestore.instance
      .collection('users')
      .doc(currentUser.uid)
      .get();
  final blockedUsers = List<String>.from(myDoc.data()?['blockedUsers'] ?? []);

  // 2. 나를 차단한 유저 ID (arrayContains)
  final blockedByQuery = await FirebaseFirestore.instance
      .collection('users')
      .where('blockedUsers', arrayContains: currentUser.uid)
      .get();
  final blockedByUsers = blockedByQuery.docs.map((doc) => doc.id).toList();

  return [...blockedUsers, ...blockedByUsers];
}
