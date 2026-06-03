import 'package:tictactoe/core/storage/key_value_storage.dart';

final class InMemoryKeyValueStorage implements KeyValueStorage {
  final _values = <String, String>{};

  @override
  Future<String?> readString(String key) async => _values[key];

  @override
  Future<void> remove(String key) async {
    _values.remove(key);
  }

  @override
  Future<void> writeString(String key, String value) async {
    _values[key] = value;
  }
}
