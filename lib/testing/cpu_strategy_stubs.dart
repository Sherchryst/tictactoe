import 'package:tictactoe/features/game/domain/entities/board.dart';
import 'package:tictactoe/features/game/domain/entities/player.dart';
import 'package:tictactoe/features/game/domain/services/cpu_strategy.dart';

final class QueueCpuStrategy implements CpuStrategy {
  QueueCpuStrategy(List<int> moves) : _moves = List.of(moves);

  final List<int> _moves;

  @override
  int chooseMove(Board board, Player player) {
    return _moves.removeAt(0);
  }
}
