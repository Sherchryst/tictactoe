import '../entities/board.dart';
import '../entities/game_domain_messages.dart';
import '../entities/game_result.dart';
import '../entities/player.dart';
import 'cpu_strategy.dart';
import 'game_rules.dart';

final class MinimaxCpuStrategy implements CpuStrategy {
  const MinimaxCpuStrategy({GameRules rules = const GameRules()})
    : _rules = rules;

  static const _preferredCells = [4, 0, 2, 6, 8, 1, 3, 5, 7];

  final GameRules _rules;

  @override
  int chooseMove(Board board, Player player) {
    final availableCells = _orderedEmptyCells(board);
    if (availableCells.isEmpty) {
      throw StateError(GameDomainMessages.noMoveAvailable);
    }

    var bestMove = availableCells.first;
    var bestScore = -1000;

    for (final index in availableCells) {
      final score = _minimax(
        board.place(player.cell, index),
        currentPlayer: player.opponent,
        maximizingPlayer: player,
        depth: 1,
      );

      if (score > bestScore) {
        bestScore = score;
        bestMove = index;
      }
    }

    return bestMove;
  }

  int _minimax(
    Board board, {
    required Player currentPlayer,
    required Player maximizingPlayer,
    required int depth,
  }) {
    final result = _rules.evaluate(board);
    switch (result) {
      case GameWin(:final winner):
        return winner == maximizingPlayer ? 10 - depth : depth - 10;
      case GameDraw():
        return 0;
      case GameOngoing():
        break;
    }

    final scores = [
      for (final index in _orderedEmptyCells(board))
        _minimax(
          board.place(currentPlayer.cell, index),
          currentPlayer: currentPlayer.opponent,
          maximizingPlayer: maximizingPlayer,
          depth: depth + 1,
        ),
    ];

    return currentPlayer == maximizingPlayer
        ? scores.reduce((value, score) => value > score ? value : score)
        : scores.reduce((value, score) => value < score ? value : score);
  }

  List<int> _orderedEmptyCells(Board board) {
    return [
      for (final index in _preferredCells)
        if (board.canPlace(index)) index,
    ];
  }
}
