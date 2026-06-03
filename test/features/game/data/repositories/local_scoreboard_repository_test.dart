import 'package:flutter_test/flutter_test.dart';
import 'package:tictactoe/core/storage/in_memory_key_value_storage.dart';
import 'package:tictactoe/features/game/data/datasources/game_storage_keys.dart';
import 'package:tictactoe/features/game/data/datasources/local_game_preferences_data_source.dart';
import 'package:tictactoe/features/game/data/repositories/local_scoreboard_repository.dart';
import 'package:tictactoe/features/game/domain/entities/game_result.dart';
import 'package:tictactoe/features/game/domain/entities/scoreboard.dart';

void main() {
  late InMemoryKeyValueStorage storage;
  late LocalScoreboardRepository repository;

  setUp(() {
    storage = InMemoryKeyValueStorage();
    repository = LocalScoreboardRepository(
      LocalGamePreferencesDataSource(storage),
    );
  });

  test('returns an empty scoreboard when none is saved', () async {
    expect(await repository.load(), Scoreboard.empty());
  });

  test('returns an empty scoreboard when saved json is invalid', () async {
    await storage.writeString(GameStorageKeys.scoreboard, 'not-json');

    expect(await repository.load(), Scoreboard.empty());
  });

  test('returns an empty scoreboard when saved json is incomplete', () async {
    await storage.writeString(GameStorageKeys.scoreboard, '{"humanWins":1}');

    expect(await repository.load(), Scoreboard.empty());
  });

  test('saves and loads a scoreboard', () async {
    const scoreboard = Scoreboard(humanWins: 2, cpuWins: 1, draws: 1);

    await repository.save(scoreboard);

    expect(await repository.load(), scoreboard);
  });

  test('resets the saved scoreboard', () async {
    await repository.save(const Scoreboard(humanWins: 1));
    await repository.reset();

    expect(await repository.load(), Scoreboard.empty());
  });

  test('serializes concurrent score records', () async {
    await Future.wait([
      repository.record(GameOutcome.humanWin),
      repository.record(GameOutcome.cpuWin),
      repository.record(GameOutcome.draw),
    ]);

    expect(
      await repository.load(),
      const Scoreboard(humanWins: 1, cpuWins: 1, draws: 1),
    );
  });
}
