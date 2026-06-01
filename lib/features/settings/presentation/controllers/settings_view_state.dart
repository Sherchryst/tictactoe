import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../game/domain/entities/game_settings.dart';
import '../../../game/domain/entities/scoreboard.dart';

part 'settings_view_state.freezed.dart';

@freezed
abstract class SettingsViewState with _$SettingsViewState {
  const SettingsViewState._();

  const factory SettingsViewState({
    required GameSettings settings,
    required Scoreboard scoreboard,
  }) = _SettingsViewState;

  factory SettingsViewState.initial() {
    return SettingsViewState(
      settings: GameSettings.defaults(),
      scoreboard: Scoreboard.empty(),
    );
  }
}
