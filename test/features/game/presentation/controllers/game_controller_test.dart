import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mockito/mockito.dart';
import 'package:tictactoe/core/audio/domain/entities/music_track.dart';
import 'package:tictactoe/core/di/audio_providers.dart';
import 'package:tictactoe/core/di/game_dependencies.dart';
import 'package:tictactoe/core/di/storage_providers.dart';
import 'package:tictactoe/features/game/domain/entities/boss_pattern.dart';
import 'package:tictactoe/features/game/domain/entities/cpu_boss.dart';
import 'package:tictactoe/features/game/domain/entities/game_result.dart';
import 'package:tictactoe/features/game/domain/entities/game_session.dart';
import 'package:tictactoe/features/game/domain/entities/game_setup.dart';
import 'package:tictactoe/features/game/domain/entities/mark.dart';
import 'package:tictactoe/features/game/domain/services/boss_pattern_catalog.dart';
import 'package:tictactoe/features/game/domain/services/cpu_strategy.dart';
import 'package:tictactoe/features/game/domain/services/cpu_strategy_resolver.dart';
import 'package:tictactoe/features/game/presentation/controllers/game_controller.dart';
import 'package:tictactoe/features/game/presentation/controllers/game_timing.dart';
import 'package:tictactoe/features/game/presentation/controllers/game_view_state.dart';
import 'package:tictactoe/features/game/presentation/controllers/no_mercy_run_status.dart';
import 'package:tictactoe/features/game/presentation/controllers/scoreboard_controller.dart';

import '../../../../testing/cpu_strategy_stubs.dart';
import '../../../../testing/in_memory_key_value_storage.dart';
import '../../../../testing/mock_stubs.dart';
import '../../../../testing/mocks.mocks.dart';
import '../../../../testing/provider_container_factory.dart';

