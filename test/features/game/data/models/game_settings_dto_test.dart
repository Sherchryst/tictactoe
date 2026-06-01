import 'package:flutter_test/flutter_test.dart';
import 'package:tictactoe/features/game/data/models/game_settings_dto.dart';
import 'package:tictactoe/features/game/domain/entities/app_theme_preference.dart';
import 'package:tictactoe/features/game/domain/entities/game_difficulty.dart';
import 'package:tictactoe/features/game/domain/entities/game_mode.dart';
import 'package:tictactoe/features/game/domain/entities/game_settings.dart';

void main() {
  test('maps settings between domain and json', () {
    const settings = GameSettings(
      mode: GameMode.humanVsHuman,
      difficulty: GameDifficulty.hard,
      themePreference: AppThemePreference.dark,
    );

    final json = GameSettingsDto.fromDomain(settings).toJson();
    final mappedSettings = GameSettingsDto.fromJson(json).toDomain();

    expect(mappedSettings, settings);
  });

  test('defaults missing mode to human vs cpu', () {
    final settings = GameSettingsDto.fromJson(const {
      'difficulty': 'medium',
      'themePreference': 'system',
    }).toDomain();

    expect(settings.mode, GameMode.humanVsCpu);
  });
}
