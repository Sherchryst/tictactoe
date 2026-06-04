import 'package:flutter_test/flutter_test.dart';
import 'package:tictactoe/features/game/data/datasources/local_scoreboard_data_source.dart';
import 'package:tictactoe/features/game/data/repositories/local_scoreboard_repository.dart';
import 'package:tictactoe/features/game/domain/entities/cpu_boss.dart';
import 'package:tictactoe/features/game/domain/entities/game_result.dart';
import 'package:tictactoe/features/game/domain/entities/scoreboard.dart';

import '../../../../testing/in_memory_key_value_storage.dart';

void main() {
  late InMemoryKeyValueStorage storage;
  late LocalScoreboardRepository repository;

  setUp(() {
    storage = InMemoryKeyValueStorage();
    repository = LocalScoreboardRepository(LocalScoreboardDataSource(storage));
  });

  test('returns an empty scoreboard when none is saved', () async {
    expect(await repository.load(), Scoreboard.empty());
  });

  test('ignores old scoreboard json mixed with guided data', () async {
    await storage.writeString('scoreboard', '{"humanWins":1}');

    expect(await repository.load(), Scoreboard.empty());
  });

  test('saves and loads a scoreboard', () async {
    const scoreboard = Scoreboard(radahn: BossScore(attempts: 1, humanWins: 1));

    await repository.save(scoreboard);

    expect(await repository.load(), scoreboard);
  });

  test('resets the saved scoreboard', () async {
    await repository.save(
      const Scoreboard(radahn: BossScore(attempts: 1, humanWins: 1)),
    );
    await repository.reset();

    expect(await repository.load(), Scoreboard.empty());
  });

  test('serializes concurrent score records per boss', () async {
    await Future.wait([
      repository.record(CpuBossId.radahn, GameOutcome.humanWin),
      repository.record(CpuBossId.radahn, GameOutcome.cpuWin),
      repository.record(CpuBossId.mohg, GameOutcome.draw),
      repository.record(CpuBossId.guided, GameOutcome.humanWin),
    ]);

    expect(
      await repository.load(),
      const Scoreboard(
        radahn: BossScore(attempts: 2, humanWins: 1, cpuWins: 1),
        mohg: BossScore(attempts: 1, draws: 1),
      ),
    );
  });
}
