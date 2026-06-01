import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/game/presentation/game_copy.dart';
import 'features/settings/presentation/controllers/settings_controller.dart';
import 'features/settings/presentation/mappers/theme_mode_mapper.dart';

class TicTacToeApp extends ConsumerWidget {
  const TicTacToeApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final settings = ref.watch(settingsControllerProvider);

    return MaterialApp.router(
      title: GameCopy.appTitle,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: settings.when(
        data: (state) =>
            themeModeFromPreference(state.settings.themePreference),
        error: (_, _) => ThemeMode.system,
        loading: () => ThemeMode.system,
      ),
      routerConfig: router,
    );
  }
}
