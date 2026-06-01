import '../entities/board.dart';
import '../entities/game_domain_messages.dart';
import '../entities/game_result.dart';
import '../entities/player.dart';
import 'cpu_strategy.dart';
import 'game_rules.dart';

final class TacticalCpuStrategy implements CpuStrategy {
  const TacticalCpuStrategy({GameRules rules = const GameRules()})
    : _rules = rules;

  static const _preferredCells = [4, 0, 2, 6, 8, 1, 3, 5, 7];

  final GameRules _rules;

  @override
  int chooseMove(Board board, Player player) {
    final winningMove = _immediateWinningMove(board, player);
    if (winningMove != null) {
      return winningMove;
    }

    final blockingMove = _immediateWinningMove(board, player.opponent);
    if (blockingMove != null) {
      return blockingMove;
    }

    for (final index in _preferredCells) {
      if (board.canPlace(index)) {
        return index;
      }
    }

    throw StateError(GameDomainMessages.noMoveAvailable);
  }

  int? _immediateWinningMove(Board board, Player player) {
    for (final index in board.emptyCells) {
      final result = _rules.evaluate(board.place(player.cell, index));
      if (result case GameWin(winner: final winner) when winner == player) {
        return index;
      }
    }

    return null;
  }
}
