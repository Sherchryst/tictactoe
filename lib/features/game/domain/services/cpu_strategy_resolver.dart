import 'package:tictactoe/features/game/domain/entities/game_setup.dart';
import 'package:tictactoe/features/game/domain/services/boss_puzzle_cpu_strategy.dart';
import 'package:tictactoe/features/game/domain/services/cpu_strategy.dart';
import 'package:tictactoe/features/game/domain/services/random_cpu_strategy.dart';

final class CpuStrategyResolver {
  CpuStrategyResolver({
    CpuStrategy? guidedStrategy,
    CpuStrategy? noMercyStrategy,
  }) : _guidedStrategy = guidedStrategy ?? RandomCpuStrategy(),
       _noMercyStrategy = noMercyStrategy ?? const BossPuzzleCpuStrategy();

  final CpuStrategy _guidedStrategy;
  final CpuStrategy _noMercyStrategy;

  CpuStrategy resolve(GameMode mode) {
    return switch (mode) {
      GameMode.localDuel => _guidedStrategy,
      GameMode.guidedTrial => _guidedStrategy,
      GameMode.noMercyRun => _noMercyStrategy,
    };
  }
}
