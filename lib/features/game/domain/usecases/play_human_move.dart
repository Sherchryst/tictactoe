import 'package:tictactoe/features/game/domain/entities/game_session.dart';
import 'package:tictactoe/features/game/domain/usecases/play_cpu_turn.dart';
import 'package:tictactoe/features/game/domain/usecases/play_move.dart';

final class PlayHumanMove {
  PlayHumanMove({
    PlayMove playMove = const PlayMove(),
    PlayCpuTurn? playCpuTurn,
  }) : _playMove = playMove,
       _playCpuTurn = playCpuTurn ?? PlayCpuTurn(playMove: playMove);

  final PlayMove _playMove;
  final PlayCpuTurn _playCpuTurn;

  GameSession call(GameSession session, int cellIndex) {
    if (!session.canHumanPlay) {
      return session;
    }

    final afterHuman = _playMove(session, session.currentPlayer, cellIndex);
    if (afterHuman == session) {
      return session;
    }

    return _playCpuTurn(afterHuman);
  }
}
