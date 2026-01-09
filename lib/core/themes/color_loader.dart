import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ColorLoader {
  static Map<String, dynamic>? _colorData;
  static bool _isLoaded = false;

  static Future<void> loadColors() async {
    if (_isLoaded) return;

    try {
      final String jsonString = await rootBundle.loadString(
        'assets/colorset.json',
      );
      _colorData = json.decode(jsonString);
      _isLoaded = true;
    } catch (e) {
      throw Exception('Failed to load color data: $e');
    }
  }

  static Color getColor(String colorName) {
    if (!_isLoaded || _colorData == null) {
      throw StateError('Colors not loaded. Call loadColors() first.');
    }

    final String? hexColor = _colorData![colorName];
    if (hexColor == null) {
      throw ArgumentError('Color "$colorName" not found in colorset.json');
    }

    return Color(int.parse(hexColor.replaceFirst('#', '0xFF')));
  }

  static HSLColor getHSLColor(String colorName) {
    if (!_isLoaded || _colorData == null) {
      throw StateError('Colors not loaded. Call loadColors() first.');
    }

    final Map<String, dynamic>? hslData = _colorData!['hsl_data'];
    if (hslData == null) {
      throw StateError('HSL data not found in colorset.json');
    }

    final Map<String, dynamic>? colorHsl = hslData[colorName];
    if (colorHsl == null) {
      throw ArgumentError('HSL color "$colorName" not found in colorset.json');
    }

    return HSLColor.fromAHSL(
      1.0,
      colorHsl['hue'].toDouble(),
      colorHsl['saturation'].toDouble() / 100,
      colorHsl['lightness'].toDouble() / 100,
    );
  }
}
