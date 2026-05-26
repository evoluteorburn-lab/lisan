import 'package:flutter/material.dart';
import 'dart:math' as math;

/// Ramadan Kareem inspired theme for Lisan app
/// Deep night sky background with matte gold accents
class RamadanTheme {
  // Background colors
  static const Color backgroundPrimary = Color(0xFF0A0E21);
  static const Color backgroundGradientStart = Color(0xFF0A0E21);
  static const Color backgroundGradientMid = Color(0xFF1A1F3D);
  static const Color backgroundGradientEnd = Color(0xFF0F1530);

  // Gold colors (matte)
  static const Color goldMatte = Color(0xFFD4AF37);
  static const Color goldLight = Color(0xFFF4E4BC);
  static const Color goldDark = Color(0xFFAA8C2C);
  static const Color goldGlow = Color(0x40D4AF37);

  // Text colors
  static const Color textPrimary = Color(0xFFF4E4BC);
  static const Color textSecondary = Color(0xFF8B8DB0);
  static const Color textOnGold = Color(0xFF0A0E21);

  // Mosque silhouette
  static const Color mosqueSilhouette = Color(0xFF151B3D);

  // Gradients
  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      backgroundGradientStart,
      backgroundGradientMid,
      backgroundGradientEnd,
    ],
  );

  static const LinearGradient goldButtonGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      goldLight,
      goldMatte,
      goldDark,
    ],
  );

  static const LinearGradient goldButtonGradientActive = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFFFE4A0),
      Color(0xFFE5C158),
      Color(0xFFB8962E),
    ],
  );

  // Shadows
  static List<BoxShadow> get goldButtonShadow => [
    BoxShadow(
      color: goldGlow,
      blurRadius: 8,
      offset: Offset(0, 4),
    ),
  ];

  static List<BoxShadow> get lampGlowShadow => [
    BoxShadow(
      color: Color(0x30D4AF37),
      blurRadius: 15,
      spreadRadius: 2,
    ),
  ];

  static List<BoxShadow> get lampRecordingShadow => [
    BoxShadow(
      color: Color(0x60FFD700),
      blurRadius: 30,
      spreadRadius: 10,
    ),
  ];

  // Text styles
  static const TextStyle headingStyle = TextStyle(
    color: textPrimary,
    fontSize: 28,
    fontWeight: FontWeight.bold,
    letterSpacing: 0.5,
  );

  static const TextStyle subheadingStyle = TextStyle(
    color: textSecondary,
    fontSize: 16,
    fontWeight: FontWeight.w500,
  );

  static const TextStyle buttonTextStyle = TextStyle(
    color: textOnGold,
    fontSize: 16,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle labelStyle = TextStyle(
    color: textSecondary,
    fontSize: 14,
    fontWeight: FontWeight.w400,
  );
}
