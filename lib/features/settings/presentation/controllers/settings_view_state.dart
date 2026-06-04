import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:tictactoe/core/preferences/domain/entities/app_preferences.dart';

part 'settings_view_state.freezed.dart';

@freezed
abstract class SettingsViewState with _$SettingsViewState {
  const SettingsViewState._();

  const factory SettingsViewState({required AppPreferences preferences}) =
      _SettingsViewState;

  factory SettingsViewState.initial() {
    return SettingsViewState(preferences: AppPreferences.defaults());
  }
}
