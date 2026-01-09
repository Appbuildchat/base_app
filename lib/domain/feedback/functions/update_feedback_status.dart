import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/result.dart';
import '../../../core/app_error_code.dart';
import '../entities/feedback_status.dart';

class UpdateFeedbackStatus {
  static Future<Result<void>> update({
    required String feedbackId,
    required FeedbackStatus newStatus,
    String? adminResponse,
  }) async {
    try {
      final feedbackRef = FirebaseFirestore.instance
          .collection('feedbacks')
          .doc(feedbackId);

      final updateData = {
        'status': newStatus.name,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      // If admin response is provided, add it to the update
      if (adminResponse != null && adminResponse.isNotEmpty) {
        updateData['adminResponse'] = adminResponse;
        updateData['adminRespondedAt'] = FieldValue.serverTimestamp();
      }

      await feedbackRef.update(updateData);

      return Result.success(null);
    } catch (e) {
      return Result.failure(
        AppErrorCode.backendUnknownError,
        message: 'Failed to update feedback status: ${e.toString()}',
      );
    }
  }
}
