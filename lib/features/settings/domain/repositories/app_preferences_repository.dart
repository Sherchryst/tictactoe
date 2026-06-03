import 'package:tictactoe/features/settings/domain/entities/app_preferences.dart';

abstract interface class AppPreferencesRepository {
  Future<AppPreferences> load();

  Future<void> save(AppPreferences preferences);
}
