import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import '../../../core/result.dart';
import '../../../core/app_error_code.dart';
import '../../feedback/entities/feedback_entity.dart';
import '../../feedback/entities/feedback_status.dart';

// Fetch all feedbacks for admin dashboard
//
// This function is specifically for admin users to fetch all feedback data
// from the 'feedbacks' collection in Firestore with proper filtering and sorting.
//
// Features:
// - Fetch all feedbacks (admin-only access)
// - Pagination support
// - Sorting by creation date (newest first)
// - Statistics calculation
// - Proper error handling with Result pattern
//
// Usage:
// ```dart
// final result = await fetchAllFeedbacksForAdmin();
// if (result.isSuccess) {
//   final feedbacks = result.data!;
//   // Use feedbacks list
// }
// ```
// Returns feedbacks sorted by creation date (newest first)
Future<Result<List<FeedbackEntity>>> fetchAllFeedbacksForAdmin({
  int? limit,
  DocumentSnapshot? startAfter,
}) async {
  try {
    debugPrint(
      '[admin.fetchAll] start limit=$limit startAfter=${startAfter?.id}',
    );

    Query query = FirebaseFirestore.instance
        .collection('feedbacks')
        .orderBy('createdAt', descending: true);

    if (limit != null) {
      query = query.limit(limit);
    }

    if (startAfter != null) {
      query = query.startAfterDocument(startAfter);
    }

    final snapshot = await query.get();
    debugPrint('[admin.fetchAll] fetched=${snapshot.docs.length} docs');

    final feedbacks = <FeedbackEntity>[];
    for (final doc in snapshot.docs) {
      try {
        debugPrint('[admin.fetchAll] parsing doc=${doc.id}');
        final data = (doc.data() as Map<String, dynamic>?) ?? {};

        // 필수 기본값 주입
        data['feedbackId'] ??= doc.id;
        data['createdAt'] ??= Timestamp.now();
        data['updatedAt'] ??= Timestamp.now();
        data['userId'] ??= '';
        data['userName'] ??= '';
        data['userEmail'] ??= '';
        data['title'] ??= '';
        data['description'] ??= '';

        // enum 문자열 보정 (엔티티는 enum.name을 기대)
        const okStatus = {'pending', 'complete'};
        const okCategory = {
          'bug',
          'feature',
          'improvement',
          'ui',
          'performance',
          'other',
        };
        const okPriority = {'low', 'medium', 'high', 'critical'};

        if (data['status'] == null || !okStatus.contains(data['status'])) {
          data['status'] = 'pending';
        }
        if (data['category'] == null ||
            !okCategory.contains(data['category'])) {
          data['category'] = 'other';
        }
        if (data['priority'] == null ||
            !okPriority.contains(data['priority'])) {
          data['priority'] = 'medium';
        }

        // 리스트 보정
        if (data['attachments'] == null || data['attachments'] is! List) {
          data['attachments'] = <String>[];
        }

        debugPrint(
          '[admin.fetchAll] hydrated doc=${doc.id} '
          'status=${data['status']} category=${data['category']} priority=${data['priority']} '
          'title=${(data['title'] ?? '').toString()}',
        );

        feedbacks.add(FeedbackEntity.fromJson(data));
      } catch (e, st) {
        debugPrint('[admin.fetchAll] skip doc=${doc.id} error=$e\n$st');
        continue;
      }
    }

    debugPrint(
      '[admin.fetchAll] parsed=${feedbacks.length} / fetched=${snapshot.docs.length}',
    );
    return Result.success(feedbacks);
  } on FirebaseException catch (e) {
    debugPrint(
      '[admin.fetchAll] FirebaseException code=${e.code} message=${e.message}',
    );
    return _handleFirebaseError<List<FeedbackEntity>>(e);
  } catch (e, st) {
    debugPrint('[admin.fetchAll] unknown error=$e\n$st');
    return Result.failure(
      AppErrorCode.unknownError,
      message: 'An unexpected error occurred while fetching feedbacks: $e',
    );
  }
}

