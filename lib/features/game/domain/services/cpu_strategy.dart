import 'package:tictactoe/features/game/domain/entities/game_session.dart';

abstract interface class CpuStrategy {
  int chooseMove(GameSession session);
}
