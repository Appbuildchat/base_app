import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import '../../domain/user/entities/role.dart';
import '../../domain/user/entities/user_entity.dart';
import '../result.dart';
import '../app_error_code.dart';

/// Role Provider for managing user roles
/// Fetches and caches user role information from Firestore
class RoleProvider extends ChangeNotifier {
  static final RoleProvider _instance = RoleProvider._internal();
  factory RoleProvider() => _instance;
  RoleProvider._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Role? _currentRole;
  UserEntity? _currentUserEntity;
  bool _isLoading = false;
  final Logger _logger = Logger();

  /// Current user role
  Role? get currentRole => _currentRole;

  /// Current user entity
  UserEntity? get currentUserEntity => _currentUserEntity;

  /// Is loading role data
  bool get isLoading => _isLoading;

  /// Initialize role provider and listen to auth changes
  void initialize() {
    _auth.authStateChanges().listen((User? user) {
      if (user == null) {
        _clearUserData();
      } else {
        _loadUserRole(user.uid);
      }
    });

    // Load initial role if user is already signed in
    final currentUser = _auth.currentUser;
    if (currentUser != null) {
      _loadUserRole(currentUser.uid);
    }
  }

  /// Load user role from Firestore
  Future<Result<Role?>> _loadUserRole(String userId) async {
    try {
      _setLoading(true);

      if (kDebugMode) {
        _logger.d('RoleProvider: Loading role for user $userId');
      }

      final docSnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .get();

      if (!docSnapshot.exists) {
        if (kDebugMode) {
          _logger.w('RoleProvider: User document does not exist');
        }
        _setRole(Role.user); // Default role for new users
        return Result.success(Role.user);
      }

      final userData = docSnapshot.data()!;
      final userEntity = UserEntity.fromJson(userData);

      _currentUserEntity = userEntity;
      _setRole(userEntity.role ?? Role.user);

      if (kDebugMode) {
        _logger.d('RoleProvider: Loaded role: ${_currentRole?.name}');
      }

      return Result.success(_currentRole);
    } on FirebaseException catch (e) {
      if (kDebugMode) {
        _logger.e('RoleProvider: Firebase error loading role: ${e.message}');
      }
      _setRole(Role.user); // Fallback to user role
      return Result.failure(
        AppErrorCode.backendUnknownError,
        message: 'Failed to load user role: ${e.message}',
      );
    } catch (e) {
      if (kDebugMode) {
        _logger.e('RoleProvider: Unknown error loading role: $e');
      }
      _setRole(Role.user); // Fallback to user role
      return Result.failure(
        AppErrorCode.unknownError,
        message: 'Unknown error loading user role',
      );
    } finally {
      _setLoading(false);
    }
  }

  /// Update user role in Firestore
  Future<Result<void>> updateUserRole(Role newRole) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      return Result.failure(
        AppErrorCode.authNotLoggedIn,
        message: 'No authenticated user',
      );
    }

    try {
      _setLoading(true);

      await _firestore.collection('users').doc(currentUser.uid).update({
        'role': newRole.name,
      });

      _setRole(newRole);

      if (kDebugMode) {
        _logger.i('RoleProvider: Updated role to: ${newRole.name}');
      }

      return Result.success(null);
    } on FirebaseException catch (e) {
      if (kDebugMode) {
        _logger.e('RoleProvider: Firebase error updating role: ${e.message}');
      }
      return Result.failure(
        AppErrorCode.backendUnknownError,
        message: 'Failed to update user role: ${e.message}',
      );
    } catch (e) {
      if (kDebugMode) {
        _logger.e('RoleProvider: Unknown error updating role: $e');
      }
      return Result.failure(
        AppErrorCode.unknownError,
        message: 'Unknown error updating user role',
      );
    } finally {
      _setLoading(false);
    }
  }

  /// Force refresh user role from Firestore
  Future<Result<Role?>> refreshUserRole() async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      _clearUserData();
      return Result.failure(
        AppErrorCode.authNotLoggedIn,
        message: 'No authenticated user',
      );
    }

    return await _loadUserRole(currentUser.uid);
  }

  /// Clear user data on sign out
  void _clearUserData() {
    _currentRole = null;
    _currentUserEntity = null;
    _isLoading = false;
    notifyListeners();

    if (kDebugMode) {
      _logger.d('RoleProvider: Cleared user data');
    }
  }

  /// Set role and notify listeners
  void _setRole(Role? role) {
    _currentRole = role;
    notifyListeners();
  }

  /// Set loading state and notify listeners
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  /// Get role for debugging
  String get roleDebugString {
    if (_isLoading) return 'Loading...';
    if (_currentRole == null) return 'No role';
    return _currentRole!.name;
  }
}
