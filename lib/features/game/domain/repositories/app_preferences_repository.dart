import 'package:tictactoe/features/game/domain/entities/app_preferences.dart';

abstract interface class AppPreferencesRepository {
  Future<AppPreferences> load();

  Future<void> save(AppPreferences preferences);
}
