// =============================================================================
// CHANGE USERNAME FUNCTIONS (사용자 이름 변경 관련 함수들)
// =============================================================================
//
// 이 파일은 사용자의 이름(Username) 변경과 관련된 함수들을 제공합니다.
//
// 주요 기능:
// 1. 현재 저장된 사용자 이름을 Firebase Firestore에서 불러오기
// 2. 새로운 사용자 이름의 유효성 검사
// 3. 사용자 이름을 Firebase Firestore 및 Auth Profile에 업데이트
//
// 함수 목록:
// - fetchCurrentUsername(): 현재 사용자 이름 가져오기
// - validateUsername(): 사용자 이름 유효성 검사
// - changeUsername(): 사용자 이름 변경하기
// =============================================================================

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/result.dart';
import '../../../core/app_error_code.dart';

// 현재 사용자의 이름을 Firebase Firestore에서 가져옵니다.
Future<Result<String?>> fetchCurrentUsername() async {
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
    final username = (data != null && data['name'] is String)
        ? data['name'] as String
        : null;

    return Result.success(username);
  } on FirebaseException catch (e) {
    return Result.failure(
      AppErrorCode.backendUnknownError,
      message: e.message ?? 'Failed to fetch current username',
    );
  } catch (e) {
    return Result.failure(
      AppErrorCode.unknownError,
      message: 'An unexpected error occurred while fetching username',
    );
  }
}

// 사용자 이름의 유효성을 검사합니다.
String? validateUsername(String? value) {
  if (value == null || value.trim().isEmpty) {
    return 'Please enter a username';
  }
  if (value.length < 3) {
    return 'Username must be at least 3 characters';
  }
  if (value.length > 20) {
    return 'Username must be less than 20 characters';
  }
  if (!RegExp(r'^[a-zA-Z0-9_.]+$').hasMatch(value)) {
    return 'Username can only contain letters, numbers, underscores and dots';
  }
  return null;
}

// 사용자의 이름을 변경합니다.
Future<Result<void>> changeUsername(String newUsername) async {
  try {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return Result.failure(
        AppErrorCode.authNotLoggedIn,
        message: 'User is not logged in',
      );
    }

    final trimmedUsername = newUsername.trim();
    final validationError = validateUsername(trimmedUsername);
    if (validationError != null) {
      return Result.failure(
        AppErrorCode.invalidFormat,
        message: validationError,
      );
    }

    // Firestore 업데이트
    await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
      'name': trimmedUsername,
    });

    // Firebase Auth Profile 업데이트
    await user.updateProfile(displayName: trimmedUsername);

    return Result.success(null);
  } on FirebaseException catch (e) {
    return Result.failure(
      AppErrorCode.backendUnknownError,
      message: e.message ?? 'Failed to update username',
    );
  } catch (e) {
    return Result.failure(
      AppErrorCode.unknownError,
      message: 'An unexpected error occurred while updating username',
    );
  }
}
