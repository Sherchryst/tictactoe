import 'package:tictactoe/features/game/domain/entities/board.dart';
import 'package:tictactoe/features/game/domain/entities/cell.dart';
import 'package:tictactoe/features/game/domain/entities/game_domain_messages.dart';
import 'package:tictactoe/features/game/domain/entities/game_result.dart';
import 'package:tictactoe/features/game/domain/entities/player.dart';

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
      final firstCell = board.cellAt(line.first);
      if (firstCell.isEmpty) {
        continue;
      }

      final hasLine = line.every((index) => board.cellAt(index) == firstCell);
      if (hasLine) {
        return GameResult.win(
          winner: _playerFor(firstCell),
          winningCells: line,
        );
      }
    }

    if (board.isFull) {
      return const GameResult.draw();
    }

    return const GameResult.ongoing();
  }

  Player _playerFor(Cell cell) {
    return switch (cell) {
      Cell.human => Player.human,
      Cell.cpu => Player.cpu,
      Cell.empty => throw ArgumentError(
        GameDomainMessages.emptyCellHasNoPlayer,
      ),
    };
  }
}
