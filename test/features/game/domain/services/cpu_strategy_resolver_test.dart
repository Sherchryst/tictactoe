import 'package:flutter_test/flutter_test.dart';
import 'package:tictactoe/features/game/domain/entities/game_setup.dart';
import 'package:tictactoe/features/game/domain/services/cpu_strategy_resolver.dart';
import 'package:tictactoe/features/game/domain/services/minimax_cpu_strategy.dart';
import 'package:tictactoe/features/game/domain/services/random_cpu_strategy.dart';

import '../../../../testing/mocks.mocks.dart';

void main() {
  group('CpuStrategyResolver', () {
    test('returns the easy strategy for easy difficulty', () {
      final resolver = CpuStrategyResolver();

      expect(resolver.resolve(GameDifficulty.easy), isA<RandomCpuStrategy>());
    });

    test('returns the minimax strategy for hard difficulty', () {
      final resolver = CpuStrategyResolver();

      expect(resolver.resolve(GameDifficulty.hard), isA<MinimaxCpuStrategy>());
    });

    test('honors easy strategy overrides', () {
      final injected = MockCpuStrategy();
      final resolver = CpuStrategyResolver(easyStrategy: injected);

      expect(resolver.resolve(GameDifficulty.easy), same(injected));
    });

    test('honors hard strategy overrides', () {
      final injected = MockCpuStrategy();
      final resolver = CpuStrategyResolver(hardStrategy: injected);

      expect(resolver.resolve(GameDifficulty.hard), same(injected));
    });
  });
}
