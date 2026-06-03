import 'package:tictactoe/features/game/domain/entities/game_setup.dart';
import 'package:tictactoe/features/game/domain/services/cpu_strategy.dart';
import 'package:tictactoe/features/game/domain/services/minimax_cpu_strategy.dart';
import 'package:tictactoe/features/game/domain/services/random_cpu_strategy.dart';

final class CpuStrategyResolver {
  CpuStrategyResolver({CpuStrategy? easyStrategy, CpuStrategy? hardStrategy})
    : _easyStrategy = easyStrategy ?? RandomCpuStrategy(),
      _hardStrategy = hardStrategy ?? const MinimaxCpuStrategy();

  final CpuStrategy _easyStrategy;
  final CpuStrategy _hardStrategy;

  CpuStrategy resolve(GameDifficulty difficulty) {
    return switch (difficulty) {
      GameDifficulty.easy => _easyStrategy,
      GameDifficulty.hard => _hardStrategy,
    };
  }
}
