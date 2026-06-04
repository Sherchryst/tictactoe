import 'package:tictactoe/features/game/domain/entities/game_session.dart';
import 'package:tictactoe/features/game/domain/entities/game_setup.dart';
import 'package:tictactoe/features/game/domain/services/cpu_strategy_resolver.dart';
import 'package:tictactoe/features/game/domain/usecases/play_move.dart';

final class PlayCpuTurn {
  PlayCpuTurn({
    PlayMove playMove = const PlayMove(),
    CpuStrategyResolver? strategyResolver,
  }) : _playMove = playMove,
       _strategyResolver = strategyResolver ?? CpuStrategyResolver();

  final PlayMove _playMove;
  final CpuStrategyResolver _strategyResolver;

  GameSession call(GameSession session) {
    if (session.mode == GameMode.localDuel ||
        !session.result.isOngoing ||
        session.currentMark != session.cpuMark) {
      return session;
    }

    final strategy = _strategyResolver.resolve(session.mode);
    final cellIndex = strategy.chooseMove(session);

    final afterCpu = _playMove(session, session.cpuMark, cellIndex);
    if (afterCpu == session) {
      return session;
    }

    return afterCpu.copyWith(cpuMoves: [...session.cpuMoves, cellIndex]);
  }
}
