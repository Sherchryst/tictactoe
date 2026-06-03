import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:tictactoe/app/di/game_dependencies.dart';
import 'package:tictactoe/features/game/domain/entities/app_preferences.dart';
import 'package:tictactoe/features/game/domain/entities/scoreboard.dart';
import 'package:tictactoe/features/game/presentation/controllers/scoreboard_controller.dart';
import 'package:tictactoe/features/game/presentation/settings/controllers/settings_view_state.dart';

part 'settings_controller.g.dart';

@Riverpod(keepAlive: true)
final class SettingsController extends _$SettingsController {
  @override
  Future<SettingsViewState> build() async {
    ref.listen(scoreboardControllerProvider, (_, next) {
      final scoreboard = next.value;
      final current = state.value;
      if (scoreboard == null || current == null) {
        return;
      }

      state = AsyncData(current.copyWith(scoreboard: scoreboard));
    });

    final preferences = await ref.watch(loadPreferencesProvider).call();
    final scoreboard = await ref.watch(scoreboardControllerProvider.future);

    return SettingsViewState(preferences: preferences, scoreboard: scoreboard);
  }

  Future<void> setLocalePreference(AppLocalePreference localePreference) async {
    final current = state.requireValue;
    final preferences = current.preferences.copyWith(
      localePreference: localePreference,
    );
    state = AsyncData(current.copyWith(preferences: preferences));
    await ref.read(savePreferencesProvider).call(preferences);
  }

  Future<void> resetScoreboard() async {
    final current = state.requireValue;
    await ref.read(scoreboardControllerProvider.notifier).reset();
    state = AsyncData(current.copyWith(scoreboard: Scoreboard.empty()));
  }
}
