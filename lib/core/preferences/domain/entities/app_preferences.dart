import 'package:freezed_annotation/freezed_annotation.dart';

part 'app_preferences.freezed.dart';

enum AppLocalePreference { english, french, spanish, german }

@freezed
abstract class AppPreferences with _$AppPreferences {
  const AppPreferences._();

  const factory AppPreferences({
    @Default(AppLocalePreference.english) AppLocalePreference localePreference,
    @Default(true) bool confirmScoreReset,
  }) = _AppPreferences;

  factory AppPreferences.defaults() => const AppPreferences();
}
