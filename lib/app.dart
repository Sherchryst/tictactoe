import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:tictactoe/app/di/audio_providers.dart';
import 'package:tictactoe/app/router/app_router.dart';
import 'package:tictactoe/design_system/theme/app_palette.dart';
import 'package:tictactoe/design_system/theme/app_theme.dart';
import 'package:tictactoe/features/game/domain/entities/app_preferences.dart';
import 'package:tictactoe/features/game/presentation/game_copy.dart';
import 'package:tictactoe/features/game/presentation/settings/controllers/settings_controller.dart';
import 'package:tictactoe/l10n/app_localizations.dart';

class TicTacToeApp extends ConsumerWidget {
  const TicTacToeApp({super.key});

  static const _systemOverlay = SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarBrightness: Brightness.dark,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: AppPalette.backgroundDeep,
    systemNavigationBarDividerColor: Colors.transparent,
    systemNavigationBarIconBrightness: Brightness.light,
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(audioSettingsProvider);

    final router = ref.watch(appRouterProvider);
    final settings = ref.watch(settingsControllerProvider);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: _systemOverlay,
      child: MaterialApp.router(
        title: GameCopy.appTitle,
        debugShowCheckedModeBanner: false,
        darkTheme: AppTheme.dark(),
        locale: settings.when(
          data: (state) => state.preferences.localePreference.locale,
          error: (_, _) => const Locale('en'),
          loading: () => const Locale('en'),
        ),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        themeMode: ThemeMode.dark,
        routerConfig: router,
      ),
    );
  }
}
