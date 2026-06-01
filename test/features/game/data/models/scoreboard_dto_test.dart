import 'package:flutter_test/flutter_test.dart';
import 'package:tictactoe/features/game/data/models/scoreboard_dto.dart';
import 'package:tictactoe/features/game/domain/entities/scoreboard.dart';

void main() {
  test('maps scoreboard between domain and json', () {
    const scoreboard = Scoreboard(humanWins: 2, cpuWins: 1, draws: 3);

    final json = ScoreboardDto.fromDomain(scoreboard).toJson();
    final mappedScoreboard = ScoreboardDto.fromJson(json).toDomain();

    expect(mappedScoreboard, scoreboard);
  });
}
