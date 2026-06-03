import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:tictactoe/features/game/domain/entities/app_preferences.dart';
import 'package:tictactoe/features/game/domain/entities/scoreboard.dart';

part 'settings_view_state.freezed.dart';

@freezed
abstract class SettingsViewState with _$SettingsViewState {
  const SettingsViewState._();

  const factory SettingsViewState({
    required AppPreferences preferences,
    required Scoreboard scoreboard,
  }) = _SettingsViewState;

  factory SettingsViewState.initial() {
    return SettingsViewState(
      preferences: AppPreferences.defaults(),
      scoreboard: Scoreboard.empty(),
    );
  }
}
