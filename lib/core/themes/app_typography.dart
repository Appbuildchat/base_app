import 'package:flutter/material.dart';
import 'color_theme.dart';
import 'font_loader.dart';
import 'app_theme.dart';

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
}
