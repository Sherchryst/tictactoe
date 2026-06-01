import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/game/presentation/pages/game_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/settings/presentation/pages/settings_page.dart';
import 'app_routes.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    routes: [
      GoRoute(
        path: AppRoutes.homePath,
        builder: (context, state) => const HomePage(),
        routes: [
          GoRoute(
            path: AppRoutes.settingsPath,
            builder: (context, state) => const SettingsPage(),
          ),
          GoRoute(
            path: AppRoutes.gamePath,
            builder: (context, state) => const GamePage(),
          ),
        ],
      ),
    ],
  );
});
