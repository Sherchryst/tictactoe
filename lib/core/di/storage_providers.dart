import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:tictactoe/core/storage/key_value_storage.dart';
import 'package:tictactoe/core/storage/shared_preferences_key_value_storage.dart';

part 'storage_providers.g.dart';

@Riverpod(keepAlive: true)
SharedPreferencesAsync sharedPreferences(Ref ref) {
  return SharedPreferencesAsync();
}

@Riverpod(keepAlive: true)
KeyValueStorage keyValueStorage(Ref ref) {
  return SharedPreferencesKeyValueStorage(ref.watch(sharedPreferencesProvider));
}
