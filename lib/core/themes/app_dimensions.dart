import 'package:flutter/material.dart';

/// Application dimensions and sizing constants
/// Centralizes border radius, icon sizes, and other dimensional values
class AppDimensions {
  AppDimensions._(); // Private constructor to prevent instantiation

  // Border radius constants
  static const double radiusXS = 4.0;
  static const double radiusS = 8.0;
  static const double radiusM = 12.0;
  static const double radiusL = 16.0;
  static const double radiusXL = 20.0;
  static const double radiusXXL = 24.0;

  // Icon sizes
  static const double iconXS = 12.0;
  static const double iconS = 16.0;
  static const double iconM = 20.0;
  static const double iconL = 24.0;
  static const double iconXL = 28.0;
  static const double iconXXL = 32.0;

  // Common component dimensions
  static const double buttonHeight = 48.0;
  static const double textFieldHeight = 56.0;
  static const double appBarHeight = 56.0;
  static const double bottomNavHeight = 80.0;
  static const double dividerThickness = 1.0;

  // Avatar sizes
  static const double avatarS = 32.0;
  static const double avatarM = 48.0;
  static const double avatarL = 64.0;
  static const double avatarXL = 96.0;

  // Container sizes
  static const double containerS = 80.0;
  static const double containerM = 120.0;
  static const double containerL = 200.0;

  // Border radius helpers
  static BorderRadius get borderRadiusXS => BorderRadius.circular(radiusXS);
  static BorderRadius get borderRadiusS => BorderRadius.circular(radiusS);
  static BorderRadius get borderRadiusM => BorderRadius.circular(radiusM);
  static BorderRadius get borderRadiusL => BorderRadius.circular(radiusL);
  static BorderRadius get borderRadiusXL => BorderRadius.circular(radiusXL);
  static BorderRadius get borderRadiusXXL => BorderRadius.circular(radiusXXL);

  // Rounded rectangle border helpers
  static RoundedRectangleBorder get roundedRectangleBorderS =>
      RoundedRectangleBorder(borderRadius: borderRadiusS);
  static RoundedRectangleBorder get roundedRectangleBorderM =>
      RoundedRectangleBorder(borderRadius: borderRadiusM);
  static RoundedRectangleBorder get roundedRectangleBorderL =>
      RoundedRectangleBorder(borderRadius: borderRadiusL);
  static RoundedRectangleBorder get roundedRectangleBorderXL =>
      RoundedRectangleBorder(borderRadius: borderRadiusXL);
}
