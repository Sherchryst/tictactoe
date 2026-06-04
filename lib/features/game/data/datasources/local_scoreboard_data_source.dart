import 'package:tictactoe/core/storage/json_key_value_store.dart';
import 'package:tictactoe/core/storage/key_value_storage.dart';
import 'package:tictactoe/features/game/data/models/scoreboard_dto.dart';

final class LocalScoreboardDataSource {
  LocalScoreboardDataSource(KeyValueStorage storage)
    : _jsonStore = JsonKeyValueStore(storage);

  static const _scoreboardKey = 'no_mercy_scoreboard_v1';

  final JsonKeyValueStore _jsonStore;

  Future<ScoreboardDto?> loadScoreboard() async {
    return _jsonStore.readObject(_scoreboardKey, ScoreboardDto.fromJson);
  }

  Future<void> saveScoreboard(ScoreboardDto scoreboard) {
    return _jsonStore.writeObject(_scoreboardKey, scoreboard.toJson());
  }

  Future<void> resetScoreboard() {
    return _jsonStore.remove(_scoreboardKey);
  }
}
