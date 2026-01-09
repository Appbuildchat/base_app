import 'package:flutter/material.dart';

/// Application shadow definitions
/// Centralizes all shadow styles for consistent elevation throughout the app
class AppShadows {
  AppShadows._(); // Private constructor to prevent instantiation

  // Light shadows for subtle elevation
  static const List<BoxShadow> light = [
    BoxShadow(
      color: Color.fromRGBO(0, 0, 0, 0.05),
      offset: Offset(0, 1),
      blurRadius: 2,
      spreadRadius: 0,
    ),
  ];

  // Medium shadows for cards and containers
  static const List<BoxShadow> medium = [
    BoxShadow(
      color: Color.fromRGBO(0, 0, 0, 0.08),
      offset: Offset(0, 2),
      blurRadius: 8,
      spreadRadius: 0,
    ),
    BoxShadow(
      color: Color.fromRGBO(0, 0, 0, 0.04),
      offset: Offset(0, 1),
      blurRadius: 2,
      spreadRadius: 0,
    ),
  ];

  // Strong shadows for modals and floating elements
  static const List<BoxShadow> strong = [
    BoxShadow(
      color: Color.fromRGBO(0, 0, 0, 0.12),
      offset: Offset(0, 4),
      blurRadius: 16,
      spreadRadius: 0,
    ),
    BoxShadow(
      color: Color.fromRGBO(0, 0, 0, 0.08),
      offset: Offset(0, 2),
      blurRadius: 4,
      spreadRadius: 0,
    ),
  ];

  // Heavy shadows for prominent floating elements
  static const List<BoxShadow> heavy = [
    BoxShadow(
      color: Color.fromRGBO(0, 0, 0, 0.16),
      offset: Offset(0, 8),
      blurRadius: 24,
      spreadRadius: 0,
    ),
    BoxShadow(
      color: Color.fromRGBO(0, 0, 0, 0.12),
      offset: Offset(0, 4),
      blurRadius: 8,
      spreadRadius: 0,
    ),
  ];

  // Colored shadows for primary elements
  static List<BoxShadow> primaryShadow(Color color) => [
    BoxShadow(
      color: color.withValues(alpha: 0.3),
      offset: const Offset(0, 2),
      blurRadius: 8,
      spreadRadius: 0,
    ),
  ];

  // Button-specific shadows
  static const List<BoxShadow> button = [
    BoxShadow(
      color: Color.fromRGBO(0, 0, 0, 0.1),
      offset: Offset(0, 2),
      blurRadius: 4,
      spreadRadius: 0,
    ),
  ];

  // Card shadows with subtle elevation
  static const List<BoxShadow> card = medium;

  // Modal/Dialog shadows
  static const List<BoxShadow> modal = strong;

  // Floating Action Button shadows
  static const List<BoxShadow> fab = [
    BoxShadow(
      color: Color.fromRGBO(0, 0, 0, 0.14),
      offset: Offset(0, 6),
      blurRadius: 12,
      spreadRadius: 0,
    ),
    BoxShadow(
      color: Color.fromRGBO(0, 0, 0, 0.12),
      offset: Offset(0, 3),
      blurRadius: 6,
      spreadRadius: 0,
    ),
  ];

  // Bottom sheet shadows
  static const List<BoxShadow> bottomSheet = [
    BoxShadow(
      color: Color.fromRGBO(0, 0, 0, 0.2),
      offset: Offset(0, -4),
      blurRadius: 20,
      spreadRadius: 0,
    ),
  ];
}
