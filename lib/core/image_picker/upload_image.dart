import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/result.dart';
import '../../../../core/app_error_code.dart';

Future<Result<String>> uploadImage(
  File imageFile, {
  required String storagePath,
  String? fileName,
  String? userId,
  String? oldImageUrl,
  Map<String, String>? customMetadata,
}) async {
  if (!imageFile.existsSync()) {
    return Result.failure(
      AppErrorCode.unknownError,
      message: "Image file does not exist.",
    );
  }

  if (storagePath.isEmpty) {
    return Result.failure(
      AppErrorCode.unknownError,
      message: "Storage path cannot be empty.",
    );
  }

  try {
    final storage = FirebaseStorage.instance;

    // 파일을 바이트 데이터로 읽기
    debugPrint('[UPLOAD] 파일을 바이트로 읽는 중...');
    final Uint8List imageData = await imageFile.readAsBytes();
    debugPrint('[UPLOAD] 파일 크기: ${imageData.length} bytes');

    // 파일명 생성: 제공된 fileName 또는 타임스탬프 기반
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final finalFileName = fileName != null
        ? '${fileName}_$timestamp.jpg'
        : 'image_$timestamp.jpg';

    final storageRef = storage.ref().child('$storagePath/$finalFileName');

    debugPrint('[UPLOAD] 이미지 업로드 시작: $storagePath/$finalFileName');

    // 메타데이터 설정
    final metadata = <String, String>{
      'uploadedAt': timestamp.toString(),
      if (userId != null) 'userId': userId,
      ...?customMetadata,
    };

    // 이미지 업로드 (putData 사용)
    final uploadTask = storageRef.putData(
      imageData,
      SettableMetadata(contentType: 'image/jpeg', customMetadata: metadata),
    );

    // 업로드 진행 상황 모니터링 (선택적)
    uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
      double progress = snapshot.bytesTransferred / snapshot.totalBytes;
      debugPrint('[UPLOAD] 진행률: ${(progress * 100).toStringAsFixed(1)}%');
    });

    // 업로드 완료 대기
    final snapshot = await uploadTask;
    debugPrint('[UPLOAD] 업로드 완료: ${snapshot.totalBytes} bytes');

    // 다운로드 URL 가져오기
    final downloadUrl = await storageRef.getDownloadURL();
    debugPrint('[UPLOAD] 다운로드 URL 획득: $downloadUrl');

    // 기존 이미지 삭제 (선택적)
    if (oldImageUrl != null && oldImageUrl.isNotEmpty) {
      try {
        await _deleteOldImage(oldImageUrl);
      } catch (e) {
        debugPrint('[UPLOAD] 기존 이미지 삭제 실패 (무시됨): $e');
        // 기존 이미지 삭제 실패는 업로드 성공에 영향을 주지 않음
      }
    }

    return Result.success(downloadUrl);
  } on FirebaseException catch (e) {
    debugPrint('[UPLOAD] Firebase Storage 오류: ${e.code} - ${e.message}');

    switch (e.code) {
      case 'storage/unauthorized':
        return Result.failure(
          AppErrorCode.authOperationNotAllowed,
          message: 'You do not have permission to upload images.',
        );
      case 'storage/canceled':
        return Result.failure(
          AppErrorCode.unknownError,
          message: 'Upload was canceled.',
        );
      case 'storage/invalid-format':
        return Result.failure(
          AppErrorCode.unknownError,
          message: 'Invalid image format.',
        );
      case 'storage/quota-exceeded':
        return Result.failure(
          AppErrorCode.unknownError,
          message: 'Storage quota exceeded.',
        );
      default:
        return Result.failure(
          AppErrorCode.backendUnknownError,
          message: 'Failed to upload image: ${e.message}',
        );
    }
  } catch (e) {
    debugPrint('[UPLOAD] 알 수 없는 오류: $e');
    return Result.failure(
      AppErrorCode.unknownError,
      message: 'An unexpected error occurred during upload: $e',
    );
  }
}

