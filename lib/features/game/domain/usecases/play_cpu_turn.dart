import 'package:tictactoe/features/game/domain/entities/game_session.dart';
import 'package:tictactoe/features/game/domain/entities/game_setup.dart';
import 'package:tictactoe/features/game/domain/entities/player.dart';
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
    if (session.mode != GameMode.humanVsCpu ||
        !session.result.isOngoing ||
        session.currentPlayer != Player.cpu) {
      return session;
    }

    final strategy = _strategyResolver.resolve(session.difficulty);
    final cellIndex = strategy.chooseMove(session.board, Player.cpu);

    return _playMove(session, Player.cpu, cellIndex);
  }
}