void main() {
  ProviderContainer createContainer({
    required InMemoryKeyValueStorage storage,
    CpuStrategy? strategy,
    MockAudioController? audioController,
    GameTiming timing = const GameTiming.immediate(),
  }) {
    final audio = audioController ?? MockAudioController();
    stubAudioController(audio);

    return createTestContainer(
      registerTearDown: addTearDown,
      overrides: [
        audioControllerProvider.overrideWithValue(audio),
        gameTimingProvider.overrideWithValue(timing),
        keyValueStorageProvider.overrideWithValue(storage),
        if (strategy != null)
          cpuStrategyResolverProvider.overrideWithValue(
            CpuStrategyResolver(
              guidedStrategy: strategy,
              noMercyStrategy: strategy,
            ),
          ),
      ],
    );
  }

  Future<void> settleTurn(ProviderContainer container) async {
    await container.pump();
  }

  Future<void> defeatBoss(
    ProviderContainer container,
    BossPattern pattern,
  ) async {
    for (final move in pattern.humanMoves.take(4)) {
      await container.read(gameControllerProvider.notifier).playCell(move);
    }
    await container
        .read(gameControllerProvider.notifier)
        .playCell(pattern.humanMoves.last);
  }

  test('starts a local duel with a clean state', () async {
    final container = createContainer(storage: InMemoryKeyValueStorage());

    await container.read(gameControllerProvider.notifier).startLocalDuel();

    final state = container.read(gameControllerProvider);
    expect(state.session.mode, GameMode.localDuel);
    expect(state.phase, GameViewPhase.awaitingHumanMove);
    expect(state.session.currentMark, Mark.x);
  });

  test('non-boss fights use Recusants music', () async {
    final audio = MockAudioController();
    final container = createContainer(
      storage: InMemoryKeyValueStorage(),
      audioController: audio,
    );

    await container.read(gameControllerProvider.notifier).startLocalDuel();
    verify(audio.playTrack(MusicTrack.recusants)).called(1);

    clearInteractions(audio);
    await container.read(gameControllerProvider.notifier).startGuidedTrial();
    verify(audio.playTrack(MusicTrack.recusants)).called(1);
  });

  test('No Mercy fights keep boss music', () async {
    final audio = MockAudioController();
    final container = createContainer(
      storage: InMemoryKeyValueStorage(),
      audioController: audio,
    );

    await container.read(gameControllerProvider.notifier).startNoMercyRun();

    verify(audio.playTrack(MusicTrack.radahn)).called(1);
    verifyNever(audio.playTrack(MusicTrack.recusants));
  });

  test('ignores taps outside awaitingHumanMove', () async {
    final container = createContainer(
      storage: InMemoryKeyValueStorage(),
      strategy: QueueCpuStrategy([8]),
    );

    await container.read(gameControllerProvider.notifier).startGuidedTrial();
    final firstMove = container
        .read(gameControllerProvider.notifier)
        .playCell(0);
    unawaited(container.read(gameControllerProvider.notifier).playCell(1));

    expect(
      container.read(gameControllerProvider).phase,
      isNot(GameViewPhase.awaitingHumanMove),
    );

    await firstMove;
    await settleTurn(container);
    final session = container.read(gameControllerProvider).session;
    expect(session.humanMoves, [0]);
    expect(session.board.markAt(1), isNull);
  });

  test(
    'restarting cancels a delayed CPU turn from the previous session',
    () async {
      final strategy = MockCpuStrategy();
      stubCpuStrategy(strategy, move: 8);
      final container = createContainer(
        storage: InMemoryKeyValueStorage(),
        strategy: strategy,
        timing: const GameTiming(
          cpuThinking: Duration(milliseconds: 1),
          markReveal: Duration.zero,
          roundOver: Duration.zero,
        ),
      );

      await container.read(gameControllerProvider.notifier).startGuidedTrial();
      final previousTurn = container
          .read(gameControllerProvider.notifier)
          .playCell(0);
      await Future<void>.delayed(Duration.zero);
      await container.pump();

      expect(
        container.read(gameControllerProvider).phase,
        GameViewPhase.cpuThinking,
      );

      await container.read(gameControllerProvider.notifier).startLocalDuel();
      await Future<void>.delayed(const Duration(milliseconds: 5));
      await previousTurn;
      await settleTurn(container);

      final state = container.read(gameControllerProvider);
      expect(state.session.mode, GameMode.localDuel);
      expect(state.session.board.cells.every((mark) => mark == null), isTrue);
      expect(state.phase, GameViewPhase.awaitingHumanMove);
      verifyNever(strategy.chooseMove(any));
    },
  );

  test('guided wins do not record No Mercy score', () async {
    final storage = InMemoryKeyValueStorage();
    final container = createContainer(
      storage: storage,
      strategy: QueueCpuStrategy([3, 5]),
    );

    await container.read(gameControllerProvider.notifier).startGuidedTrial();
    await container.read(gameControllerProvider.notifier).playCell(0);
    await container.read(gameControllerProvider.notifier).playCell(1);
    await container.read(gameControllerProvider.notifier).playCell(2);

    final game = container.read(gameControllerProvider);
    final scoreboard = await container.read(
      scoreboardControllerProvider.future,
    );

    expect(
      game.session.result,
      const GameResult.win(winner: Mark.x, winningCells: [0, 1, 2]),
    );
    expect(game.hasRecordedOutcome, isFalse);
    expect(scoreboard.playedGames, 0);
  });

  test('No Mercy records a boss defeat and persists the run', () async {
    final storage = InMemoryKeyValueStorage();
    final container = createContainer(storage: storage);

    await container.read(gameControllerProvider.notifier).startNoMercyRun();
    await defeatBoss(container, BossPatterns.radahn);

    final game = container.read(gameControllerProvider);
    final scoreboard = await container.read(
      scoreboardControllerProvider.future,
    );
    final savedRun = await container.read(loadNoMercyRunProvider).call();

    expect(game.session.bossId, CpuBossId.radahn);
    expect(game.session.participantOutcome, GameOutcome.humanWin);
    expect(game.hasRecordedOutcome, isTrue);
    expect(scoreboard.radahn.humanWins, 1);
    expect(await container.read(noMercyRunExistsProvider.future), isTrue);
    expect(savedRun?.bossId, CpuBossId.mohg);
    expect(savedRun?.noMercyCycle, 0);
    expect(savedRun?.result.isOngoing, isTrue);

    final continued = await container
        .read(gameControllerProvider.notifier)
        .continueNoMercyRun();
    final continuedGame = container.read(gameControllerProvider);
    expect(continued, isTrue);
    expect(continuedGame.session.bossId, CpuBossId.mohg);
    expect(continuedGame.session.noMercyCycle, 0);
  });

  test(
    'restarting No Mercy clears only progress and keeps the record',
    () async {
      final storage = InMemoryKeyValueStorage();
      final container = createContainer(storage: storage);

      await container.read(gameControllerProvider.notifier).startNoMercyRun();
      await defeatBoss(container, BossPatterns.radahn);

      await container.read(gameControllerProvider.notifier).restartNoMercyRun();

      final savedRun = await container.read(loadNoMercyRunProvider).call();
      final scoreboard = await container.read(
        scoreboardControllerProvider.future,
      );

      expect(savedRun?.bossId, CpuBossId.radahn);
      expect(savedRun?.noMercyCycle, 0);
      expect(savedRun?.board.cells.every((mark) => mark == null), isTrue);
      expect(savedRun?.humanMoves, isEmpty);
      expect(savedRun?.cpuMoves, isEmpty);
      expect(savedRun?.weaknessBroken, isFalse);
      expect(scoreboard.tarnishedRecord.humanWins, 1);
      expect(scoreboard.tarnishedRecord.attempts, 1);
    },
  );

  test('No Mercy advances to the next boss after a boss defeat', () async {
    final storage = InMemoryKeyValueStorage();
    final container = createContainer(storage: storage);

    await container.read(gameControllerProvider.notifier).startNoMercyRun();
    await defeatBoss(container, BossPatterns.radahn);

    final advanced = await container
        .read(gameControllerProvider.notifier)
        .advanceNoMercyRun();

    final game = container.read(gameControllerProvider);
    expect(advanced, isTrue);
    expect(game.session.bossId, CpuBossId.mohg);
    expect(game.session.noMercyCycle, 0);
    expect(game.session.result.isOngoing, isTrue);
    expect(game.phase, GameViewPhase.awaitingHumanMove);
  });

  test('No Mercy enters NG+1 after Malenia is defeated', () async {
    final storage = InMemoryKeyValueStorage();
    final container = createContainer(storage: storage);

    await container
        .read(saveNoMercyRunProvider)
        .call(GameSession.newGame(GameSetup.noMercy(CpuBossId.malenia)));
    await container.read(gameControllerProvider.notifier).continueNoMercyRun();
    await defeatBoss(container, BossPatterns.malenia);

    final advanced = await container
        .read(gameControllerProvider.notifier)
        .advanceNoMercyRun();

    final game = container.read(gameControllerProvider);
    final savedRun = await container.read(loadNoMercyRunProvider).call();
    expect(advanced, isTrue);
    expect(game.session.bossId, CpuBossId.radahn);
    expect(game.session.noMercyCycle, 1);
    expect(savedRun?.bossId, CpuBossId.radahn);
    expect(savedRun?.noMercyCycle, 1);
  });

  test('continue restores a saved No Mercy run', () async {
    final storage = InMemoryKeyValueStorage();
    final firstContainer = createContainer(storage: storage);
    await firstContainer
        .read(gameControllerProvider.notifier)
        .startNoMercyRun();
    firstContainer.dispose();

    final secondContainer = createContainer(storage: storage);
    final continued = await secondContainer
        .read(gameControllerProvider.notifier)
        .continueNoMercyRun();

    final state = secondContainer.read(gameControllerProvider);
    expect(continued, isTrue);
    expect(state.session.mode, GameMode.noMercyRun);
    expect(state.session.bossId, CpuBossId.radahn);
    expect(state.phase, GameViewPhase.awaitingHumanMove);
  });
}
