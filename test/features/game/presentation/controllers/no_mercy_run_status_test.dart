import 'package:flutter_test/flutter_test.dart';
import 'package:tictactoe/core/di/game_dependencies.dart';
import 'package:tictactoe/core/di/storage_providers.dart';
import 'package:tictactoe/features/game/domain/entities/cpu_boss.dart';
import 'package:tictactoe/features/game/domain/entities/game_result.dart';
import 'package:tictactoe/features/game/domain/entities/game_session.dart';
import 'package:tictactoe/features/game/domain/entities/game_setup.dart';
import 'package:tictactoe/features/game/presentation/controllers/no_mercy_run_status.dart';
import 'package:tictactoe/features/game/presentation/controllers/scoreboard_controller.dart';

import '../../../../testing/in_memory_key_value_storage.dart';
import '../../../../testing/provider_container_factory.dart';

void main() {
  test('is empty without saved run or unlocked credits', () async {
    final container = createTestContainer(
      registerTearDown: addTearDown,
      overrides: [
        keyValueStorageProvider.overrideWithValue(InMemoryKeyValueStorage()),
      ],
    );

    final status = await container.read(noMercyRunStatusProvider.future);

    expect(status.hasSavedRun, isFalse);
    expect(status.creditsUnlocked, isFalse);
  });

  test(
    'reports saved run and credits unlocked from No Mercy progress',
    () async {
      final container = createTestContainer(
        registerTearDown: addTearDown,
        overrides: [
          keyValueStorageProvider.overrideWithValue(InMemoryKeyValueStorage()),
        ],
      );

      await container
          .read(saveNoMercyRunProvider)
          .call(
            GameSession.newGame(
              GameSetup.noMercy(CpuBossId.radahn, noMercyCycle: 1),
            ),
          );
      container.invalidate(noMercyRunStatusProvider);

      final status = await container.read(noMercyRunStatusProvider.future);

      expect(status.hasSavedRun, isTrue);
      expect(status.creditsUnlocked, isTrue);
    },
  );

  test('unlocks credits from a recorded Malenia win', () async {
    final container = createTestContainer(
      registerTearDown: addTearDown,
      overrides: [
        keyValueStorageProvider.overrideWithValue(InMemoryKeyValueStorage()),
      ],
    );

    await container
        .read(scoreboardControllerProvider.notifier)
        .record(CpuBossId.malenia, GameOutcome.humanWin);
    container.invalidate(noMercyRunStatusProvider);

    final status = await container.read(noMercyRunStatusProvider.future);

    expect(status.hasSavedRun, isFalse);
    expect(status.creditsUnlocked, isTrue);
  });
}
