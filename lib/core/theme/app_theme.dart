import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_spacing.dart';
import 'app_typography.dart';

// Re-exported so any file that imports the theme (for `context.appColors`)
// also gets the `AppColorScheme` type it returns, without a second import.
export 'app_colors.dart' show AppColorScheme;

/// Builds the light/dark ThemeData for Picture This. Kept as one place so
/// every screen inherits the same warm, minimal, photography-first look
/// instead of screens reaching for raw colors.
class AppTheme {
  const AppTheme._();

  static ThemeData light() => _build(Brightness.light);
  static ThemeData dark() => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final AppColorScheme colors = AppColors.of(brightness);
    final TextTheme textTheme = AppTypography.textTheme(colors);

    final ColorScheme colorScheme = brightness == Brightness.dark
        ? ColorScheme.dark(
            surface: colors.surface,
            onSurface: colors.textPrimary,
            primary: colors.accent,
            onPrimary: colors.background,
            secondary: colors.accentSoft,
            onSecondary: colors.textPrimary,
            error: const Color(0xFFCF6679),
          )
        : ColorScheme.light(
            surface: colors.surface,
            onSurface: colors.textPrimary,
            primary: colors.accent,
            onPrimary: Colors.white,
            secondary: colors.accentSoft,
            onSecondary: colors.textPrimary,
            error: const Color(0xFFB3261E),
          );

    return ThemeData(
      brightness: brightness,
      useMaterial3: true,
      scaffoldBackgroundColor: colors.background,
      colorScheme: colorScheme,
      textTheme: textTheme,
      splashFactory: InkSparkle.splashFactory,
      dividerTheme: DividerThemeData(
        color: colors.divider,
        thickness: 1,
        space: 1,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: colors.background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: textTheme.headlineMedium,
        iconTheme: IconThemeData(color: colors.textPrimary),
      ),
      cardTheme: CardThemeData(
        color: colors.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: colors.surfaceMuted,
        selectedColor: colors.accentSoft,
        labelStyle: textTheme.labelLarge,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.pill),
          side: BorderSide.none,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colors.textPrimary,
          foregroundColor: colors.background,
          minimumSize: const Size.fromHeight(56),
          elevation: 0,
          textStyle: textTheme.labelLarge,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.pill),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colors.textPrimary,
          minimumSize: const Size.fromHeight(56),
          side: BorderSide(color: colors.divider),
          textStyle: textTheme.labelLarge,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.pill),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colors.textPrimary,
          textStyle: textTheme.labelLarge,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colors.surfaceMuted,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.lg,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide.none,
        ),
        hintStyle: textTheme.bodyLarge?.copyWith(color: colors.textSecondary),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: colors.surface.withValues(alpha: 0.85),
        selectedItemColor: colors.textPrimary,
        unselectedItemColor: colors.textSecondary,
        type: BottomNavigationBarType.fixed,
        showUnselectedLabels: true,
        elevation: 0,
      ),
      extensions: <ThemeExtension<dynamic>>[AppThemeExtension(colors: colors)],
    );
  }
}

/// Exposes [AppColorScheme] through the standard ThemeExtension mechanism
/// so widgets can do `Theme.of(context).extension<AppThemeExtension>()`
/// for colors that don't map onto Material's ColorScheme (e.g. surfaceMuted,
/// textSecondary, accentSoft).
class AppThemeExtension extends ThemeExtension<AppThemeExtension> {
  const AppThemeExtension({required this.colors});

  final AppColorScheme colors;

  @override
  AppThemeExtension copyWith({AppColorScheme? colors}) {
    return AppThemeExtension(colors: colors ?? this.colors);
  }

  @override
  AppThemeExtension lerp(ThemeExtension<AppThemeExtension>? other, double t) {
    if (other is! AppThemeExtension) return this;
    return t < 0.5 ? this : other;
  }
}

extension AppThemeContext on BuildContext {
  AppColorScheme get appColors =>
      Theme.of(this).extension<AppThemeExtension>()!.colors;
}
