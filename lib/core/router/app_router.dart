import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tictactoe/core/audio/domain/entities/menu_sfx.dart';
import 'package:tictactoe/core/design_system/tokens/app_curves.dart';
import 'package:tictactoe/core/design_system/tokens/app_durations.dart';
import 'package:tictactoe/core/di/audio_providers.dart';
import 'package:tictactoe/core/router/app_routes.dart';
import 'package:tictactoe/features/game/domain/entities/game_setup.dart';
import 'package:tictactoe/features/game/presentation/controllers/game_controller.dart';
import 'package:tictactoe/features/game/presentation/dialogs/scoreboard_dialog.dart';
import 'package:tictactoe/features/game/presentation/pages/game_page.dart';
import 'package:tictactoe/features/settings/presentation/pages/settings_page.dart';
import 'package:tictactoe/features/shell/presentation/models/solo_challenge.dart';
import 'package:tictactoe/features/shell/presentation/pages/game_loading_page.dart';
import 'package:tictactoe/features/shell/presentation/pages/home_page.dart';
import 'package:tictactoe/features/shell/presentation/pages/splash_page.dart';
import 'package:tictactoe/features/shell/presentation/pages/title_page.dart';

part 'app_router.g.dart';

@Riverpod(keepAlive: true)
GoRouter appRouter(Ref ref) {
  return GoRouter(
    routes: [
      GoRoute(
        path: AppRoutes.splashPath,
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: AppRoutes.titlePath,
        pageBuilder: (context, state) {
          return _buildPageTransition(
            state: state,
            child: const TitlePage(),
            duration: AppDurations.routeTitle,
          );
        },
      ),
      GoRoute(
        path: AppRoutes.homePath,
        pageBuilder: (context, state) {
          return _buildPageTransition(
            state: state,
            child: HomePage(
              onStartLocalDuel: (context) {
                return _startGame(
                  context: context,
                  ref: ref,
                  setup: const GameSetup(mode: GameMode.humanVsHuman),
                );
              },
              onStartSoloChallenge: (context, challenge) {
                return _startGame(
                  context: context,
                  ref: ref,
                  setup: GameSetup(difficulty: _difficultyFor(challenge)),
                );
              },
              onShowScoreboard: ScoreboardDialog.show,
            ),
            duration: AppDurations.routeHome,
          );
        },
      ),
      GoRoute(
        path: AppRoutes.settingsPath,
        pageBuilder: (context, state) {
          return _buildPageTransition(
            state: state,
            child: SettingsPage(
              onBack: () => context.go(AppRoutes.homeLocation),
              onCategoryChanged: () {
                unawaited(
                  ref.read(audioControllerProvider).playMenuSfx(MenuSfx.select),
                );
              },
            ),
            duration: AppDurations.routeSettings,
          );
        },
      ),
      GoRoute(
        path: AppRoutes.gameLoadingPath,
        pageBuilder: (context, state) {
          return _buildPageTransition(
            state: state,
            child: const GameLoadingPage(),
            duration: AppDurations.routeLoading,
          );
        },
      ),
      GoRoute(
        path: AppRoutes.gamePath,
        pageBuilder: (context, state) {
          return _buildPageTransition(
            state: state,
            child: const GamePage(),
            duration: AppDurations.routeGame,
          );
        },
      ),
    ],
  );
}

Future<void> _startGame({
  required BuildContext context,
  required Ref ref,
  required GameSetup setup,
}) {
  ref.read(gameControllerProvider.notifier).startGame(setup);
  if (context.mounted) {
    context.go(AppRoutes.gameLoadingLocation);
  }

  return Future<void>.value();
}

GameDifficulty _difficultyFor(SoloChallenge challenge) {
  return switch (challenge) {
    SoloChallenge.guided => GameDifficulty.easy,
    SoloChallenge.noMercy => GameDifficulty.hard,
  };
}

CustomTransitionPage<void> _buildPageTransition({
  required GoRouterState state,
  required Widget child,
  required Duration duration,
}) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    transitionDuration: duration,
    reverseTransitionDuration: AppDurations.routeReverse,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final incoming = CurvedAnimation(
        parent: animation,
        curve: const Interval(0.08, 1, curve: AppCurves.standard),
        reverseCurve: AppCurves.standard,
      );
      final outgoing = Tween<double>(begin: 1, end: 0.92).animate(
        CurvedAnimation(parent: secondaryAnimation, curve: AppCurves.entrance),
      );

      return FadeTransition(
        opacity: outgoing,
        child: FadeTransition(opacity: incoming, child: child),
      );
    },
  );
}
