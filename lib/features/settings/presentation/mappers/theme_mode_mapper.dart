import 'package:flutter/material.dart';

import '../../../game/domain/entities/app_theme_preference.dart';

ThemeMode themeModeFromPreference(AppThemePreference preference) {
  return switch (preference) {
    AppThemePreference.system => ThemeMode.system,
    AppThemePreference.light => ThemeMode.light,
    AppThemePreference.dark => ThemeMode.dark,
  };
}
