import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tictactoe/core/design_system/theme/app_theme.dart';
import 'package:tictactoe/core/di/audio_providers.dart';
import 'package:tictactoe/core/di/storage_providers.dart';
import 'package:tictactoe/core/router/app_routes.dart';
import 'package:tictactoe/features/game/domain/entities/boss_pattern.dart';
import 'package:tictactoe/features/game/domain/entities/game_result.dart';
import 'package:tictactoe/features/game/domain/entities/game_session.dart';
import 'package:tictactoe/features/game/domain/entities/game_setup.dart';
import 'package:tictactoe/features/game/domain/entities/mark.dart';
import 'package:tictactoe/features/game/domain/services/boss_pattern_catalog.dart';
import 'package:tictactoe/features/game/presentation/controllers/game_controller.dart';
import 'package:tictactoe/features/game/presentation/controllers/game_timing.dart';
import 'package:tictactoe/features/game/presentation/controllers/game_view_state.dart';
import 'package:tictactoe/features/game/presentation/navigation/game_route_guard.dart';
import 'package:tictactoe/features/game/presentation/pages/game_page.dart';
import 'package:tictactoe/features/game/presentation/widgets/game_board.dart';
import 'package:tictactoe/l10n/app_localizations.dart';

import '../../../../testing/in_memory_key_value_storage.dart';
import '../../../../testing/mock_stubs.dart';
import '../../../../testing/mocks.mocks.dart';
import '../../../../testing/provider_container_factory.dart';

const _homeRouteLabel = 'home-route';

void main() {
  ProviderContainer createContainer() {
    final audio = MockAudioController();
    stubAudioController(audio);

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

  Future<void> pumpGameRoute(
    WidgetTester tester,
    ProviderContainer container,
  ) async {
    final router = GoRouter(
      initialLocation: AppRoutes.gameLocation,
      routes: [
        GoRoute(
          path: AppRoutes.gamePath,
          builder: (context, state) => const GamePage(),
        ),
        GoRoute(
          path: AppRoutes.homePath,
          builder: (context, state) {
            return const Scaffold(body: Text(_homeRouteLabel));
          },
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
  }

  test('route policy rejects direct entry on a finished round', () {
    final finishedState = GameViewState(
      session: GameSession.newGame(GameSetup.guidedTrial()).copyWith(
        result: const GameResult.win(winner: Mark.x, winningCells: [0, 1, 2]),
      ),
      phase: GameViewPhase.roundOver,
      hasPreparedSession: true,
    );

    expect(
      GameRouteAccessPolicy.shouldLeaveGameRoute(
        state: finishedState,
        enteredWithPlayableRound: false,
      ),
      isTrue,
    );
    expect(
      GameRouteAccessPolicy.shouldLeaveGameRoute(
        state: finishedState,
        enteredWithPlayableRound: true,
      ),
      isFalse,
    );
  });

  test('route policy rejects direct entry before a session is prepared', () {
    expect(
      GameRouteAccessPolicy.shouldLeaveGameRoute(
        state: GameViewState.initial(),
        enteredWithPlayableRound: true,
      ),
      isTrue,
    );
  });

  testWidgets('redirects away from game route without a prepared session', (
    tester,
  ) async {
    final container = createContainer();

    await pumpGameRoute(tester, container);
    await tester.pump();
    await tester.pumpAndSettle();

    expect(find.text(_homeRouteLabel), findsOneWidget);
    expect(find.byType(GameBoard), findsNothing);
  });

  testWidgets('redirects away from a finished boss fight opened from history', (
    tester,
  ) async {
    final container = createContainer();
    await container.read(gameControllerProvider.notifier).startNoMercyRun();
    await defeatBoss(container, BossPatterns.radahn);

    expect(
      container.read(gameControllerProvider).session.result.isOngoing,
      false,
    );

    await pumpGameRoute(tester, container);
    await tester.pump();
    await tester.pumpAndSettle();

    expect(find.text(_homeRouteLabel), findsOneWidget);
    expect(find.byType(GameBoard), findsNothing);
  });
}
