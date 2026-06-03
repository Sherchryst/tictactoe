import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tictactoe/app/di/game_dependencies.dart';
import 'package:tictactoe/core/storage/in_memory_key_value_storage.dart';
import 'package:tictactoe/features/game/domain/entities/cell.dart';
import 'package:tictactoe/features/game/domain/entities/game_setup.dart';
import 'package:tictactoe/features/game/domain/services/cpu_strategy.dart';
import 'package:tictactoe/features/game/domain/services/cpu_strategy_resolver.dart';
import 'package:tictactoe/features/game/presentation/controllers/game_controller.dart';
import 'package:tictactoe/features/game/presentation/settings/controllers/settings_controller.dart';

import 'package:tictactoe/testing/cpu_strategy_stubs.dart';
import 'package:tictactoe/testing/provider_container_factory.dart';

void main() {
  ProviderContainer createContainer({
    required InMemoryKeyValueStorage storage,
    CpuStrategy? easyStrategy,
  }) {
    return createTestContainer(
      registerTearDown: addTearDown,
      overrides: [
        keyValueStorageProvider.overrideWithValue(storage),
        if (easyStrategy != null)
          cpuStrategyResolverProvider.overrideWithValue(
            CpuStrategyResolver(
              easyStrategy: easyStrategy,
              hardStrategy: easyStrategy,
            ),
          ),
      ],
    );
  }

  test('starts a game with a setup snapshot', () {
    final container = createContainer(storage: InMemoryKeyValueStorage());
    const setup = GameSetup(mode: GameMode.humanVsHuman);

    container.read(gameControllerProvider.notifier).startGame(setup);

    final state = container.read(gameControllerProvider);
    expect(state.session.mode, GameMode.humanVsHuman);
    expect(state.session.difficulty, GameDifficulty.hard);
  });

  test('plays a human turn and records a finished game once', () async {
    final storage = InMemoryKeyValueStorage();
    final container = createContainer(
      storage: storage,
      easyStrategy: QueueCpuStrategy([8, 7]),
    );
    await container.read(settingsControllerProvider.future);

    container
        .read(gameControllerProvider.notifier)
        .startGame(const GameSetup(difficulty: GameDifficulty.easy));
    container.read(gameControllerProvider.notifier).playCell(0);
    container.read(gameControllerProvider.notifier).playCell(1);
    container.read(gameControllerProvider.notifier).playCell(2);
    await Future<void>.delayed(Duration.zero);
    await container.pump();

    final game = container.read(gameControllerProvider);
    final settingsState = container
        .read(settingsControllerProvider)
        .requireValue;

    expect(game.session.board.cellAt(0), Cell.human);
    expect(game.session.board.cellAt(8), Cell.cpu);
    expect(game.hasRecordedOutcome, isTrue);
    expect(settingsState.scoreboard.humanWins, 1);
  });
}
