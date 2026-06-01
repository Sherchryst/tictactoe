import 'package:tictactoe/core/storage/key_value_storage.dart';

final class FakeKeyValueStorage implements KeyValueStorage {
  final Map<String, String> values = {};

  @override
  Future<String?> readString(String key) async => values[key];

  @override
  Future<void> remove(String key) async {
    values.remove(key);
  }

  @override
  Future<void> writeString(String key, String value) async {
    values[key] = value;
  }
}
