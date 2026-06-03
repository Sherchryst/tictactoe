import 'dart:convert';

import 'package:tictactoe/core/storage/key_value_storage.dart';
import 'package:tictactoe/features/game/data/models/scoreboard_dto.dart';

final class LocalScoreboardDataSource {
  const LocalScoreboardDataSource(this._storage);

  static const _scoreboardKey = 'scoreboard';

  final KeyValueStorage _storage;

  Future<ScoreboardDto?> loadScoreboard() async {
    final json = await _storage.readString(_scoreboardKey);
    if (json == null) {
      return null;
    }

    return _decodeObject(json, ScoreboardDto.fromJson);
  }

  Future<void> saveScoreboard(ScoreboardDto scoreboard) {
    return _storage.writeString(
      _scoreboardKey,
      jsonEncode(scoreboard.toJson()),
    );
  }

  Future<void> resetScoreboard() {
    return _storage.remove(_scoreboardKey);
  }

  T? _decodeObject<T>(String raw, T Function(Map<String, dynamic>) fromJson) {
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
