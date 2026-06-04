import 'package:tictactoe/features/game/domain/entities/board.dart';
import 'package:tictactoe/features/game/domain/entities/game_result.dart';

final class GameRules {
  const GameRules();

  static const winningLines = [
    [0, 1, 2],
    [3, 4, 5],
    [6, 7, 8],
    [0, 3, 6],
    [1, 4, 7],
    [2, 5, 8],
    [0, 4, 8],
    [2, 4, 6],
  ];

  GameResult evaluate(Board board) {
    for (final line in winningLines) {
      final firstMark = board.markAt(line.first);
      if (firstMark == null) {
        continue;
      }

      final hasLine = line.every((index) => board.markAt(index) == firstMark);
      if (hasLine) {
        return GameResult.win(winner: firstMark, winningCells: line);
      }
    }

    if (board.isFull) {
      return const GameResult.draw();
    }

    return const GameResult.ongoing();
  }
}