// Get comprehensive feedback statistics for admin dashboard
Future<Result<Map<String, int>>> getFeedbackStatisticsForAdmin() async {
  try {
    debugPrint('[admin.stats] start');
    final col = FirebaseFirestore.instance.collection('feedbacks');

    Future<int> countDocuments(Query q) async {
      try {
        final snap = await q.count().get();
        final c = snap.count ?? 0; // int? → int 보정
        // 너무 시끄러우면 아래 라인은 주석 처리하세요.
        // debugPrint('[admin.stats] count q=$q -> $c');
        return c;
      } catch (e, st) {
        debugPrint('[admin.stats] count error: $e\n$st');
        rethrow;
      }
    }

    final futures = <String, Future<int>>{
      'total': countDocuments(col),

      // status
      'pending': countDocuments(col.where('status', isEqualTo: 'pending')),
      'complete': countDocuments(col.where('status', isEqualTo: 'complete')),

      // category
      'bugs': countDocuments(col.where('category', isEqualTo: 'bug')),
      'features': countDocuments(col.where('category', isEqualTo: 'feature')),
      'improvements': countDocuments(
        col.where('category', isEqualTo: 'improvement'),
      ),
      'ui_issues': countDocuments(col.where('category', isEqualTo: 'ui')),
      'performance': countDocuments(
        col.where('category', isEqualTo: 'performance'),
      ),

      // priority
      'high_priority': countDocuments(
        col.where('priority', whereIn: ['high', 'critical']),
      ),
      'critical_priority': countDocuments(
        col.where('priority', isEqualTo: 'critical'),
      ),
    };

    final entries = await Future.wait(
      futures.entries.map((e) async => MapEntry(e.key, await e.value)),
    );
    final stats = Map<String, int>.fromEntries(entries);

    debugPrint('[admin.stats] done -> $stats');
    return Result.success(stats);
  } on FirebaseException catch (e) {
    debugPrint(
      '[admin.stats] FirebaseException code=${e.code} message=${e.message}',
    );
    return _handleFirebaseError<Map<String, int>>(e);
  } catch (e, st) {
    debugPrint('[admin.stats] unknown error=$e\n$st');
    return Result.failure(
      AppErrorCode.unknownError,
      message:
          'An unexpected error occurred while fetching feedback statistics: $e',
    );
  }
}

// Fetch feedbacks with advanced filtering for admin
Future<Result<List<FeedbackEntity>>> fetchFeedbacksWithFilters({
  FeedbackStatus? status,
  FeedbackCategory? category,
  FeedbackPriority? priority,
  String? searchTerm,
  int? limit,
}) async {
  try {
    debugPrint(
      '[admin.fetchWithFilters] start '
      'status=${status?.name} category=${category?.name} priority=${priority?.name} '
      'search="${searchTerm ?? ''}" limit=$limit',
    );

    Query query = FirebaseFirestore.instance.collection('feedbacks');

    if (status != null) {
      query = query.where('status', isEqualTo: status.name);
    }
    if (category != null) {
      query = query.where('category', isEqualTo: category.name);
    }
    if (priority != null) {
      query = query.where('priority', isEqualTo: priority.name);
    }

    query = query.orderBy('createdAt', descending: true);

    if (limit != null) {
      query = query.limit(limit);
    }

    final snapshot = await query.get();
    debugPrint('[admin.fetchWithFilters] fetched=${snapshot.docs.length} docs');

    var feedbacks = <FeedbackEntity>[];
    for (final doc in snapshot.docs) {
      try {
        debugPrint('[admin.fetchWithFilters] parsing doc=${doc.id}');
        final data = (doc.data() as Map<String, dynamic>?) ?? {};

        data['feedbackId'] ??= doc.id;
        data['createdAt'] ??= Timestamp.now();
        data['updatedAt'] ??= Timestamp.now();
        data['userId'] ??= '';
        data['userName'] ??= '';
        data['userEmail'] ??= '';
        data['title'] ??= '';
        data['description'] ??= '';

        const okStatus = {'pending', 'complete'};
        const okCategory = {
          'bug',
          'feature',
          'improvement',
          'ui',
          'performance',
          'other',
        };
        const okPriority = {'low', 'medium', 'high', 'critical'};

        if (data['status'] == null || !okStatus.contains(data['status'])) {
          data['status'] = 'pending';
        }
        if (data['category'] == null ||
            !okCategory.contains(data['category'])) {
          data['category'] = 'other';
        }
        if (data['priority'] == null ||
            !okPriority.contains(data['priority'])) {
          data['priority'] = 'medium';
        }

        if (data['attachments'] == null || data['attachments'] is! List) {
          data['attachments'] = <String>[];
        }

        debugPrint(
          '[admin.fetchWithFilters] hydrated doc=${doc.id} '
          'status=${data['status']} category=${data['category']} priority=${data['priority']}',
        );

        feedbacks.add(FeedbackEntity.fromJson(data));
      } catch (e, st) {
        debugPrint('[admin.fetchWithFilters] skip doc=${doc.id} error=$e\n$st');
        continue;
      }
    }

    debugPrint(
      '[admin.fetchWithFilters] parsed(beforeSearch)=${feedbacks.length}',
    );
    if (searchTerm != null && searchTerm.isNotEmpty) {
      final before = feedbacks.length;
      final q = searchTerm.toLowerCase();
      feedbacks = feedbacks.where((f) {
        return f.title.toLowerCase().contains(q) ||
            f.description.toLowerCase().contains(q) ||
            f.userName.toLowerCase().contains(q);
      }).toList();
      debugPrint(
        '[admin.fetchWithFilters] after search "$searchTerm": $before -> ${feedbacks.length}',
      );
    }

    debugPrint('[admin.fetchWithFilters] done -> ${feedbacks.length} items');
    return Result.success(feedbacks);
  } on FirebaseException catch (e) {
    debugPrint(
      '[admin.fetchWithFilters] FirebaseException code=${e.code} message=${e.message}',
    );
    return _handleFirebaseError<List<FeedbackEntity>>(e);
  } catch (e, st) {
    debugPrint('[admin.fetchWithFilters] unknown error=$e\n$st');
    return Result.failure(
      AppErrorCode.unknownError,
      message:
          'An unexpected error occurred while fetching filtered feedbacks: $e',
    );
  }
}

