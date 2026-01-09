import 'package:flutter/material.dart';
import 'responsive.dart';

/// Application spacing constants
/// Centralizes all spacing values for consistent layout throughout the app
///
/// ## 사용법
///
/// ### 정적 값 (기존 방식)
/// ```dart
/// Padding(padding: EdgeInsets.all(AppSpacing.md))
/// SizedBox(height: AppSpacing.sm)
/// ```
///
/// ### 반응형 값 (NEW)
/// ```dart
/// // 디바이스별 다른 간격
/// Padding(padding: EdgeInsets.all(AppSpacing.responsive(context).md))
///
/// // 또는 직접 지정
/// Padding(padding: EdgeInsets.all(
///   AppSpacing.of(context, mobile: 16, tablet: 24, desktop: 32)
/// ))
/// ```
class AppSpacing {
  AppSpacing._(); // Private constructor to prevent instantiation

  // ============================================================
  // Base spacing values (정적)
  // ============================================================
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 40.0;
  static const double xxxl = 48.0;

  // Legacy aliases (하위 호환성)
  static const double s = 8.0;
  static const double m = 12.0;
  static const double l = 16.0;
  static const double xxxxl = 40.0;
  static const double xxxxxl = 48.0;

  // ============================================================
  // Responsive spacing (반응형)
  // ============================================================

  /// 반응형 간격 반환
  ///
  /// ```dart
  /// final spacing = AppSpacing.of(context, mobile: 16, tablet: 24, desktop: 32);
  /// ```
  static double of(
    BuildContext context, {
    required double mobile,
    double? tablet,
    double? desktop,
  }) {
    return Responsive.value<double>(
      context,
      mobile: mobile,
      tablet: tablet,
      desktop: desktop,
    );
  }

  /// 반응형 간격 객체 반환
  ///
  /// ```dart
  /// final sp = AppSpacing.responsive(context);
  /// Padding(padding: EdgeInsets.all(sp.md)) // 디바이스별 자동 조정
  /// ```
  static ResponsiveSpacing responsive(BuildContext context) {
    return ResponsiveSpacing(context);
  }

  // Vertical spacing helpers
  static const SizedBox v4 = SizedBox(height: xs);
  static const SizedBox v8 = SizedBox(height: s);
  static const SizedBox v12 = SizedBox(height: m);
  static const SizedBox v16 = SizedBox(height: l);
  static const SizedBox v20 = SizedBox(height: xl);
  static const SizedBox v24 = SizedBox(height: xxl);
  static const SizedBox v30 = SizedBox(height: 30.0);
  static const SizedBox v32 = SizedBox(height: xxxl);
  static const SizedBox v40 = SizedBox(height: xxxxl);
  static const SizedBox v48 = SizedBox(height: xxxxxl);
  static const SizedBox v60 = SizedBox(height: 60.0);

  // Horizontal spacing helpers
  static const SizedBox h4 = SizedBox(width: xs);
  static const SizedBox h8 = SizedBox(width: s);
  static const SizedBox h12 = SizedBox(width: m);
  static const SizedBox h16 = SizedBox(width: l);
  static const SizedBox h20 = SizedBox(width: xl);
  static const SizedBox h24 = SizedBox(width: xxl);
  static const SizedBox h32 = SizedBox(width: xxxl);
  static const SizedBox h40 = SizedBox(width: xxxxl);
  static const SizedBox h48 = SizedBox(width: xxxxxl);

  // Padding constants
  static const EdgeInsets paddingXS = EdgeInsets.all(xs);
  static const EdgeInsets paddingS = EdgeInsets.all(s);
  static const EdgeInsets paddingM = EdgeInsets.all(m);
  static const EdgeInsets paddingL = EdgeInsets.all(l);
  static const EdgeInsets paddingXL = EdgeInsets.all(xl);
  static const EdgeInsets paddingXXL = EdgeInsets.all(xxl);
  static const EdgeInsets paddingXXXL = EdgeInsets.all(xxxl);

