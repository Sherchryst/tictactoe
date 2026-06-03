import 'dart:ui';

import 'package:freezed_annotation/freezed_annotation.dart';

part 'app_preferences.freezed.dart';

enum AppLocalePreference { english, french, spanish, german }

@freezed
abstract class AppPreferences with _$AppPreferences {
  const AppPreferences._();

  const factory AppPreferences({
    @Default(AppLocalePreference.english) AppLocalePreference localePreference,
  }) = _AppPreferences;

  factory AppPreferences.defaults() => const AppPreferences();
}

extension AppLocalePreferenceMapper on AppLocalePreference {
  Locale get locale {
    return switch (this) {
      AppLocalePreference.english => const Locale('en'),
      AppLocalePreference.french => const Locale('fr'),
      AppLocalePreference.spanish => const Locale('es'),
      AppLocalePreference.german => const Locale('de'),
    };
  }
}
