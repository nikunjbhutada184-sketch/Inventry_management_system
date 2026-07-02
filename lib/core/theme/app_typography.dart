import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Custom typography helpers built on top of Material 3 text theme.
class AppTypography {
  AppTypography._();

  /// Base text theme using Inter.
  static TextTheme get textTheme => GoogleFonts.interTextTheme();

  /// Display style for large hero numbers / stats.
  static TextStyle statValue(BuildContext context) {
    return Theme.of(context).textTheme.headlineLarge!.copyWith(
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5,
        );
  }

  /// Label for stat cards, subtitles.
  static TextStyle statLabel(BuildContext context) {
    return Theme.of(context).textTheme.bodySmall!.copyWith(
          fontWeight: FontWeight.w500,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
          letterSpacing: 0.4,
        );
  }

  /// Section header style.
  static TextStyle sectionHeader(BuildContext context) {
    return Theme.of(context).textTheme.titleMedium!.copyWith(
          fontWeight: FontWeight.w600,
        );
  }

  /// Page title (used in AppBars).
  static TextStyle pageTitle(BuildContext context) {
    return Theme.of(context).textTheme.titleLarge!.copyWith(
          fontWeight: FontWeight.w600,
        );
  }

  /// Caption / hint style.
  static TextStyle caption(BuildContext context) {
    return Theme.of(context).textTheme.bodySmall!.copyWith(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        );
  }
}
