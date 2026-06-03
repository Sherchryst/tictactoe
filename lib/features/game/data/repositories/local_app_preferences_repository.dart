import 'package:tictactoe/features/game/data/datasources/local_game_preferences_data_source.dart';
import 'package:tictactoe/features/game/data/models/app_preferences_dto.dart';
import 'package:tictactoe/features/game/domain/entities/app_preferences.dart';
import 'package:tictactoe/features/game/domain/repositories/app_preferences_repository.dart';

final class LocalAppPreferencesRepository implements AppPreferencesRepository {
  LocalAppPreferencesRepository(this._dataSource);

  final LocalGamePreferencesDataSource _dataSource;
  Future<void> _mutationQueue = Future<void>.value();

  @override
  Future<AppPreferences> load() async {
    await _mutationQueue;
    return _loadNow();
  }

  @override
  Future<void> save(AppPreferences preferences) {
    return _enqueueMutation(() => _saveNow(preferences));
  }

  Future<AppPreferences> _loadNow() async {
    final preferences = await _dataSource.loadPreferences();
    return preferences?.toDomain() ?? AppPreferences.defaults();
  }

  Future<void> _saveNow(AppPreferences preferences) {
    return _dataSource.savePreferences(
      AppPreferencesDto.fromDomain(preferences),
    );
  }

  Future<T> _enqueueMutation<T>(Future<T> Function() operation) {
    final queued = _mutationQueue.then((_) => operation());
    _mutationQueue = queued.then<void>((_) {}, onError: (_) {});
    return queued;
  }
}