  // Horizontal padding
  static const EdgeInsets paddingHorizontalXS = EdgeInsets.symmetric(
    horizontal: xs,
  );
  static const EdgeInsets paddingHorizontalS = EdgeInsets.symmetric(
    horizontal: s,
  );
  static const EdgeInsets paddingHorizontalM = EdgeInsets.symmetric(
    horizontal: m,
  );
  static const EdgeInsets paddingHorizontalL = EdgeInsets.symmetric(
    horizontal: l,
  );
  static const EdgeInsets paddingHorizontalXL = EdgeInsets.symmetric(
    horizontal: xl,
  );
  static const EdgeInsets paddingHorizontalXXL = EdgeInsets.symmetric(
    horizontal: xxl,
  );
  static const EdgeInsets paddingHorizontalXXXL = EdgeInsets.symmetric(
    horizontal: xxxl,
  );

  // Vertical padding
  static const EdgeInsets paddingVerticalXS = EdgeInsets.symmetric(
    vertical: xs,
  );
  static const EdgeInsets paddingVerticalS = EdgeInsets.symmetric(vertical: s);
  static const EdgeInsets paddingVerticalM = EdgeInsets.symmetric(vertical: m);
  static const EdgeInsets paddingVerticalL = EdgeInsets.symmetric(vertical: l);
  static const EdgeInsets paddingVerticalXL = EdgeInsets.symmetric(
    vertical: xl,
  );
  static const EdgeInsets paddingVerticalXXL = EdgeInsets.symmetric(
    vertical: xxl,
  );
  static const EdgeInsets paddingVerticalXXXL = EdgeInsets.symmetric(
    vertical: xxxl,
  );

  // Page padding standards
  static const EdgeInsets pagePadding = EdgeInsets.all(l);
  static const EdgeInsets pagePaddingHorizontal = EdgeInsets.symmetric(
    horizontal: l,
  );
  static const EdgeInsets pagePaddingVertical = EdgeInsets.symmetric(
    vertical: l,
  );

  // Component specific padding
  static const EdgeInsets buttonPadding = EdgeInsets.symmetric(
    horizontal: xxl,
    vertical: l,
  );
  static const EdgeInsets textFieldPadding = EdgeInsets.symmetric(
    horizontal: xl,
    vertical: l,
  );
  static const EdgeInsets cardPadding = EdgeInsets.all(l);
  static const EdgeInsets listItemPadding = EdgeInsets.symmetric(
    horizontal: l,
    vertical: m,
  );
}

/// 반응형 간격 클래스
///
/// 디바이스 타입에 따라 자동으로 간격을 조정합니다.
///
/// ```dart
/// final sp = AppSpacing.responsive(context);
/// Padding(padding: EdgeInsets.all(sp.md))
/// ```
class ResponsiveSpacing {
  final BuildContext _context;

  ResponsiveSpacing(this._context);

  // 반응형 간격 값들
  // mobile → tablet → desktop 순으로 증가
  double get xs => Responsive.value(_context, mobile: 4, tablet: 6, desktop: 8);
  double get sm => Responsive.value(_context, mobile: 8, tablet: 12, desktop: 16);
  double get md => Responsive.value(_context, mobile: 16, tablet: 20, desktop: 24);
  double get lg => Responsive.value(_context, mobile: 24, tablet: 32, desktop: 40);
  double get xl => Responsive.value(_context, mobile: 32, tablet: 48, desktop: 64);
  double get xxl => Responsive.value(_context, mobile: 40, tablet: 56, desktop: 72);

  // 페이지 패딩
  EdgeInsets get pagePadding => EdgeInsets.symmetric(
    horizontal: md,
    vertical: sm,
  );

  // 카드 패딩
  EdgeInsets get cardPadding => EdgeInsets.all(md);

  // 섹션 간격
  double get sectionGap => lg;

  // 아이템 간격
  double get itemGap => sm;
}
