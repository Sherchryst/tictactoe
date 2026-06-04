import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tictactoe/core/di/preferences_dependencies.dart';
import 'package:tictactoe/core/preferences/domain/entities/app_preferences.dart';

part 'app_preferences_controller.g.dart';

@Riverpod(keepAlive: true)
final class AppPreferencesController extends _$AppPreferencesController {
  @override
  Future<AppPreferences> build() {
    return ref.watch(loadPreferencesProvider).call();
  }

  Future<void> setLocalePreference(AppLocalePreference localePreference) async {
    final current = await _currentPreferences();
    final preferences = current.copyWith(localePreference: localePreference);
    state = AsyncData(preferences);
    await ref.read(savePreferencesProvider).call(preferences);
  }

  Future<void> setConfirmScoreReset(bool confirmScoreReset) async {
    final current = await _currentPreferences();
    final preferences = current.copyWith(confirmScoreReset: confirmScoreReset);
    state = AsyncData(preferences);
    await ref.read(savePreferencesProvider).call(preferences);
  }

  Future<AppPreferences> _currentPreferences() async {
    final value = state.value;
    if (value != null) {
      return value;
    }

    return ref.read(loadPreferencesProvider).call();
  }
}
