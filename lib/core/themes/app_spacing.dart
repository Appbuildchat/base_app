import 'package:flutter/material.dart';

/// Application spacing constants
/// Centralizes all spacing values for consistent layout throughout the app
class AppSpacing {
  AppSpacing._(); // Private constructor to prevent instantiation

  // Base spacing values
  static const double xs = 4.0;
  static const double s = 8.0;
  static const double m = 12.0;
  static const double l = 16.0;
  static const double xl = 20.0;
  static const double xxl = 24.0;
  static const double xxxl = 32.0;
  static const double xxxxl = 40.0;
  static const double xxxxxl = 48.0;

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
