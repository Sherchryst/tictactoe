import 'dart:ui';

import 'package:tictactoe/core/preferences/domain/entities/app_preferences.dart';

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
