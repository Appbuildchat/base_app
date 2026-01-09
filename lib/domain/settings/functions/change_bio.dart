// =============================================================================
// CHANGE BIO FUNCTIONS (소개글 변경 관련 함수들)
// =============================================================================
//
// 이 파일은 사용자의 소개글(Bio) 변경과 관련된 함수들을 제공합니다.
//
// 주요 기능:
// 1. 현재 저장된 소개글을 Firebase Firestore에서 불러오기
// 2. 새로운 소개글의 유효성 검사
// 3. 소개글을 Firebase Firestore에 업데이트
//
// 함수 목록:
// - fetchCurrentBio(): 현재 소개글 가져오기
// - validateBio(): 소개글 유효성 검사
// - changeBio(): 소개글 변경하기
// =============================================================================

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/result.dart';
import '../../../core/app_error_code.dart';

// 현재 사용자의 소개글을 Firebase Firestore에서 가져옵니다.
Future<Result<String?>> fetchCurrentBio() async {
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
    final bio = (data != null && data['bio'] is String)
        ? data['bio'] as String
        : null;

    return Result.success(bio);
  } on FirebaseException catch (e) {
    return Result.failure(
      AppErrorCode.backendUnknownError,
      message: e.message ?? 'Failed to fetch current bio',
    );
  } catch (e) {
    return Result.failure(
      AppErrorCode.unknownError,
      message: 'An unexpected error occurred while fetching bio',
    );
  }
}

// 소개글의 유효성을 검사합니다.
String? validateBio(String? value) {
  const int maxBioLength = 150;

  if (value == null || value.trim().isEmpty) {
    return 'Please enter a bio';
  }
  if (value.length > maxBioLength) {
    return 'Bio must be less than $maxBioLength characters';
  }
  return null;
}

// 사용자의 소개글을 변경합니다.
Future<Result<void>> changeBio(String newBio) async {
  try {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return Result.failure(
        AppErrorCode.authNotLoggedIn,
        message: 'User is not logged in',
      );
    }

    final trimmed = newBio.trim();
    final validationError = validateBio(trimmed);
    if (validationError != null) {
      return Result.failure(
        AppErrorCode.invalidFormat,
        message: validationError,
      );
    }

    await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
      'bio': trimmed,
    });

    return Result.success(null);
  } on FirebaseException catch (e) {
    return Result.failure(
      AppErrorCode.backendUnknownError,
      message: e.message ?? 'Failed to update bio',
    );
  } catch (e) {
    return Result.failure(
      AppErrorCode.unknownError,
      message: 'An unexpected error occurred while updating bio',
    );
  }
}
