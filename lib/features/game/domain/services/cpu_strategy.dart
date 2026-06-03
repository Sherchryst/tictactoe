import 'package:tictactoe/features/game/domain/entities/board.dart';
import 'package:tictactoe/features/game/domain/entities/player.dart';

abstract interface class CpuStrategy {
  int chooseMove(Board board, Player player);
}
