import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tictactoe/core/design_system/theme/app_palette.dart';
import 'package:tictactoe/core/design_system/theme/app_theme.dart';
import 'package:tictactoe/core/di/audio_providers.dart';
import 'package:tictactoe/core/preferences/application/controllers/app_preferences_controller.dart';
import 'package:tictactoe/core/preferences/presentation/app_locale_preference_mapper.dart';
import 'package:tictactoe/core/router/app_router.dart';
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
    ref.watch(audioPreferencesProvider);

    final router = ref.watch(appRouterProvider);
    final preferences = ref.watch(appPreferencesControllerProvider);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: _systemOverlay,
      child: MaterialApp.router(
        onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
        debugShowCheckedModeBanner: false,
        darkTheme: AppTheme.dark(),
        locale: preferences.when(
          data: (preferences) => preferences.localePreference.locale,
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
