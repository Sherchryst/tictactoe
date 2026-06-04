import 'dart:convert';

import 'package:tictactoe/core/storage/key_value_storage.dart';

final class JsonKeyValueStore {
  const JsonKeyValueStore(this._storage);

  final KeyValueStorage _storage;

  Future<T?> readObject<T>(
    String key,
    T Function(Map<String, dynamic>) fromJson,
  ) async {
    final raw = await _storage.readString(key);
    if (raw == null) {
      return null;
    }

    return decodeObject(raw, fromJson);
  }

  Future<void> writeObject(String key, Map<String, Object?> json) {
    return _storage.writeString(key, jsonEncode(json));
  }

  Future<void> remove(String key) {
    return _storage.remove(key);
  }

  T? decodeObject<T>(String raw, T Function(Map<String, dynamic>) fromJson) {
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) {
        return null;
      }

      return fromJson(decoded);
    } catch (_) {
      return null;
    }
  }
}