// Update feedback status (admin only)
Future<Result<bool>> updateFeedbackStatus({
  required String feedbackId,
  required FeedbackStatus newStatus,
  String? adminResponse,
}) async {
  try {
    debugPrint(
      '[admin.updateStatus] id=$feedbackId newStatus=${newStatus.name} '
      'hasResponse=${adminResponse != null && adminResponse.isNotEmpty}',
    );
    final updateData = {
      'status': newStatus.name,
      'updatedAt': FieldValue.serverTimestamp(),
    };

    if (adminResponse != null && adminResponse.isNotEmpty) {
      updateData['adminResponse'] = adminResponse;
      updateData['adminRespondedAt'] = FieldValue.serverTimestamp();
    }

    await FirebaseFirestore.instance
        .collection('feedbacks')
        .doc(feedbackId)
        .update(updateData);

    debugPrint('[admin.updateStatus] success id=$feedbackId');
    return Result.success(true);
  } on FirebaseException catch (e) {
    debugPrint(
      '[admin.updateStatus] FirebaseException code=${e.code} message=${e.message}',
    );
    return _handleFirebaseError<bool>(e);
  } catch (e, st) {
    debugPrint('[admin.updateStatus] unknown error=$e\n$st');
    return Result.failure(
      AppErrorCode.unknownError,
      message:
          'An unexpected error occurred while updating feedback status: $e',
    );
  }
}

// Add admin response to feedback
Future<Result<bool>> addAdminResponseToFeedback({
  required String feedbackId,
  required String response,
}) async {
  try {
    debugPrint('[admin.addResponse] id=$feedbackId len=${response.length}');
    await FirebaseFirestore.instance
        .collection('feedbacks')
        .doc(feedbackId)
        .update({
          'adminResponse': response,
          'adminRespondedAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });

    debugPrint('[admin.addResponse] success id=$feedbackId');
    return Result.success(true);
  } on FirebaseException catch (e) {
    debugPrint(
      '[admin.addResponse] FirebaseException code=${e.code} message=${e.message}',
    );
    return _handleFirebaseError<bool>(e);
  } catch (e, st) {
    debugPrint('[admin.addResponse] unknown error=$e\n$st');
    return Result.failure(
      AppErrorCode.unknownError,
      message: 'An unexpected error occurred while adding admin response: $e',
    );
  }
}

// Handle Firebase-specific errors
Result<T> _handleFirebaseError<T>(FirebaseException e) {
  switch (e.code) {
    case 'permission-denied':
      return Result.failure(
        AppErrorCode.permissionDenied,
        message: 'Permission denied. Admin access required.',
      );
    case 'unavailable':
      return Result.failure(
        AppErrorCode.networkError,
        message: 'Service temporarily unavailable. Please try again.',
      );
    case 'quota-exceeded':
      return Result.failure(
        AppErrorCode.backendServiceUnavailable,
        message: 'Storage quota exceeded. Please try again later.',
      );
    case 'not-found':
      return Result.failure(
        AppErrorCode.backendUnknownError,
        message: 'Feedback not found.',
      );
    default:
      return Result.failure(
        AppErrorCode.backendUnknownError,
        message: 'Failed to process feedback request: ${e.message}',
      );
  }
}
