import 'package:flutter/material.dart';

/// Fixed, semantic colors used consistently for the same kind of stat
/// everywhere in the app (dashboard tiles, goal progress bars, chart bars).
/// This is deliberate — a fixed color-per-metric system, rather than a
/// single mood color, so every screen reads consistently at a glance.
class AppColors {
  AppColors._();

  static const calories = Color(0xFFFF7A45); // orange — energy burned
  static const workouts = Color(0xFF14B8A6); // teal — session/workout counts
  static const active = Color(0xFF34D399); // green — achieved / active time
  static const distance = Color(0xFF9B6BFF); // purple — distance / secondary goals

  static const dangerRed = Color(0xFFEF4444);

  // Brand colors, matching the FitPulse logo mark (orange-to-pink gradient).
  // Used for primary interactive elements (buttons, focus states, links) —
  // kept separate from the per-metric stat colors above, which stay fixed
  // regardless of brand color so dashboard/goal data stays readable.
  static const brandOrange = Color(0xFFFF8108);
  static const brandPink = Color(0xFFFA1F70);

  // Dark theme surfaces
  static const darkBg = Color(0xFF0F1115);
  static const darkSurface = Color(0xFF1A1D23);
  static const darkSurfaceAlt = Color(0xFF23262E);

  // Light theme surfaces — deliberately a step darker than the cards
  // sitting on it, so cards actually read as separate surfaces.
  static const lightBg = Color(0xFFE9EEEC);
  static const lightSurface = Color(0xFFFFFFFF);

  /// Gradient used on primary call-to-action buttons, matching the logo.
  static const primaryGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [brandOrange, brandPink],
  );

  /// Returns the fixed color for a goal type code, matching the metric
  /// it's tracking (calories vs workout count).
  static Color forGoalType(String type) {
    return type.startsWith('CALORIES') ? calories : workouts;
  }
}

class AppTheme {
  AppTheme._();

  static ThemeData get light => _build(Brightness.light);
  static ThemeData get dark => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.brandPink,
      brightness: brightness,
      surface: isDark ? AppColors.darkSurface : AppColors.lightSurface,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: isDark ? AppColors.darkBg : AppColors.lightBg,
      appBarTheme: AppBarTheme(
        backgroundColor: isDark ? AppColors.darkBg : AppColors.lightBg,
        foregroundColor: isDark ? Colors.white : Colors.black87,
        elevation: 0,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        elevation: isDark ? 0 : 1.5,
        shadowColor: Colors.black.withOpacity(0.08),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: isDark ? BorderSide.none : BorderSide(color: Colors.black.withOpacity(0.04)),
        ),
        margin: EdgeInsets.zero,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? AppColors.darkSurfaceAlt : AppColors.lightSurface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: isDark ? Colors.white12 : Colors.black12),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: isDark ? Colors.white12 : Colors.black12),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.workouts, width: 1.5),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: AppColors.workouts,
        linearTrackColor: isDark ? Colors.white12 : Colors.black12,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected) ? AppColors.workouts : null,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected) ? AppColors.workouts.withOpacity(0.5) : null,
        ),
      ),
    );
  }
}
