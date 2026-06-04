import 'package:flutter_test/flutter_test.dart';
import 'package:tictactoe/features/game/domain/entities/game_setup.dart';
import 'package:tictactoe/features/game/domain/services/boss_puzzle_cpu_strategy.dart';
import 'package:tictactoe/features/game/domain/services/cpu_strategy_resolver.dart';
import 'package:tictactoe/features/game/domain/services/random_cpu_strategy.dart';

import '../../../../testing/mocks.mocks.dart';

void main() {
  group('CpuStrategyResolver', () {
    test('returns guided strategy for guided and local modes', () {
      final resolver = CpuStrategyResolver();

      expect(resolver.resolve(GameMode.guidedTrial), isA<RandomCpuStrategy>());
      expect(resolver.resolve(GameMode.localDuel), isA<RandomCpuStrategy>());
    });

    test('returns boss puzzle strategy for No Mercy', () {
      final resolver = CpuStrategyResolver();

      expect(
        resolver.resolve(GameMode.noMercyRun),
        isA<BossPuzzleCpuStrategy>(),
      );
    });

    test('honors injected strategies', () {
      final guided = MockCpuStrategy();
      final noMercy = MockCpuStrategy();
      final resolver = CpuStrategyResolver(
        guidedStrategy: guided,
        noMercyStrategy: noMercy,
      );

      expect(resolver.resolve(GameMode.guidedTrial), same(guided));
      expect(resolver.resolve(GameMode.noMercyRun), same(noMercy));
    });
  });
}
