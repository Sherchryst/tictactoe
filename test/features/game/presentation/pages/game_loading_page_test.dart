import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tictactoe/core/di/audio_providers.dart';
import 'package:tictactoe/features/game/presentation/pages/game_loading_page.dart';
import 'package:tictactoe/features/game/presentation/widgets/loading/loading_beam.dart';
import 'package:tictactoe/l10n/app_localizations.dart';
import 'package:tictactoe/l10n/app_localizations_en.dart';

import '../../../../testing/mock_stubs.dart';
import '../../../../testing/mocks.mocks.dart';

void main() {
  final en = AppLocalizationsEn();

  testWidgets('renders the game loading presentation', (tester) async {
    final audio = MockAudioController();
    stubAudioController(audio);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [audioControllerProvider.overrideWithValue(audio)],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: GameLoadingPage(),
        ),
      ),
    );
    await tester.pump();

    expect(find.text(en.loadingTitle), findsOneWidget);
    expect(find.byType(LoadingBeam), findsOneWidget);
  });
}
