// =============================================================================
// LOAD USER PROFILE FUNCTIONS (사용자 프로필 로드 관련 함수들)
// =============================================================================
//
// 이 파일은 사용자의 프로필 데이터를 불러오는 기능을 제공합니다.
//
// 주요 기능:
// 1. Firebase Firestore에서 사용자 프로필 정보 로드
// 2. 차단된 사용자 목록 가져오기
// 3. 사용자 데이터 구조화
//
// 함수 목록:
// - loadUserProfile(): 사용자 프로필 로드
// - fetchBlockedUserIds(): 차단된 사용자 ID 목록 가져오기
// =============================================================================

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/result.dart';
import '../../../core/app_error_code.dart';

// 사용자 프로필 데이터
class UserProfile {
  final String username;
  final String email;
  final String? bio;
  final List<String> blockedUserIds;

  UserProfile({
    required this.username,
    required this.email,
    this.bio,
    required this.blockedUserIds,
  });
}

// 현재 사용자의 프로필을 Firebase Firestore에서 로드합니다.
Future<Result<UserProfile>> loadUserProfile() async {
  try {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return Result.failure(
        AppErrorCode.authNotLoggedIn,
        message: 'User is not logged in',
      );
    }

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    if (!doc.exists) {
      return Result.failure(
        AppErrorCode.backendResourceNotFound,
        message: 'User profile not found',
      );
    }

    final data = doc.data() as Map<String, dynamic>;

    final profile = UserProfile(
      username: data['username'] ?? data['name'] ?? '사용자',
      email: data['email'] ?? user.email ?? 'mock@email.com',
      bio: data['bio'] as String?,
      blockedUserIds: List<String>.from(data['blockedUsers'] ?? []),
    );

    return Result.success(profile);
  } on FirebaseException catch (e) {
    return Result.failure(
      AppErrorCode.backendUnknownError,
      message: e.message ?? 'Failed to load user profile',
    );
  } catch (e) {
    return Result.failure(
      AppErrorCode.unknownError,
      message: 'An unexpected error occurred while loading profile',
    );
  }
}

// 차단된 사용자 ID 목록을 가져옵니다.
Future<Result<List<String>>> fetchBlockedUserIds() async {
  try {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return Result.failure(
        AppErrorCode.authNotLoggedIn,
        message: 'User is not logged in',
      );
    }

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    final data = doc.data();
    final blockedUserIds = List<String>.from(data?['blockedUsers'] ?? []);

    return Result.success(blockedUserIds);
  } on FirebaseException catch (e) {
    return Result.failure(
      AppErrorCode.backendUnknownError,
      message: e.message ?? 'Failed to fetch blocked user IDs',
    );
  } catch (e) {
    return Result.failure(
      AppErrorCode.unknownError,
      message: 'An unexpected error occurred while fetching blocked users',
    );
  }
}
