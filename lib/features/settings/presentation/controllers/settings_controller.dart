import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:tictactoe/core/di/settings_dependencies.dart';
import 'package:tictactoe/features/settings/domain/entities/app_preferences.dart';
import 'package:tictactoe/features/settings/presentation/controllers/settings_view_state.dart';

part 'settings_controller.g.dart';

@Riverpod(keepAlive: true)
final class SettingsController extends _$SettingsController {
  @override
  Future<SettingsViewState> build() async {
    final preferences = await ref.watch(loadPreferencesProvider).call();
    return SettingsViewState(preferences: preferences);
  }

  Future<void> setLocalePreference(AppLocalePreference localePreference) async {
    final current = state.requireValue;
    final preferences = current.preferences.copyWith(
      localePreference: localePreference,
    );
    state = AsyncData(current.copyWith(preferences: preferences));
    await ref.read(savePreferencesProvider).call(preferences);
  }
}
