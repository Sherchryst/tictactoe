import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tictactoe/core/design_system/theme/app_theme.dart';
import 'package:tictactoe/core/di/audio_providers.dart';
import 'package:tictactoe/core/di/storage_providers.dart';
import 'package:tictactoe/core/router/app_routes.dart';
import 'package:tictactoe/features/game/domain/entities/boss_pattern.dart';
import 'package:tictactoe/features/game/domain/entities/cpu_boss.dart';
import 'package:tictactoe/features/game/domain/entities/game_result.dart';
import 'package:tictactoe/features/game/domain/entities/game_session.dart';
import 'package:tictactoe/features/game/domain/entities/game_setup.dart';
import 'package:tictactoe/features/game/domain/entities/mark.dart';
import 'package:tictactoe/features/game/domain/services/boss_pattern_catalog.dart';
import 'package:tictactoe/features/game/presentation/audio/game_audio_effects.dart';
import 'package:tictactoe/features/game/presentation/controllers/game_controller.dart';
import 'package:tictactoe/features/game/presentation/controllers/game_timing.dart';
import 'package:tictactoe/features/game/presentation/dialogs/ending_credits_roll.dart';
import 'package:tictactoe/features/game/presentation/flows/game_over_sequence.dart';
import 'package:tictactoe/l10n/app_localizations.dart';
import 'package:tictactoe/l10n/app_localizations_en.dart';

import '../../../../testing/in_memory_key_value_storage.dart';
import '../../../../testing/mock_stubs.dart';
import '../../../../testing/mocks.mocks.dart';
import '../../../../testing/provider_container_factory.dart';

void main() {
  final en = AppLocalizationsEn();

  ProviderContainer createContainer(MockAudioController audio) {
    return createTestContainer(
      registerTearDown: addTearDown,
      overrides: [
        audioControllerProvider.overrideWithValue(audio),
        gameTimingProvider.overrideWithValue(const GameTiming.immediate()),
        keyValueStorageProvider.overrideWithValue(InMemoryKeyValueStorage()),
      ],
    );
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

  testWidgets('Malenia victory rolls credits before New Game Plus', (
    tester,
  ) async {
    final audio = MockAudioController();
    stubAudioController(audio);
    late Future<void> sequence;
    late GoRouter router;

    router = GoRouter(
      initialLocation: AppRoutes.gameLocation,
      routes: [
        GoRoute(
          path: AppRoutes.gamePath,
          builder: (context, state) {
            return Consumer(
              builder: (context, ref, _) {
                return Scaffold(
                  body: TextButton(
                    onPressed: () {
                      sequence = runGameOverSequence(
                        context: context,
                        ref: ref,
                        audioEffects: GameAudioEffects(audio),
                        session: _noMercyHumanWin(CpuBossId.malenia),
                      );
                    },
                    child: const Text('finish round'),
                  ),
                );
              },
            );
          },
        ),
        GoRoute(
          path: AppRoutes.titlePath,
          builder: (context, state) => const Scaffold(body: Text('title')),
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [audioControllerProvider.overrideWithValue(audio)],
        child: MaterialApp.router(
          theme: AppTheme.dark(),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          routerConfig: router,
        ),
      ),
    );

    await tester.tap(find.text('finish round'));
    await tester.pump();
    await tester.pump(GameAudioEffects.noMercyVictoryBannerDelay);
    await tester.pump();
    await tester.pump(GameAudioEffects.soloVictorySoundDuration);
    await tester.pump();

    expect(find.textContaining(en.creditsDesignerName), findsOneWidget);
    expect(find.text(en.newGamePlusAction), findsNothing);

    await tester.pump(
      EndingCreditsRoll.rollDuration + const Duration(milliseconds: 120),
    );
    await tester.pump();
    await tester.pumpAndSettle();

    expect(find.text(en.newGamePlusAction), findsOneWidget);
    expect(find.textContaining(en.creditsDesignerName), findsNothing);

    await tester.tap(find.text(en.goHomeAction));
    await tester.pumpAndSettle();
    await sequence;

    expect(find.text('title'), findsOneWidget);

    router.dispose();
  });

  testWidgets('next boss prepares the run before showing loading', (
    tester,
  ) async {
    final audio = MockAudioController();
    stubAudioController(audio);
    final container = createContainer(audio);
    await container.read(gameControllerProvider.notifier).startNoMercyRun();
    await defeatBoss(container, BossPatterns.radahn);

    final finishedSession = container.read(gameControllerProvider).session;
    late Future<void> sequence;
    final router = GoRouter(
      initialLocation: AppRoutes.gameLocation,
      routes: [
        GoRoute(
          path: AppRoutes.gamePath,
          builder: (context, state) {
            return Consumer(
              builder: (context, ref, _) {
                return Scaffold(
                  body: TextButton(
                    onPressed: () {
                      sequence = runGameOverSequence(
                        context: context,
                        ref: ref,
                        audioEffects: GameAudioEffects(audio),
                        session: finishedSession,
                      );
                    },
                    child: const Text('finish round'),
                  ),
                );
              },
            );
          },
        ),
        GoRoute(
          path: AppRoutes.gameLoadingPath,
          builder: (context, state) => const Scaffold(body: Text('loading')),
        ),
        GoRoute(
          path: AppRoutes.homePath,
          builder: (context, state) => const Scaffold(body: Text('home')),
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(
          theme: AppTheme.dark(),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          routerConfig: router,
        ),
      ),
    );

    await tester.tap(find.text('finish round'));
    await tester.pump();
    await tester.pump(GameAudioEffects.noMercyVictoryBannerDelay);
    await tester.pump();
    await tester.pump(GameAudioEffects.soloVictorySoundDuration);
    await tester.pumpAndSettle();

    await tester.tap(find.text(en.nextBossAction));
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();
    await sequence;

    final preparedSession = container.read(gameControllerProvider).session;
    expect(find.text('loading'), findsOneWidget);
    expect(preparedSession.bossId, CpuBossId.mohg);
    expect(preparedSession.result.isOngoing, isTrue);
  });
}

GameSession _noMercyHumanWin(CpuBossId bossId) {
  return GameSession.newGame(GameSetup.noMercy(bossId)).copyWith(
    result: const GameResult.win(winner: Mark.x, winningCells: [0, 1, 2]),
  );
}