/// Web-compatible image upload function using XFile
Future<Result<String>> uploadImageFromXFile(
  XFile imageFile, {
  required String storagePath,
  String? fileName,
  String? userId,
  String? oldImageUrl,
  Map<String, String>? customMetadata,
}) async {
  if (storagePath.isEmpty) {
    return Result.failure(
      AppErrorCode.unknownError,
      message: "Storage path cannot be empty.",
    );
  }

  try {
    final storage = FirebaseStorage.instance;

    // 파일을 바이트 데이터로 읽기
    debugPrint('[UPLOAD] XFile을 바이트로 읽는 중...');
    final Uint8List imageData = await imageFile.readAsBytes();
    debugPrint('[UPLOAD] 파일 크기: ${imageData.length} bytes');

    // 파일명 생성: 제공된 fileName 또는 타임스탬프 기반
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final finalFileName = fileName != null
        ? '${fileName}_$timestamp.jpg'
        : 'image_$timestamp.jpg';

    final storageRef = storage.ref().child('$storagePath/$finalFileName');

    debugPrint('[UPLOAD] 이미지 업로드 시작: $storagePath/$finalFileName');

    // 메타데이터 설정
    final metadata = <String, String>{
      'uploadedAt': timestamp.toString(),
      if (userId != null) 'userId': userId,
      ...?customMetadata,
    };

    // 이미지 업로드 (putData 사용)
    final uploadTask = storageRef.putData(
      imageData,
      SettableMetadata(contentType: 'image/jpeg', customMetadata: metadata),
    );

    // 업로드 진행 상황 모니터링 (선택적)
    uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
      double progress = snapshot.bytesTransferred / snapshot.totalBytes;
      debugPrint('[UPLOAD] 진행률: ${(progress * 100).toStringAsFixed(1)}%');
    });

    // 업로드 완료 대기
    final snapshot = await uploadTask;
    debugPrint('[UPLOAD] 업로드 완료: ${snapshot.totalBytes} bytes');

    // 다운로드 URL 가져오기
    final downloadUrl = await storageRef.getDownloadURL();
    debugPrint('[UPLOAD] 다운로드 URL 획득: $downloadUrl');

    // 기존 이미지 삭제 (선택적)
    if (oldImageUrl != null && oldImageUrl.isNotEmpty) {
      try {
        await _deleteOldImage(oldImageUrl);
      } catch (e) {
        debugPrint('[UPLOAD] 기존 이미지 삭제 실패 (무시됨): $e');
        // 기존 이미지 삭제 실패는 업로드 성공에 영향을 주지 않음
      }
    }

    return Result.success(downloadUrl);
  } on FirebaseException catch (e) {
    debugPrint('[UPLOAD] Firebase Storage 오류: ${e.code} - ${e.message}');

    switch (e.code) {
      case 'storage/unauthorized':
        return Result.failure(
          AppErrorCode.authOperationNotAllowed,
          message: 'You do not have permission to upload images.',
        );
      case 'storage/canceled':
        return Result.failure(
          AppErrorCode.unknownError,
          message: 'Upload was canceled.',
        );
      case 'storage/invalid-format':
        return Result.failure(
          AppErrorCode.unknownError,
          message: 'Invalid image format.',
        );
      case 'storage/quota-exceeded':
        return Result.failure(
          AppErrorCode.unknownError,
          message: 'Storage quota exceeded.',
        );
      default:
        return Result.failure(
          AppErrorCode.backendUnknownError,
          message: 'Failed to upload image: ${e.message}',
        );
    }
  } catch (e) {
    debugPrint('[UPLOAD] 알 수 없는 오류: $e');
    return Result.failure(
      AppErrorCode.unknownError,
      message: 'An unexpected error occurred during upload: $e',
    );
  }
}

/// 프로필 이미지 업로드를 위한 편의 함수 (File 버전)
Future<Result<String>> uploadProfileImage(
  String userId,
  File imageFile, {
  String? oldImageUrl,
}) async {
  return uploadImage(
    imageFile,
    storagePath: 'profile_images',
    fileName: '${userId}_profile',
    userId: userId,
    oldImageUrl: oldImageUrl,
    customMetadata: {'imageType': 'profile'},
  );
}

/// 프로필 이미지 업로드를 위한 편의 함수 (XFile 버전 - 웹 호환)
Future<Result<String>> uploadProfileImageFromXFile(
  String userId,
  XFile imageFile, {
  String? oldImageUrl,
}) async {
  return uploadImageFromXFile(
    imageFile,
    storagePath: 'profile_images',
    fileName: '${userId}_profile',
    userId: userId,
    oldImageUrl: oldImageUrl,
    customMetadata: {'imageType': 'profile'},
  );
}

