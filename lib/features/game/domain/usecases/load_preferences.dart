import 'package:tictactoe/features/game/domain/entities/app_preferences.dart';
import 'package:tictactoe/features/game/domain/repositories/app_preferences_repository.dart';

final class LoadPreferences {
  const LoadPreferences(this._repository);

  final AppPreferencesRepository _repository;

  Future<AppPreferences> call() => _repository.load();
}
