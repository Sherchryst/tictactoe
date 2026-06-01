import 'package:json_annotation/json_annotation.dart';

import '../../domain/entities/app_theme_preference.dart';
import '../../domain/entities/game_difficulty.dart';
import '../../domain/entities/game_mode.dart';
import '../../domain/entities/game_settings.dart';

part 'game_settings_dto.g.dart';

@JsonSerializable()
final class GameSettingsDto {
  const GameSettingsDto({
    required this.mode,
    required this.difficulty,
    required this.themePreference,
  });

  factory GameSettingsDto.fromDomain(GameSettings settings) {
    return GameSettingsDto(
      mode: settings.mode,
      difficulty: settings.difficulty,
      themePreference: settings.themePreference,
    );
  }

  factory GameSettingsDto.fromJson(Map<String, dynamic> json) {
    return _$GameSettingsDtoFromJson(json);
  }

  @JsonKey(defaultValue: GameMode.humanVsCpu)
  final GameMode mode;
  final GameDifficulty difficulty;
  final AppThemePreference themePreference;

  Map<String, dynamic> toJson() => _$GameSettingsDtoToJson(this);

  GameSettings toDomain() {
    return GameSettings(
      mode: mode,
      difficulty: difficulty,
      themePreference: themePreference,
    );
  }
}
