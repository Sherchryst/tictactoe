import 'package:tictactoe/core/preferences/data/models/app_preferences_dto.dart';
import 'package:tictactoe/core/storage/json_key_value_store.dart';
import 'package:tictactoe/core/storage/key_value_storage.dart';

final class LocalAppPreferencesDataSource {
  LocalAppPreferencesDataSource(KeyValueStorage storage)
    : _jsonStore = JsonKeyValueStore(storage);

  static const _preferencesKey = 'app_preferences';

  final JsonKeyValueStore _jsonStore;

  Future<AppPreferencesDto?> loadPreferences() async {
    return _jsonStore.readObject(_preferencesKey, AppPreferencesDto.fromJson);
  }

  Future<void> savePreferences(AppPreferencesDto preferences) {
    return _jsonStore.writeObject(_preferencesKey, preferences.toJson());
  }
}
