import 'package:tictactoe/features/game/domain/entities/app_preferences.dart';
import 'package:tictactoe/features/game/domain/repositories/app_preferences_repository.dart';

final class SavePreferences {
  const SavePreferences(this._repository);

  final AppPreferencesRepository _repository;

  Future<void> call(AppPreferences preferences) {
    return _repository.save(preferences);
  }
}
