import 'package:freezed_annotation/freezed_annotation.dart';

import 'app_theme_preference.dart';
import 'game_difficulty.dart';
import 'game_mode.dart';

part 'game_settings.freezed.dart';

@freezed
abstract class GameSettings with _$GameSettings {
  const GameSettings._();

  const factory GameSettings({
    @Default(GameMode.humanVsCpu) GameMode mode,
    @Default(GameDifficulty.medium) GameDifficulty difficulty,
    @Default(AppThemePreference.system) AppThemePreference themePreference,
  }) = _GameSettings;

  factory GameSettings.defaults() => const GameSettings();
}
