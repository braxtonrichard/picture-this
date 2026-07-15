import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// Fraunces (a warm, editorial serif) for anything that should feel
/// considered — headlines, vibe names, prompts. Inter for everything
/// functional. The pairing is the single biggest driver of the app's
/// "intentional, not another feed" feeling, so it is used consistently
/// rather than mixed in ad hoc.
class AppTypography {
  const AppTypography._();

  static TextTheme textTheme(AppColorScheme colors) {
    final TextTheme base = TextTheme(
      displayLarge: GoogleFonts.fraunces(
        fontSize: 40,
        height: 1.1,
        fontWeight: FontWeight.w500,
        letterSpacing: -0.5,
        color: colors.textPrimary,
      ),
      displayMedium: GoogleFonts.fraunces(
        fontSize: 32,
        height: 1.15,
        fontWeight: FontWeight.w500,
        letterSpacing: -0.3,
        color: colors.textPrimary,
      ),
      headlineLarge: GoogleFonts.fraunces(
        fontSize: 26,
        height: 1.2,
        fontWeight: FontWeight.w500,
        color: colors.textPrimary,
      ),
      headlineMedium: GoogleFonts.fraunces(
        fontSize: 22,
        height: 1.25,
        fontWeight: FontWeight.w500,
        color: colors.textPrimary,
      ),
      titleLarge: GoogleFonts.fraunces(
        fontSize: 18,
        height: 1.3,
        fontStyle: FontStyle.italic,
        fontWeight: FontWeight.w400,
        color: colors.textPrimary,
      ),
      titleMedium: GoogleFonts.inter(
        fontSize: 16,
        height: 1.4,
        fontWeight: FontWeight.w600,
        color: colors.textPrimary,
      ),
      bodyLarge: GoogleFonts.inter(
        fontSize: 16,
        height: 1.5,
        fontWeight: FontWeight.w400,
        color: colors.textPrimary,
      ),
      bodyMedium: GoogleFonts.inter(
        fontSize: 14,
        height: 1.5,
        fontWeight: FontWeight.w400,
        color: colors.textSecondary,
      ),
      labelLarge: GoogleFonts.inter(
        fontSize: 14,
        height: 1.2,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
        color: colors.textPrimary,
      ),
      labelMedium: GoogleFonts.inter(
        fontSize: 12,
        height: 1.3,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.4,
        color: colors.textSecondary,
      ),
      labelSmall: GoogleFonts.inter(
        fontSize: 11,
        height: 1.3,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.6,
        color: colors.textSecondary,
      ),
    );
    return base;
  }
}
