import '../entities/game_difficulty.dart';
import '../entities/game_mode.dart';
import '../entities/game_result.dart';
import '../entities/game_session.dart';
import '../entities/player.dart';
import '../services/cpu_strategy.dart';
import '../services/game_rules.dart';
import '../services/minimax_cpu_strategy.dart';
import '../services/random_cpu_strategy.dart';
import '../services/tactical_cpu_strategy.dart';

final class PlayHumanMove {
  PlayHumanMove({
    GameRules rules = const GameRules(),
    CpuStrategy? easyStrategy,
    CpuStrategy? mediumStrategy,
    CpuStrategy? hardStrategy,
  }) : _rules = rules,
       _easyStrategy = easyStrategy ?? RandomCpuStrategy(),
       _mediumStrategy = mediumStrategy ?? const TacticalCpuStrategy(),
       _hardStrategy = hardStrategy ?? const MinimaxCpuStrategy();

  final GameRules _rules;
  final CpuStrategy _easyStrategy;
  final CpuStrategy _mediumStrategy;
  final CpuStrategy _hardStrategy;

  GameSession call(GameSession session, int cellIndex) {
    if (!session.canHumanPlay || !session.board.canPlace(cellIndex)) {
      return session;
    }

    final afterHumanMove = _play(session, session.currentPlayer, cellIndex);
    if (!afterHumanMove.result.isOngoing ||
        afterHumanMove.mode == GameMode.humanVsHuman) {
      return afterHumanMove;
    }

    final cpuStrategy = _strategyFor(afterHumanMove.difficulty);
    final cpuMove = cpuStrategy.chooseMove(afterHumanMove.board, Player.cpu);
    return _play(afterHumanMove, Player.cpu, cpuMove);
  }

  GameSession _play(GameSession session, Player player, int cellIndex) {
    final board = session.board.place(player.cell, cellIndex);
    final result = _rules.evaluate(board);

    return session.copyWith(
      board: board,
      currentPlayer: result is GameOngoing ? player.opponent : player,
      result: result,
    );
  }

  CpuStrategy _strategyFor(GameDifficulty difficulty) {
    return switch (difficulty) {
      GameDifficulty.easy => _easyStrategy,
      GameDifficulty.medium => _mediumStrategy,
      GameDifficulty.hard => _hardStrategy,
    };
  }
}
