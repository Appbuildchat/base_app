/// Addon Registry
///
/// 선택적 기능(Addon)을 등록하고 관리합니다.
///
/// ## Addon 이란?
/// - 앱에 선택적으로 추가할 수 있는 기능 모듈
/// - 독립적으로 초기화/해제 가능
/// - 자체 라우트 등록 가능
///
/// ## 사용법
///
/// ### main.dart에서 초기화
/// ```dart
/// void main() async {
///   WidgetsFlutterBinding.ensureInitialized();
///   await DS.initialize();
///
///   // Addons 초기화
///   await AddonRegistry.initialize([
///     if (AppConfig.enableNotification) NotificationAddon(),
///     if (AppConfig.enablePayment) PaymentAddon(),
///     if (AppConfig.enableMedia) MediaAddon(),
///   ]);
///
///   runApp(MyApp());
/// }
/// ```
///
/// ### 라우트 등록
/// ```dart
/// // app_router.dart에서
/// final routes = [
///   ...baseRoutes,
///   ...AddonRegistry.routes,
/// ];
/// ```
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Addon 추상 클래스
///
/// 새 Addon을 만들려면 이 클래스를 상속받으세요.
///
/// ```dart
/// class MyAddon extends Addon {
///   @override
///   String get name => 'my_addon';
///
///   @override
///   Future<void> initialize() async {
///     // 초기화 로직
///   }
///
///   @override
///   List<RouteBase> get routes => [
///     GoRoute(path: '/my-feature', builder: (_, __) => MyScreen()),
///   ];
/// }
/// ```
abstract class Addon {
  /// Addon 이름 (고유 식별자)
  String get name;

  /// Addon 설명
  String get description => '';

  /// 초기화
  Future<void> initialize();

  /// 해제 (선택적)
  Future<void> dispose() async {}

  /// 라우트 목록
  List<RouteBase> get routes => [];

  /// NavigatorObserver 목록 (선택적)
  List<NavigatorObserver> get observers => [];

  /// 초기화 완료 여부
  bool get isInitialized => _isInitialized;
  bool _isInitialized = false;

  /// 내부 초기화 래퍼
  Future<void> _init() async {
    if (_isInitialized) return;
    await initialize();
    _isInitialized = true;
  }
}

/// Addon Registry
///
/// 모든 Addon을 중앙에서 관리합니다.
class AddonRegistry {
  AddonRegistry._();

  static final List<Addon> _addons = [];
  static bool _initialized = false;

  /// 등록된 모든 Addon
  static List<Addon> get addons => List.unmodifiable(_addons);

  /// 초기화 여부
  static bool get isInitialized => _initialized;

  /// Addon 초기화
  ///
  /// ```dart
  /// await AddonRegistry.initialize([
  ///   NotificationAddon(),
  ///   PaymentAddon(),
  /// ]);
  /// ```
  static Future<void> initialize(List<Addon> addons) async {
    if (_initialized) {
      debugPrint('[AddonRegistry] Already initialized');
      return;
    }

    for (final addon in addons) {
      try {
        debugPrint('[AddonRegistry] Initializing ${addon.name}...');
        await addon._init();
        _addons.add(addon);
        debugPrint('[AddonRegistry] ${addon.name} initialized');
      } catch (e) {
        debugPrint('[AddonRegistry] Failed to initialize ${addon.name}: $e');
      }
    }

    _initialized = true;
    debugPrint('[AddonRegistry] ${_addons.length} addons initialized');
  }

  /// 모든 Addon 라우트
  static List<RouteBase> get routes {
    return _addons.expand((addon) => addon.routes).toList();
  }

  /// 모든 Addon NavigatorObserver
  static List<NavigatorObserver> get observers {
    return _addons.expand((addon) => addon.observers).toList();
  }

  /// 특정 Addon 가져오기
  static T? get<T extends Addon>() {
    try {
      return _addons.whereType<T>().first;
    } catch (_) {
      return null;
    }
  }

  /// Addon 등록 여부 확인
  static bool has<T extends Addon>() {
    return _addons.whereType<T>().isNotEmpty;
  }

  /// Addon 이름으로 확인
  static bool hasNamed(String name) {
    return _addons.any((addon) => addon.name == name);
  }

  /// 모든 Addon 해제
  static Future<void> dispose() async {
    for (final addon in _addons) {
      try {
        await addon.dispose();
      } catch (e) {
        debugPrint('[AddonRegistry] Failed to dispose ${addon.name}: $e');
      }
    }
    _addons.clear();
    _initialized = false;
  }
}
