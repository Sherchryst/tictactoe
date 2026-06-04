import 'package:tictactoe/core/storage/json_key_value_store.dart';
import 'package:tictactoe/core/storage/key_value_storage.dart';
import 'package:tictactoe/features/game/data/models/no_mercy_run_dto.dart';

final class LocalNoMercyRunDataSource {
  LocalNoMercyRunDataSource(KeyValueStorage storage)
    : _jsonStore = JsonKeyValueStore(storage);

  static const _runKey = 'no_mercy_run_v1';

  final JsonKeyValueStore _jsonStore;

  Future<NoMercyRunDto?> loadRun() async {
    return _jsonStore.readObject(_runKey, NoMercyRunDto.fromJson);
  }

  Future<void> saveRun(NoMercyRunDto run) {
    return _jsonStore.writeObject(_runKey, run.toJson());
  }

  Future<void> clearRun() {
    return _jsonStore.remove(_runKey);
  }
}