/// 포스트 이미지 업로드를 위한 편의 함수
Future<Result<String>> uploadPostImage(
  String userId,
  File imageFile, {
  String? postId,
  int? imageIndex,
  String? oldImageUrl,
}) async {
  final fileName = postId != null
      ? '${postId}_${imageIndex ?? 0}'
      : '${userId}_post';

  return uploadImage(
    imageFile,
    storagePath: 'post_images',
    fileName: fileName,
    userId: userId,
    oldImageUrl: oldImageUrl,
    customMetadata: {
      'imageType': 'post',
      if (postId != null) 'postId': postId,
      if (imageIndex != null) 'imageIndex': imageIndex.toString(),
    },
  );
}

/// 비디오 파일 업로드 함수 (확장자/ContentType 자동 지정)
Future<Result<String>> uploadVideoFile(
  String userId,
  File videoFile, {
  String? postId,
  int? videoIndex,
  String? oldVideoUrl,
}) async {
  if (!videoFile.existsSync()) {
    return Result.failure(
      AppErrorCode.unknownError,
      message: "Video file does not exist.",
    );
  }

  final extension = videoFile.path.split('.').last.toLowerCase();
  final timestamp = DateTime.now().millisecondsSinceEpoch;
  final fileName = postId != null
      ? '${postId}_${videoIndex ?? 0}_$timestamp.$extension'
      : '${userId}_video_$timestamp.$extension';

  final storageRef = FirebaseStorage.instance.ref().child(
    'post_videos/$fileName',
  );

  // 확장자별 contentType 지정
  String contentType;
  switch (extension) {
    case 'mp4':
      contentType = 'video/mp4';
      break;
    case 'mov':
      contentType = 'video/quicktime';
      break;
    case 'avi':
      contentType = 'video/x-msvideo';
      break;
    case 'mkv':
      contentType = 'video/x-matroska';
      break;
    case 'wmv':
      contentType = 'video/x-ms-wmv';
      break;
    case 'flv':
      contentType = 'video/x-flv';
      break;
    case '3gp':
      contentType = 'video/3gpp';
      break;
    case 'webm':
      contentType = 'video/webm';
      break;
    default:
      contentType = 'application/octet-stream';
  }

  final metadata = SettableMetadata(
    contentType: contentType,
    customMetadata: {
      'uploadedAt': timestamp.toString(),
      'userId': userId,
      'fileType': 'video',
      if (postId != null) 'postId': postId,
      if (videoIndex != null) 'videoIndex': videoIndex.toString(),
    },
    contentDisposition: 'inline', // 브라우저에서 바로 재생되도록 추가
  );

  try {
    final Uint8List videoData = await videoFile.readAsBytes();
    final uploadTask = storageRef.putData(videoData, metadata);
    await uploadTask;
    final downloadUrl = await storageRef.getDownloadURL();
    // 기존 동영상 삭제 (선택)
    if (oldVideoUrl != null && oldVideoUrl.isNotEmpty) {
      try {
        final ref = FirebaseStorage.instance.refFromURL(oldVideoUrl);
        await ref.delete();
      } catch (e) {
        // 무시
      }
    }
    return Result.success(downloadUrl);
  } catch (e) {
    return Result.failure(
      AppErrorCode.unknownError,
      message: 'Video upload failed: $e',
    );
  }
}

/// Firebase Storage에서 기존 이미지를 삭제합니다.
///
/// [imageUrl]: 삭제할 이미지의 다운로드 URL
Future<void> _deleteOldImage(String imageUrl) async {
  try {
    debugPrint('[DELETE] 기존 이미지 삭제 시도: $imageUrl');

    // URL에서 Storage 참조 생성
    final ref = FirebaseStorage.instance.refFromURL(imageUrl);
    await ref.delete();

    debugPrint('[DELETE] 기존 이미지 삭제 완료');
  } on FirebaseException catch (e) {
    if (e.code == 'storage/object-not-found') {
      debugPrint('[DELETE] 삭제할 이미지가 존재하지 않음 (무시됨)');
    } else {
      debugPrint('[DELETE] 이미지 삭제 실패: ${e.code} - ${e.message}');
      rethrow;
    }
  }
}
