import '../entities/board.dart';
import '../entities/player.dart';

abstract interface class CpuStrategy {
  int chooseMove(Board board, Player player);
}
