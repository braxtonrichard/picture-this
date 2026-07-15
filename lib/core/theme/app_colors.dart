import 'package:flutter/material.dart';

/// Picture This runs on a warm, editorial palette — the app chrome stays
/// quiet so photography and vibe colors carry the visual weight.
class AppColors {
  const AppColors._();

  static const Color _lightBackground = Color(0xFFFAF7F2);
  static const Color _lightSurface = Color(0xFFFFFFFF);
  static const Color _lightSurfaceMuted = Color(0xFFF3EEE6);
  static const Color _lightTextPrimary = Color(0xFF221F1B);
  static const Color _lightTextSecondary = Color(0xFF6B6459);
  static const Color _lightDivider = Color(0xFFE8E1D6);
  static const Color _lightAccent = Color(0xFFC1694F);
  static const Color _lightAccentSoft = Color(0xFFF0DACE);

  static const Color _darkBackground = Color(0xFF14120F);
  static const Color _darkSurface = Color(0xFF1E1B17);
  static const Color _darkSurfaceMuted = Color(0xFF2A2621);
  static const Color _darkTextPrimary = Color(0xFFF5F1EA);
  static const Color _darkTextSecondary = Color(0xFFA69C8D);
  static const Color _darkDivider = Color(0xFF322D26);
  static const Color _darkAccent = Color(0xFFE08B6F);
  static const Color _darkAccentSoft = Color(0xFF3A2A22);

  static AppColorScheme of(Brightness brightness) {
    return brightness == Brightness.dark ? dark : light;
  }

  static const AppColorScheme light = AppColorScheme(
    background: _lightBackground,
    surface: _lightSurface,
    surfaceMuted: _lightSurfaceMuted,
    textPrimary: _lightTextPrimary,
    textSecondary: _lightTextSecondary,
    divider: _lightDivider,
    accent: _lightAccent,
    accentSoft: _lightAccentSoft,
  );

  static const AppColorScheme dark = AppColorScheme(
    background: _darkBackground,
    surface: _darkSurface,
    surfaceMuted: _darkSurfaceMuted,
    textPrimary: _darkTextPrimary,
    textSecondary: _darkTextSecondary,
    divider: _darkDivider,
    accent: _darkAccent,
    accentSoft: _darkAccentSoft,
  );

  /// A small, curated set of vibe accent colors — used on vibe chips and
  /// vibe pages so each one feels distinct without users picking a color.
  static const List<Color> vibePalette = <Color>[
    Color(0xFFC1694F), // clay
    Color(0xFF7A8B6F), // sage
    Color(0xFF4F6B8B), // dusty blue
    Color(0xFFB08A3E), // ochre
    Color(0xFF8A5A7A), // plum
    Color(0xFF3E7A6E), // pine
    Color(0xFFA0524B), // brick
    Color(0xFF6E6A8A), // slate violet
  ];

  static Color vibeColorFor(String seed) {
    final int index =
        seed.codeUnits.fold<int>(0, (int a, int b) => a + b) %
        vibePalette.length;
    return vibePalette[index];
  }
}

/// A resolved set of semantic colors for the current brightness.
class AppColorScheme {
  const AppColorScheme({
    required this.background,
    required this.surface,
    required this.surfaceMuted,
    required this.textPrimary,
    required this.textSecondary,
    required this.divider,
    required this.accent,
    required this.accentSoft,
  });

  final Color background;
  final Color surface;
  final Color surfaceMuted;
  final Color textPrimary;
  final Color textSecondary;
  final Color divider;
  final Color accent;
  final Color accentSoft;
}
