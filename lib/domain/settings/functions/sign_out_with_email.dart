// =============================================================================
// SIGN OUT FUNCTION (로그아웃 처리 함수)
// =============================================================================
//
// 이 함수는 Firebase Authentication에서 현재 로그인된 사용자를 로그아웃시킵니다.
//
// 주요 기능:
// 1. Firebase의 `signOut()` 메서드를 호출해 사용자 인증 세션 종료
// 2. 로그아웃 성공 여부를 `Result` 객체 형태로 반환
// 3. FirebaseAuthException 또는 기타 예외에 대해 오류 코드 및 메시지 처리
//
// 반환값:
// - 성공: `Result.success(null)`
// - 실패: `Result.failure(AppErrorCode, message: ...)`
//
// 사용 예시:
// ```dart
// final result = await signOut();
// if (result.isSuccess) {
//   // Go to welcome screen
// } else {
//   showToast(result.message);
// }
// ```
// =============================================================================

import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/result.dart';
import '../../../core/app_error_code.dart';

Future<Result<void>> signOut() async {
  try {
    // Firebase 인증에서 현재 사용자 로그아웃
    await FirebaseAuth.instance.signOut();

    // 성공 결과 반환
    return Result.success(null);
  } on FirebaseAuthException catch (e) {
    // Firebase 관련 오류 처리
    return Result.failure(
      AppErrorCode.authUnknownError,
      message: e.message ?? 'An unknown error occurred during sign-out.',
    );
  } catch (e) {
    // 그 외 모든 예외 처리
    return Result.failure(
      AppErrorCode.unknownError,
      message: 'An unexpected error occurred during sign-out.',
    );
  }
}
