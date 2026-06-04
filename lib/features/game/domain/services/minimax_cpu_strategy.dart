import 'package:tictactoe/features/game/domain/entities/board.dart';
import 'package:tictactoe/features/game/domain/entities/game_domain_messages.dart';
import 'package:tictactoe/features/game/domain/entities/game_result.dart';
import 'package:tictactoe/features/game/domain/entities/game_session.dart';
import 'package:tictactoe/features/game/domain/entities/mark.dart';
import 'package:tictactoe/features/game/domain/services/cpu_strategy.dart';
import 'package:tictactoe/features/game/domain/services/game_rules.dart';

final class MinimaxCpuStrategy implements CpuStrategy {
  const MinimaxCpuStrategy({GameRules rules = const GameRules()})
    : _rules = rules;

  static const _preferredCells = [4, 0, 2, 6, 8, 1, 3, 5, 7];

  final GameRules _rules;

  @override
  int chooseMove(GameSession session) {
    return chooseMoveFor(session.board, session.cpuMark);
  }

  int chooseMoveFor(Board board, Mark mark) {
    final availableCells = _orderedEmptyCells(board);
    if (availableCells.isEmpty) {
      throw StateError(GameDomainMessages.noMoveAvailable);
    }

    var bestMove = availableCells.first;
    var bestScore = -1000;

    for (final index in availableCells) {
      final score = _minimax(
        board.place(mark, index),
        currentMark: mark.opponent,
        maximizingMark: mark,
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
    required Mark currentMark,
    required Mark maximizingMark,
    required int depth,
  }) {
    final result = _rules.evaluate(board);
    switch (result) {
      case GameWin(:final winner):
        return winner == maximizingMark ? 10 - depth : depth - 10;
      case GameDraw():
        return 0;
      case GameOngoing():
        break;
    }

    final scores = [
      for (final index in _orderedEmptyCells(board))
        _minimax(
          board.place(currentMark, index),
          currentMark: currentMark.opponent,
          maximizingMark: maximizingMark,
          depth: depth + 1,
        ),
    ];

    return currentMark == maximizingMark
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
