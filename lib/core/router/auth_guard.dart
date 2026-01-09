import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logger/logger.dart';
import '../providers/role_provider.dart';

class AuthGuard {
  static FirebaseAuth? _auth;
  static final RoleProvider _roleProvider = RoleProvider();
  static final Logger _logger = Logger();
  static bool _firebaseInitialized = false;

  /// Get FirebaseAuth instance safely
  static FirebaseAuth? get _safeAuth {
    if (!_firebaseInitialized) return null;
    _auth ??= FirebaseAuth.instance;
    return _auth;
  }

  /// Mark Firebase as initialized
  static void setFirebaseInitialized(bool value) {
    _firebaseInitialized = value;
  }

  /// Check if Firebase is ready
  static bool get isFirebaseReady => _firebaseInitialized;

  /// Check if user is currently authenticated
  static bool get isAuthenticated {
    try {
      return _safeAuth?.currentUser != null;
    } catch (e) {
      debugPrint('AuthGuard: Error checking auth state: $e');
      return false;
    }
  }

  /// Get current user
  static User? get currentUser {
    try {
      return _safeAuth?.currentUser;
    } catch (e) {
      return null;
    }
  }

  /// Stream of authentication state changes
  static Stream<User?> get authStateChanges {
    if (_safeAuth == null) return const Stream.empty();
    return _safeAuth!.authStateChanges();
  }

  /// Check if user is authenticated and redirect accordingly
  static String? redirectLogic(String currentRoute) {
    final isAuth = isAuthenticated;

    // Define public routes that don't require authentication
    final publicRoutes = [
      '/',
      '/onboarding',
      '/auth/sign-in-and-up',
      '/auth/sign-in',
      '/auth/sign-up',
      '/auth/social-sign-up',
      '/auth/sign-up-tnc',
      '/auth/sign-up-complete',
      '/auth/forgot-password',
    ];

    // If user is not authenticated and trying to access protected route
    if (!isAuth && !publicRoutes.contains(currentRoute)) {
      if (kDebugMode) {
        _logger.d('AuthGuard: Redirecting unauthenticated user to sign-in');
      }
      return '/auth/sign-in-and-up';
    }

    // If user is authenticated and trying to access auth routes (except completion flows)
    // Allow authenticated users to stay on profile completion screens
    if (isAuth &&
        publicRoutes.contains(currentRoute) &&
        currentRoute != '/' &&
        currentRoute != '/onboarding' &&
        currentRoute != '/auth/sign-in-and-up' &&
        currentRoute != '/auth/social-sign-up' &&
        currentRoute != '/auth/sign-up-tnc' &&
        currentRoute != '/auth/sign-up-complete') {
      if (kDebugMode) {
        _logger.d('AuthGuard: Redirecting authenticated user to home');
      }
      return '/home';
    }

    // Let splash screen (/) handle its own navigation logic
    // No automatic redirects from root path

    // No redirect needed
    return null;
  }

  /// Handle sign out
  static Future<void> signOut() async {
    try {
      await _safeAuth?.signOut();
      if (kDebugMode) {
        _logger.i('AuthGuard: User signed out successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        _logger.e('AuthGuard: Error signing out: $e');
      }
      rethrow;
    }
  }

  /// Check if the current user's email is verified
  static bool get isEmailVerified => _safeAuth?.currentUser?.emailVerified ?? false;

  /// Check if user has incomplete profile (for social sign-up users)
  static Future<bool> hasIncompleteProfile() async {
    final user = _safeAuth?.currentUser;
    if (user == null) return false;

    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      // If document doesn't exist, profile is incomplete
      if (!userDoc.exists) return true;

      final userData = userDoc.data();
      if (userData == null) return true;

      // Check required fields for complete profile
      final requiredFields = ['firstName', 'lastName', 'email', 'role'];
      for (String field in requiredFields) {
        if (userData[field] == null || userData[field].toString().isEmpty) {
          return true;
        }
      }

      return false;
    } catch (e) {
      if (kDebugMode) {
        _logger.e('AuthGuard: Error checking profile completeness: $e');
      }
      return false;
    }
  }

  /// Get user authentication state as a string for debugging
  static String get authStateDebug {
    final user = _safeAuth?.currentUser;
    if (user == null) return 'Not authenticated';

    return 'Authenticated: ${user.email} (verified: ${user.emailVerified})';
  }

  /// Get social data for incomplete profile redirect
  static Map<String, dynamic> getSocialDataForIncompleteProfile() {
    final user = _safeAuth?.currentUser;
    if (user == null) return {};

    // Detect the actual auth provider from Firebase providerData
    String detectedProvider = 'unknown';
    for (final providerProfile in user.providerData) {
      final providerId = providerProfile.providerId;
      if (providerId == 'google.com') {
        detectedProvider = 'google';
        break;
      } else if (providerId == 'apple.com') {
        detectedProvider = 'apple';
        break;
      }
    }

    return {
      'uid': user.uid,
      'email': user.email ?? '',
      'displayName': user.displayName ?? '',
      'firstName': user.displayName?.split(' ').first ?? '',
      'lastName': user.displayName?.split(' ').skip(1).join(' ') ?? '',
      'photoUrl': user.photoURL,
      'isSocialSignUp': true,
      'socialProvider': detectedProvider,
    };
  }

  /// Initialize auth state listener and role provider
  static void initializeAuthListener() {
    // Initialize role provider
    _roleProvider.initialize();

    if (!kDebugMode) return;
    if (_safeAuth == null) return;

    _safeAuth!.authStateChanges().listen((User? user) {
      if (user == null) {
        _logger.d('AuthGuard: User signed out');
      } else {
        _logger.d('AuthGuard: User signed in: ${user.email}');
        _logger.d('AuthGuard: Role: ${_roleProvider.roleDebugString}');
      }
    });
  }

  /// Get role provider instance
  static RoleProvider get roleProvider => _roleProvider;

  /// Get current user role
  static String get currentUserRole => _roleProvider.roleDebugString;

  /// Refresh user role from Firestore
  static Future<void> refreshUserRole() async {
    await _roleProvider.refreshUserRole();
  }
}
