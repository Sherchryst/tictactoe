import 'package:flutter_test/flutter_test.dart';
import 'package:tictactoe/features/game/data/datasources/local_game_preferences_data_source.dart';
import 'package:tictactoe/features/game/data/repositories/local_scoreboard_repository.dart';
import 'package:tictactoe/features/game/domain/entities/scoreboard.dart';

import '../../../../helpers/fake_key_value_storage.dart';

void main() {
  late FakeKeyValueStorage storage;
  late LocalScoreboardRepository repository;

  setUp(() {
    storage = FakeKeyValueStorage();
    repository = LocalScoreboardRepository(
      LocalGamePreferencesDataSource(storage),
    );
  });

  test('returns an empty scoreboard when none is saved', () async {
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
}
