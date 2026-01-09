import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_font_weights.dart';

class FontLoader {
  static Map<String, dynamic>? _fontData;
  static bool _isLoaded = false;

  static Future<void> loadFonts() async {
    if (_isLoaded) return;

    try {
      final String jsonString = await rootBundle.loadString('assets/font.json');
      _fontData = json.decode(jsonString);
      _isLoaded = true;
    } catch (e) {
      throw Exception('Failed to load font data: $e');
    }
  }

  static String get primaryFont {
    if (!_isLoaded || _fontData == null) {
      throw StateError('Fonts not loaded. Call loadFonts() first.');
    }
    return _fontData!['primary_font'] ?? 'Inter';
  }

  static FontWeight _getFontWeight(String weightName) {
    switch (weightName.toLowerCase()) {
      case 'regular':
        return AppFontWeights.regular;
      case 'medium':
        return AppFontWeights.medium;
      case 'semibold':
        return AppFontWeights.semiBold;
      case 'bold':
        return AppFontWeights.bold;
      case 'extrabold':
        return AppFontWeights.extraBold;
      default:
        return AppFontWeights.regular;
    }
  }

  static TextStyle getTextStyle(
    String styleName, {
    Color? color,
    TextDecoration? decoration,
  }) {
    if (!_isLoaded || _fontData == null) {
      throw StateError('Fonts not loaded. Call loadFonts() first.');
    }

    final Map<String, dynamic>? typographyScale =
        _fontData!['typography_scale'];
    if (typographyScale == null) {
      throw StateError('Typography scale not found in font.json');
    }

    final Map<String, dynamic>? style = typographyScale[styleName];
    if (style == null) {
      throw ArgumentError('Style "$styleName" not found in font.json');
    }

    final double fontSize = (style['font_size'] ?? 14).toDouble();
    final String fontWeightName = style['font_weight'] ?? 'Regular';
    final double letterSpacing = (style['letter_spacing'] ?? 0).toDouble();
    final double lineHeight = (style['line_height'] ?? 1.0).toDouble();

    switch (primaryFont.toLowerCase()) {
      case 'inter':
        return GoogleFonts.inter(
          fontSize: fontSize,
          fontWeight: _getFontWeight(fontWeightName),
          color: color,
          letterSpacing: letterSpacing,
          height: lineHeight,
          decoration: decoration,
        );
      default:
        return GoogleFonts.inter(
          fontSize: fontSize,
          fontWeight: _getFontWeight(fontWeightName),
          color: color,
          letterSpacing: letterSpacing,
          height: lineHeight,
          decoration: decoration,
        );
    }
  }
}
