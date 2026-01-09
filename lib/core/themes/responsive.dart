/// Responsive Utilities
///
/// 반응형 디자인을 위한 유틸리티 클래스입니다.
///
/// ## 사용법
///
/// ### BuildContext 확장
/// ```dart
/// // 현재 디바이스 타입
/// if (context.isMobile) { ... }
/// if (context.isTablet) { ... }
/// if (context.isDesktop) { ... }
///
/// // 화면 크기
/// final width = context.screenWidth;
/// final height = context.screenHeight;
/// ```
///
/// ### 반응형 값
/// ```dart
/// // 디바이스별 다른 값 반환
/// final padding = Responsive.value<double>(
///   context,
///   mobile: 16,
///   tablet: 24,
///   desktop: 32,
/// );
///
/// // 반응형 위젯
/// Responsive.builder(
///   context,
///   mobile: (context) => MobileLayout(),
///   tablet: (context) => TabletLayout(),
///   desktop: (context) => DesktopLayout(),
/// )
/// ```
library;

import 'package:flutter/material.dart';

/// 디바이스 타입
enum DeviceType { mobile, tablet, desktop }

/// Breakpoints 정의
class Breakpoints {
  Breakpoints._();

  /// 모바일 최대 너비
  static const double mobile = 600;

  /// 태블릿 최대 너비
  static const double tablet = 1024;

  /// 데스크탑 시작 너비
  static const double desktop = 1024;

  /// 대형 데스크탑 시작 너비
  static const double largeDesktop = 1440;
}

/// 반응형 유틸리티
class Responsive {
  Responsive._();

  /// 현재 디바이스 타입 반환
  static DeviceType getDeviceType(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;

    if (width < Breakpoints.mobile) {
      return DeviceType.mobile;
    } else if (width < Breakpoints.tablet) {
      return DeviceType.tablet;
    } else {
      return DeviceType.desktop;
    }
  }

  /// 모바일인지 확인
  static bool isMobile(BuildContext context) {
    return getDeviceType(context) == DeviceType.mobile;
  }

  /// 태블릿인지 확인
  static bool isTablet(BuildContext context) {
    return getDeviceType(context) == DeviceType.tablet;
  }

  /// 데스크탑인지 확인
  static bool isDesktop(BuildContext context) {
    return getDeviceType(context) == DeviceType.desktop;
  }

  /// 디바이스별 값 반환
  ///
  /// ```dart
  /// final padding = Responsive.value<double>(
  ///   context,
  ///   mobile: 16,
  ///   tablet: 24,
  ///   desktop: 32,
  /// );
  /// ```
  static T value<T>(
    BuildContext context, {
    required T mobile,
    T? tablet,
    T? desktop,
  }) {
    final deviceType = getDeviceType(context);

    switch (deviceType) {
      case DeviceType.mobile:
        return mobile;
      case DeviceType.tablet:
        return tablet ?? mobile;
      case DeviceType.desktop:
        return desktop ?? tablet ?? mobile;
    }
  }

  /// 디바이스별 위젯 빌더
  ///
  /// ```dart
  /// Responsive.builder(
  ///   context,
  ///   mobile: (context) => MobileLayout(),
  ///   tablet: (context) => TabletLayout(),
  /// )
  /// ```
  static Widget builder(
    BuildContext context, {
    required Widget Function(BuildContext) mobile,
    Widget Function(BuildContext)? tablet,
    Widget Function(BuildContext)? desktop,
  }) {
    final deviceType = getDeviceType(context);

    switch (deviceType) {
      case DeviceType.mobile:
        return mobile(context);
      case DeviceType.tablet:
        return (tablet ?? mobile)(context);
      case DeviceType.desktop:
        return (desktop ?? tablet ?? mobile)(context);
    }
  }

  /// 화면 너비의 비율로 값 계산
  ///
  /// ```dart
  /// final width = Responsive.widthPercent(context, 50); // 화면 너비의 50%
  /// ```
  static double widthPercent(BuildContext context, double percent) {
    return MediaQuery.sizeOf(context).width * (percent / 100);
  }

  /// 화면 높이의 비율로 값 계산
  static double heightPercent(BuildContext context, double percent) {
    return MediaQuery.sizeOf(context).height * (percent / 100);
  }

  /// 그리드 컬럼 수 반환
  ///
  /// ```dart
  /// GridView.count(
  ///   crossAxisCount: Responsive.gridColumns(context),
  ///   children: [...],
  /// )
  /// ```
  static int gridColumns(
    BuildContext context, {
    int mobile = 2,
    int tablet = 3,
    int desktop = 4,
  }) {
    return value<int>(
      context,
      mobile: mobile,
      tablet: tablet,
      desktop: desktop,
    );
  }
}

/// BuildContext 확장
extension ResponsiveContext on BuildContext {
  /// 현재 디바이스 타입
  DeviceType get deviceType => Responsive.getDeviceType(this);

  /// 모바일인지 확인
  bool get isMobile => Responsive.isMobile(this);

  /// 태블릿인지 확인
  bool get isTablet => Responsive.isTablet(this);

  /// 데스크탑인지 확인
  bool get isDesktop => Responsive.isDesktop(this);

  /// 화면 너비
  double get screenWidth => MediaQuery.sizeOf(this).width;

  /// 화면 높이
  double get screenHeight => MediaQuery.sizeOf(this).height;

  /// 디바이스별 값 반환
  T responsive<T>({
    required T mobile,
    T? tablet,
    T? desktop,
  }) {
    return Responsive.value<T>(
      this,
      mobile: mobile,
      tablet: tablet,
      desktop: desktop,
    );
  }
}

/// 반응형 위젯
///
/// ```dart
/// ResponsiveWidget(
///   mobile: MobileLayout(),
///   tablet: TabletLayout(),
///   desktop: DesktopLayout(),
/// )
/// ```
class ResponsiveWidget extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;

  const ResponsiveWidget({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
  });

  @override
  Widget build(BuildContext context) {
    return Responsive.builder(
      context,
      mobile: (_) => mobile,
      tablet: tablet != null ? (_) => tablet! : null,
      desktop: desktop != null ? (_) => desktop! : null,
    );
  }
}
