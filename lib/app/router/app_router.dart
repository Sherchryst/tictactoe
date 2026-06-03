import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:tictactoe/app/router/app_routes.dart';
import 'package:tictactoe/design_system/tokens/app_curves.dart';
import 'package:tictactoe/design_system/tokens/app_durations.dart';
import 'package:tictactoe/features/game/presentation/pages/game_loading_page.dart';
import 'package:tictactoe/features/game/presentation/pages/game_page.dart';
import 'package:tictactoe/features/game/presentation/pages/home_page.dart';
import 'package:tictactoe/features/game/presentation/pages/splash_page.dart';
import 'package:tictactoe/features/game/presentation/pages/title_page.dart';
import 'package:tictactoe/features/game/presentation/settings/pages/settings_page.dart';

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
            child: const HomePage(),
            duration: AppDurations.routeHome,
          );
        },
      ),
      GoRoute(
        path: AppRoutes.settingsPath,
        pageBuilder: (context, state) {
          return _buildPageTransition(
            state: state,
            child: const SettingsPage(),
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
