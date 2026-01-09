import 'package:flutter/material.dart';
import 'color_loader.dart';

class AppColors {
  static Color get primary => ColorLoader.getColor('primary');
  static Color get secondary => ColorLoader.getColor('secondary');
  static Color get accent => ColorLoader.getColor('accent');
  static Color get background => ColorLoader.getColor('background');
  static Color get text => ColorLoader.getColor('text');
}

class AppHSLColors {
  static HSLColor get primary => ColorLoader.getHSLColor('primary');
  static HSLColor get secondary => ColorLoader.getHSLColor('secondary');
  static HSLColor get error => ColorLoader.getHSLColor('error');
  static HSLColor get white => ColorLoader.getHSLColor('white');
  static HSLColor get grey => ColorLoader.getHSLColor('grey');
  static HSLColor get black => ColorLoader.getHSLColor('black');
}
