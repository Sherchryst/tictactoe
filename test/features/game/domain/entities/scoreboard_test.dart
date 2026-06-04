import 'package:flutter_test/flutter_test.dart';
import 'package:tictactoe/features/game/domain/entities/scoreboard.dart';

void main() {
  test('tarnished record aggregates every boss result', () {
    const scoreboard = Scoreboard(
      radahn: BossScore(attempts: 3, humanWins: 1, cpuWins: 1, draws: 1),
      mohg: BossScore(attempts: 2, humanWins: 2),
      malenia: BossScore(attempts: 4, cpuWins: 3, draws: 1),
    );

    final record = scoreboard.tarnishedRecord;

    expect(record.attempts, 9);
    expect(record.humanWins, 3);
    expect(record.cpuWins, 4);
    expect(record.draws, 2);
  });
}
