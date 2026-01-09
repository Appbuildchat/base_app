import 'package:flutter/material.dart';
import 'color_theme.dart';
import 'font_loader.dart';
import 'app_theme.dart';
import 'responsive.dart';

/// 앱 타이포그래피
///
/// ## 사용법
///
/// ### 정적 스타일 (기존 방식)
/// ```dart
/// Text('Hello', style: AppTypography.headline1)
/// ```
///
/// ### 반응형 스타일 (NEW)
/// ```dart
/// Text('Hello', style: AppTypography.responsive(context).h1)
/// ```
class AppTypography {
  static TextStyle get headline1 =>
      FontLoader.getTextStyle('headline1', color: AppColors.text);

  static TextStyle get headline2 =>
      FontLoader.getTextStyle('headline2', color: AppColors.text);

  static TextStyle get headline3 =>
      FontLoader.getTextStyle('headline3', color: AppColors.text);

  static TextStyle get title1 =>
      FontLoader.getTextStyle('title1', color: AppColors.text);

  static TextStyle get title2 =>
      FontLoader.getTextStyle('title2', color: AppColors.text);

  static TextStyle get bodyLarge =>
      FontLoader.getTextStyle('body_large', color: AppColors.text);

  static TextStyle get bodyRegular =>
      FontLoader.getTextStyle('body_regular', color: AppColors.text);

  static TextStyle get bodySmall =>
      FontLoader.getTextStyle('body_small', color: AppColors.secondary);

  static TextStyle get caption =>
      FontLoader.getTextStyle('caption', color: AppColors.secondary);

  static TextStyle get button => FontLoader.getTextStyle('button');

  static TextStyle get overline =>
      FontLoader.getTextStyle('overline', color: AppColors.secondary);

  // 특별한 스타일
  static TextStyle get display =>
      FontLoader.getTextStyle('display', color: AppColors.text);

  static TextStyle get subtitle =>
      FontLoader.getTextStyle('subtitle', color: AppColors.secondary);

  // 특정 용도별 스타일
  static TextStyle get errorText =>
      FontLoader.getTextStyle('error_text', color: AppColors.accent);

  static TextStyle get linkText => FontLoader.getTextStyle(
    'link_text',
    color: AppColors.primary,
    decoration: TextDecoration.underline,
  );

  static TextStyle get placeholderText => FontLoader.getTextStyle(
    'placeholder_text',
    color: AppCommonColors.grey500,
  );

  // 다크 모드용 (미래 대비)
  static TextStyle get headline1Dark =>
      headline1.copyWith(color: AppCommonColors.white);
  static TextStyle get bodyRegularDark =>
      bodyRegular.copyWith(color: AppCommonColors.white.withValues(alpha: 0.7));

  // ============================================================
  // Responsive Typography
  // ============================================================

  /// 반응형 타이포그래피 반환
  ///
  /// ```dart
  /// Text('Hello', style: AppTypography.responsive(context).h1)
  /// ```
  static ResponsiveTypography responsive(BuildContext context) {
    return ResponsiveTypography(context);
  }
}

/// 반응형 타이포그래피 클래스
///
/// 디바이스 타입에 따라 폰트 크기를 자동 조정합니다.
class ResponsiveTypography {
  final BuildContext _context;

  ResponsiveTypography(this._context);

  // 폰트 크기 스케일 팩터
  double get _scaleFactor {
    return Responsive.value<double>(
      _context,
      mobile: 1.0,
      tablet: 1.1,
      desktop: 1.2,
    );
  }

  /// Display (가장 큰 제목)
  TextStyle get display => AppTypography.display.copyWith(
    fontSize: (AppTypography.display.fontSize ?? 48) * _scaleFactor,
  );

  /// Headline 1
  TextStyle get h1 => AppTypography.headline1.copyWith(
    fontSize: (AppTypography.headline1.fontSize ?? 32) * _scaleFactor,
  );

  /// Headline 2
  TextStyle get h2 => AppTypography.headline2.copyWith(
    fontSize: (AppTypography.headline2.fontSize ?? 24) * _scaleFactor,
  );

  /// Headline 3
  TextStyle get h3 => AppTypography.headline3.copyWith(
    fontSize: (AppTypography.headline3.fontSize ?? 20) * _scaleFactor,
  );

  /// Title 1
  TextStyle get title1 => AppTypography.title1.copyWith(
    fontSize: (AppTypography.title1.fontSize ?? 18) * _scaleFactor,
  );

  /// Title 2
  TextStyle get title2 => AppTypography.title2.copyWith(
    fontSize: (AppTypography.title2.fontSize ?? 16) * _scaleFactor,
  );

  /// Body Large
  TextStyle get bodyLg => AppTypography.bodyLarge.copyWith(
    fontSize: (AppTypography.bodyLarge.fontSize ?? 16) * _scaleFactor,
  );

  /// Body Regular
  TextStyle get body => AppTypography.bodyRegular.copyWith(
    fontSize: (AppTypography.bodyRegular.fontSize ?? 14) * _scaleFactor,
  );

  /// Body Small
  TextStyle get bodySm => AppTypography.bodySmall.copyWith(
    fontSize: (AppTypography.bodySmall.fontSize ?? 12) * _scaleFactor,
  );

  /// Caption
  TextStyle get caption => AppTypography.caption.copyWith(
    fontSize: (AppTypography.caption.fontSize ?? 12) * _scaleFactor,
  );

  /// Button
  TextStyle get button => AppTypography.button.copyWith(
    fontSize: (AppTypography.button.fontSize ?? 14) * _scaleFactor,
  );
}
