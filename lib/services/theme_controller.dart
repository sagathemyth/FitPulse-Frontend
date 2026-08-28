import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// App-wide light/dark mode switch, persisted locally so the choice
/// survives an app restart. Kept intentionally simple — no state
/// management package in this project, so a ValueNotifier + listener
/// on MaterialApp is all we need.
class ThemeController {
  ThemeController._();

  static const _prefsKey = 'themeMode';

  /// Defaults to dark to match the app's primary designed look.
  static final ValueNotifier<ThemeMode> mode = ValueNotifier(ThemeMode.dark);

  static Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getString(_prefsKey);
      if (saved == 'light') {
        mode.value = ThemeMode.light;
      } else {
        mode.value = ThemeMode.dark;
      }
    } catch (_) {
      // If preferences can't be read, just keep the default.
    }
  }

  static Future<void> setDark(bool isDark) async {
    mode.value = isDark ? ThemeMode.dark : ThemeMode.light;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefsKey, isDark ? 'dark' : 'light');
    } catch (_) {
      // Best-effort persistence — the toggle still works for this session.
    }
  }
}
