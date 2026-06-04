import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:tictactoe/core/preferences/application/controllers/app_preferences_controller.dart';
import 'package:tictactoe/core/preferences/domain/entities/app_preferences.dart';
import 'package:tictactoe/features/settings/presentation/controllers/settings_view_state.dart';

part 'settings_controller.g.dart';

@Riverpod(keepAlive: true)
final class SettingsController extends _$SettingsController {
  @override
  Future<SettingsViewState> build() async {
    final preferences = await ref.watch(
      appPreferencesControllerProvider.future,
    );
    return SettingsViewState(preferences: preferences);
  }

  Future<void> setLocalePreference(AppLocalePreference localePreference) async {
    await ref
        .read(appPreferencesControllerProvider.notifier)
        .setLocalePreference(localePreference);
    _syncFromAppPreferences();
  }

  Future<void> setConfirmScoreReset(bool confirmScoreReset) async {
    await ref
        .read(appPreferencesControllerProvider.notifier)
        .setConfirmScoreReset(confirmScoreReset);
    _syncFromAppPreferences();
  }

  void _syncFromAppPreferences() {
    final preferences = ref.read(appPreferencesControllerProvider).requireValue;
    final current = state.value ?? SettingsViewState.initial();
    state = AsyncData(current.copyWith(preferences: preferences));
  }
}
