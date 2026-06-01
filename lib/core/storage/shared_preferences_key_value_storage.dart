import 'package:shared_preferences/shared_preferences.dart';

import 'key_value_storage.dart';

final class SharedPreferencesKeyValueStorage implements KeyValueStorage {
  const SharedPreferencesKeyValueStorage(this._preferences);

  final SharedPreferencesAsync _preferences;

  @override
  Future<String?> readString(String key) {
    return _preferences.getString(key);
  }

  @override
  Future<void> remove(String key) {
    return _preferences.remove(key);
  }

  @override
  Future<void> writeString(String key, String value) {
    return _preferences.setString(key, value);
  }
}
