import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/result.dart';
import '../../../core/app_error_code.dart';
import '../../user/entities/user_entity.dart';
import '../../user/entities/role.dart';

// Fetch all users for admin dashboard (including all users)
//
// This function is specifically for admin users to fetch all user data
// from the 'users' collection in Firestore, including all users.
//
// Features:
// - Fetch all users including current admin
// - User statistics calculation
// - Filtering and sorting options
// - Proper error handling with Result pattern
//
// Usage:
// ```dart
// final result = await fetchAllUsersForAdmin(currentUserId: 'admin123');
// if (result.isSuccess) {
//   final users = result.data!;
//   // Use users list
// }
// ```
Future<Result<List<UserEntity>>> fetchAllUsersForAdmin({
  required String currentUserId,
  int? limit,
  Role? roleFilter,
}) async {
  try {
    Query query = FirebaseFirestore.instance.collection('users');

    // Apply role filter if specified
    if (roleFilter != null) {
      query = query.where('role', isEqualTo: roleFilter.name);
    }

    // Order by creation date (newest first)
    query = query.orderBy('createdAt', descending: true);

    if (limit != null) {
      query = query.limit(limit);
    }

    final snapshot = await query.get();

    final users = snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return UserEntity.fromJson(data);
    }).toList();

    return Result.success(users);
  } on FirebaseException catch (e) {
    return _handleFirebaseError<List<UserEntity>>(e);
  } catch (e) {
    return Result.failure(
      AppErrorCode.unknownError,
      message: 'An unexpected error occurred while fetching users: $e',
    );
  }
}

// Get comprehensive user statistics for admin dashboard
Future<Result<Map<String, int>>> getUserStatisticsForAdmin() async {
  try {
    final snapshot = await FirebaseFirestore.instance.collection('users').get();

    final users = snapshot.docs.map((doc) {
      final data = doc.data();
      return UserEntity.fromJson(data);
    }).toList();

    // Calculate statistics
    final stats = <String, int>{
      'total': users.length,
      'admins': users.where((u) => u.role == Role.admin).length,
      'users': users.where((u) => u.role == Role.user).length,
      'no_role': users.where((u) => u.role == null).length,
      'with_profile_image': users
          .where((u) => u.imageUrl != null && u.imageUrl!.isNotEmpty)
          .length,
      'verified_emails': users.where((u) => u.email.isNotEmpty).length,
    };

    // Calculate users registered in last 30 days
    final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
    stats['recent_users'] = users
        .where((u) => u.createdAt.isAfter(thirtyDaysAgo))
        .length;

    // Calculate users registered today
    final today = DateTime.now();
    final todayStart = DateTime(today.year, today.month, today.day);
    stats['today_users'] = users
        .where((u) => u.createdAt.isAfter(todayStart))
        .length;

    return Result.success(stats);
  } on FirebaseException catch (e) {
    return _handleFirebaseError<Map<String, int>>(e);
  } catch (e) {
    return Result.failure(
      AppErrorCode.unknownError,
      message:
          'An unexpected error occurred while fetching user statistics: $e',
    );
  }
}

// Search users by name or email
Future<Result<List<UserEntity>>> searchUsersForAdmin({
  required String currentUserId,
  required String searchTerm,
  int? limit,
}) async {
  try {
    if (searchTerm.trim().isEmpty) {
      return Result.failure(
        AppErrorCode.validationError,
        message: 'Search term is required',
      );
    }

    // Get all users first (Firestore doesn't support case-insensitive search)
    Query query = FirebaseFirestore.instance
        .collection('users')
        .where('userId', isNotEqualTo: currentUserId);

    if (limit != null) {
      query = query.limit(limit * 2); // Get more to filter client-side
    }

    final snapshot = await query.get();

    var users = snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return UserEntity.fromJson(data);
    }).toList();

    // Client-side search filtering
    final searchLower = searchTerm.toLowerCase();
    users = users.where((user) {
      return user.fullName.toLowerCase().contains(searchLower) ||
          user.email.toLowerCase().contains(searchLower) ||
          (user.nickname?.toLowerCase().contains(searchLower) ?? false);
    }).toList();

    // Apply limit after filtering
    if (limit != null && users.length > limit) {
      users = users.take(limit).toList();
    }

    return Result.success(users);
  } on FirebaseException catch (e) {
    return _handleFirebaseError<List<UserEntity>>(e);
  } catch (e) {
    return Result.failure(
      AppErrorCode.unknownError,
      message: 'An unexpected error occurred while searching users: $e',
    );
  }
}

// Update user role (admin only)
Future<Result<bool>> updateUserRole({
  required String userId,
  required Role newRole,
}) async {
  try {
    await FirebaseFirestore.instance.collection('users').doc(userId).update({
      'role': newRole.name,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    return Result.success(true);
  } on FirebaseException catch (e) {
    return _handleFirebaseError<bool>(e);
  } catch (e) {
    return Result.failure(
      AppErrorCode.unknownError,
      message: 'An unexpected error occurred while updating user role: $e',
    );
  }
}

// Get user activity statistics (if needed for future features)
Future<Result<Map<String, dynamic>>> getUserActivityStats({
  required String userId,
}) async {
  try {
    // This could be expanded to include user activity data
    // For now, just return basic user info
    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .get();

    if (!userDoc.exists) {
      return Result.failure(
        AppErrorCode.backendUnknownError,
        message: 'User not found',
      );
    }

    final userData = userDoc.data()!;
    final user = UserEntity.fromJson(userData);

    final stats = {
      'user': user,
      'joinDate': user.createdAt,
      'lastUpdate': user.updatedAt,
      'hasProfileImage': user.imageUrl != null && user.imageUrl!.isNotEmpty,
      'hasNickname': user.nickname != null && user.nickname!.isNotEmpty,
      'hasPhoneNumber':
          user.phoneNumber != null && user.phoneNumber!.isNotEmpty,
    };

    return Result.success(stats);
  } on FirebaseException catch (e) {
    return _handleFirebaseError<Map<String, dynamic>>(e);
  } catch (e) {
    return Result.failure(
      AppErrorCode.unknownError,
      message: 'An unexpected error occurred while fetching user activity: $e',
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
        message: 'User data not found.',
      );
    default:
      return Result.failure(
        AppErrorCode.backendUnknownError,
        message: 'Failed to process user request: ${e.message}',
      );
  }
}
