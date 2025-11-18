import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppThemeMode {
  light,
  dark,
  system,
}

class ThemeService {
  static const String _themeModeKey = 'app_theme_mode';
  static const AppThemeMode _defaultThemeMode = AppThemeMode.system;

  /// Get the current theme mode preference
  Future<AppThemeMode> getThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final themeModeIndex = prefs.getInt(_themeModeKey);
    
    if (themeModeIndex != null && 
        themeModeIndex >= 0 && 
        themeModeIndex < AppThemeMode.values.length) {
      return AppThemeMode.values[themeModeIndex];
    }
    
    return _defaultThemeMode;
  }

  /// Set the theme mode preference
  Future<void> setThemeMode(AppThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_themeModeKey, mode.index);
  }

  /// Get ThemeMode for MaterialApp based on system preference
  Future<ThemeMode> getMaterialThemeMode() async {
    final appThemeMode = await getThemeMode();
    switch (appThemeMode) {
      case AppThemeMode.light:
        return ThemeMode.light;
      case AppThemeMode.dark:
        return ThemeMode.dark;
      case AppThemeMode.system:
        return ThemeMode.system;
    }
  }

  /// Get display name for theme mode
  String getThemeModeDisplayName(AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.light:
        return 'Licht';
      case AppThemeMode.dark:
        return 'Donker';
      case AppThemeMode.system:
        return 'Systeem';
    }
  }
}

