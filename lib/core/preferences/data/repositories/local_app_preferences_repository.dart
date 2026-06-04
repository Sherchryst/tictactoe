import 'package:tictactoe/core/async/serial_task_queue.dart';
import 'package:tictactoe/core/preferences/data/datasources/local_app_preferences_data_source.dart';
import 'package:tictactoe/core/preferences/data/models/app_preferences_dto.dart';
import 'package:tictactoe/core/preferences/domain/entities/app_preferences.dart';
import 'package:tictactoe/core/preferences/domain/repositories/app_preferences_repository.dart';

final class LocalAppPreferencesRepository implements AppPreferencesRepository {
  LocalAppPreferencesRepository(this._dataSource);

  final LocalAppPreferencesDataSource _dataSource;
  final _mutationQueue = SerialTaskQueue();

  @override
  Future<AppPreferences> load() async {
    await _mutationQueue.waitForIdle();
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
    return _mutationQueue.enqueue(operation);
  }
}
