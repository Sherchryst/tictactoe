import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tictactoe/core/design_system/theme/app_palette.dart';
import 'package:tictactoe/core/design_system/theme/app_theme.dart';
import 'package:tictactoe/core/di/audio_providers.dart';
import 'package:tictactoe/features/game/domain/entities/cpu_boss.dart';
import 'package:tictactoe/features/game/domain/entities/game_result.dart';
import 'package:tictactoe/features/game/domain/entities/game_session.dart';
import 'package:tictactoe/features/game/domain/entities/game_setup.dart';
import 'package:tictactoe/features/game/domain/entities/mark.dart';
import 'package:tictactoe/features/game/domain/services/no_mercy_run_rules.dart';
import 'package:tictactoe/features/game/presentation/widgets/dialogs/game_over_dialog.dart';
import 'package:tictactoe/l10n/app_localizations.dart';
import 'package:tictactoe/l10n/app_localizations_en.dart';

import '../../../../testing/mock_stubs.dart';
import '../../../../testing/mocks.mocks.dart';

void main() {
  final en = AppLocalizationsEn();

  Future<void> pumpDialog(WidgetTester tester, GameSession session) async {
    final audio = MockAudioController();
    stubAudioController(audio);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [audioControllerProvider.overrideWithValue(audio)],
        child: MaterialApp(
          theme: AppTheme.dark(),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: GameOverDialog(session: session),
        ),
      ),
    );
  }

  testWidgets('No Mercy boss victory offers home and next boss', (
    tester,
  ) async {
    await pumpDialog(tester, _noMercyHumanWin(CpuBossId.radahn));

    expect(find.text(en.goHomeAction), findsOneWidget);
    expect(find.text(en.nextBossAction), findsOneWidget);
    expect(find.text(en.playAgainAction), findsNothing);
  });

  testWidgets('next boss action returns the next boss choice', (tester) async {
    final audio = MockAudioController();
    stubAudioController(audio);
    GameOverChoice? choice;

    await tester.pumpWidget(
      ProviderScope(
        overrides: [audioControllerProvider.overrideWithValue(audio)],
        child: MaterialApp(
          theme: AppTheme.dark(),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return TextButton(
                  onPressed: () async {
                    choice = await GameOverDialog.show(
                      context: context,
                      session: _noMercyHumanWin(CpuBossId.radahn),
                    );
                  },
                  child: const Text('open'),
                );
              },
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    await tester.tap(find.text(en.nextBossAction));
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();

    expect(choice, GameOverChoice.nextBoss);
  });

  testWidgets('final No Mercy victory offers new game and title screen', (
    tester,
  ) async {
    await pumpDialog(
      tester,
      _noMercyHumanWin(CpuBossId.malenia, noMercyCycle: maxNoMercyCycle),
    );

    expect(find.text(en.goHomeAction), findsOneWidget);
    expect(find.text(en.newGamePlusAction), findsOneWidget);
    expect(_fontFamilyFor(en.newGamePlusAction, '+'), AppPalette.serifFont);
    expect(find.text(en.nextBossAction), findsNothing);
    expect(find.text(en.playAgainAction), findsNothing);
    expect(find.text(en.creditsBarrierLabel), findsNothing);
  });

  testWidgets('Malenia victory offers New Game Plus instead of next boss', (
    tester,
  ) async {
    await pumpDialog(tester, _noMercyHumanWin(CpuBossId.malenia));

    expect(find.text(en.goHomeAction), findsOneWidget);
    expect(find.text(en.newGamePlusAction), findsOneWidget);
    expect(find.text(en.nextBossAction), findsNothing);
    expect(find.text(en.playAgainAction), findsNothing);
  });

  testWidgets(
    'final credits actions return new game and title screen choices',
    (tester) async {
      final audio = MockAudioController();
      stubAudioController(audio);
      GameOverChoice? choice;

      Future<void> pumpHost() async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [audioControllerProvider.overrideWithValue(audio)],
            child: MaterialApp(
              theme: AppTheme.dark(),
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              home: Scaffold(
                body: Builder(
                  builder: (context) {
                    return TextButton(
                      onPressed: () async {
                        choice = await GameOverDialog.show(
                          context: context,
                          session: _noMercyHumanWin(
                            CpuBossId.malenia,
                            noMercyCycle: maxNoMercyCycle,
                          ),
                        );
                      },
                      child: const Text('open'),
                    );
                  },
                ),
              ),
            ),
          ),
        );
      }

      await pumpHost();
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      await tester.tap(find.text(en.newGamePlusAction));
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();

      expect(choice, GameOverChoice.newGamePlus);

      choice = null;
      await pumpHost();
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      await tester.tap(find.text(en.goHomeAction));
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();

      expect(choice, GameOverChoice.titleScreen);
    },
  );

  testWidgets('Malenia victory dialog does not inline the rolling credits', (
    tester,
  ) async {
    await pumpDialog(tester, _noMercyHumanWin(CpuBossId.malenia));

    expect(find.text(en.creditsBarrierLabel), findsNothing);
    expect(find.textContaining(en.creditsMusicRecusants), findsNothing);
    expect(find.textContaining(en.creditsDesignerName), findsNothing);
  });

  testWidgets('non-Malenia victories do not show the miniature credits', (
    tester,
  ) async {
    await pumpDialog(tester, _noMercyHumanWin(CpuBossId.radahn));

    expect(find.text(en.creditsBarrierLabel), findsNothing);
    expect(find.textContaining(en.creditsDesignerName), findsNothing);
  });
}

GameSession _noMercyHumanWin(CpuBossId bossId, {int noMercyCycle = 0}) {
  return GameSession.newGame(
    GameSetup.noMercy(bossId, noMercyCycle: noMercyCycle),
  ).copyWith(
    result: const GameResult.win(winner: Mark.x, winningCells: [0, 1, 2]),
  );
}

String? _fontFamilyFor(String label, String character) {
  final text = find.text(label).evaluate().single.widget as Text;
  final span = text.textSpan! as TextSpan;

  for (final child in span.children ?? const <InlineSpan>[]) {
    if (child is TextSpan && child.text == character) {
      return child.style?.fontFamily;
    }
  }

  return null;
}
