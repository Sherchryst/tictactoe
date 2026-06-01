import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/game_dependencies.dart';
import '../../../game/domain/entities/app_theme_preference.dart';
import '../../../game/domain/entities/game_difficulty.dart';
import '../../../game/domain/entities/game_mode.dart';
import '../../../game/domain/entities/game_settings.dart';
import '../../../game/domain/entities/scoreboard.dart';
import 'settings_view_state.dart';

final settingsControllerProvider =
    AsyncNotifierProvider<SettingsController, SettingsViewState>(
      SettingsController.new,
    );

final class SettingsController extends AsyncNotifier<SettingsViewState> {
  @override
  Future<SettingsViewState> build() async {
    final settings = await ref.watch(loadGameSettingsProvider).call();
    final scoreboard = await ref.watch(loadScoreboardProvider).call();

    return SettingsViewState(settings: settings, scoreboard: scoreboard);
  }

  Future<void> setDifficulty(GameDifficulty difficulty) async {
    final current = state.requireValue;
    final settings = current.settings.copyWith(difficulty: difficulty);
    state = AsyncData(current.copyWith(settings: settings));
    await ref.read(saveGameSettingsProvider).call(settings);
  }

  Future<void> setMode(GameMode mode) async {
    final current = state.requireValue;
    final settings = current.settings.copyWith(mode: mode);
    state = AsyncData(current.copyWith(settings: settings));
    await ref.read(saveGameSettingsProvider).call(settings);
  }

  Future<void> setThemePreference(AppThemePreference themePreference) async {
    final current = state.requireValue;
    final settings = current.settings.copyWith(
      themePreference: themePreference,
    );
    state = AsyncData(current.copyWith(settings: settings));
    await ref.read(saveGameSettingsProvider).call(settings);
  }

  Future<void> setGameSettings(GameSettings settings) async {
    final current = state.value ?? SettingsViewState.initial();
    state = AsyncData(current.copyWith(settings: settings));
    await ref.read(saveGameSettingsProvider).call(settings);
  }

  Future<void> resetScoreboard() async {
    final current = state.requireValue;
    await ref.read(resetScoreboardProvider).call();
    state = AsyncData(current.copyWith(scoreboard: Scoreboard.empty()));
  }

  void replaceScoreboard(Scoreboard scoreboard) {
    final current = state.value ?? SettingsViewState.initial();
    state = AsyncData(current.copyWith(scoreboard: scoreboard));
  }
}
