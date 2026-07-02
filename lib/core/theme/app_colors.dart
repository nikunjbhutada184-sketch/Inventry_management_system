import 'package:flutter/material.dart';

/// Centralized app color palette.
/// These seed colors drive Material 3 ColorScheme generation.
class AppColors {
  AppColors._();

  // ─── Brand Seeds ───
  static const Color primarySeed = Color(0xFF1565C0); // Deep blue
  static const Color secondarySeed = Color(0xFF00897B); // Teal
  static const Color tertiarySeed = Color(0xFFF9A825); // Amber

  // ─── Semantic Colors ───
  static const Color success = Color(0xFF2E7D32);
  static const Color warning = Color(0xFFF57F17);
  static const Color info = Color(0xFF0277BD);
  static const Color danger = Color(0xFFC62828);

  // ─── Chart / Visualization Palette ───
  static const List<Color> chartPalette = [
    Color(0xFF1565C0),
    Color(0xFF00897B),
    Color(0xFFF9A825),
    Color(0xFFAB47BC),
    Color(0xFFEF5350),
    Color(0xFF66BB6A),
    Color(0xFF42A5F5),
    Color(0xFFFFA726),
  ];

  // ─── Gradient Presets ───
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF1565C0), Color(0xFF1E88E5)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [Color(0xFF00897B), Color(0xFF26A69A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient warmGradient = LinearGradient(
    colors: [Color(0xFFF9A825), Color(0xFFFFCA28)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkSurfaceGradient = LinearGradient(
    colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}
