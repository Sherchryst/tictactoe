import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tictactoe/app.dart';
import 'package:tictactoe/core/design_system/tokens/app_assets.dart';
import 'package:tictactoe/core/design_system/widgets/tic_tac_toe_title_logo.dart';
import 'package:tictactoe/core/di/storage_providers.dart';
import 'package:tictactoe/features/game/domain/entities/board.dart';
import 'package:tictactoe/features/game/domain/entities/game_result.dart';
import 'package:tictactoe/features/game/presentation/widgets/game_board.dart';
import 'package:tictactoe/l10n/app_localizations_en.dart';
import 'package:tictactoe/l10n/app_localizations_fr.dart';

import 'testing/in_memory_key_value_storage.dart';

void main() {
  final en = AppLocalizationsEn();
  final fr = AppLocalizationsFr();

  Future<void> pumpApp(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          keyValueStorageProvider.overrideWithValue(InMemoryKeyValueStorage()),
        ],
        child: const TicTacToeApp(),
      ),
    );
    await tester.pump();
  }

  Future<void> finishSplash(WidgetTester tester) async {
    await tester.pump(const Duration(milliseconds: 2350));
    await tester.pump();
  }

  Future<void> finishTitleIntro(WidgetTester tester) async {
    await finishSplash(tester);
    await tester.pump(const Duration(milliseconds: 700));
    await tester.pump();
    await tester.pump(const Duration(seconds: 2));
    await tester.pump();
    await tester.pump(const Duration(seconds: 5));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 900));
  }

  Future<void> enterHome(WidgetTester tester) async {
    await finishTitleIntro(tester);
    expect(find.text(en.touchScreenPrompt), findsOneWidget);

    await tester.tapAt(const Offset(400, 300));
    await tester.pump(const Duration(milliseconds: 900));
    await tester.pumpAndSettle();
  }

  Future<void> finishGameLoading(WidgetTester tester) async {
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    expect(find.text(en.loadingTitle, skipOffstage: false), findsOneWidget);

    await tester.pump(const Duration(seconds: 5));
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pump(const Duration(milliseconds: 800));
    await tester.pump(const Duration(milliseconds: 200));
  }

  testWidgets('opens on the title screen before home', (tester) async {
    await pumpApp(tester);

    expect(find.image(const AssetImage(AppAssets.sigil)), findsOneWidget);
    expect(find.text(en.touchScreenPrompt), findsNothing);

    await finishSplash(tester);

    expect(find.byType(TicTacToeTitleLogo), findsWidgets);
    expect(find.text(en.touchScreenPrompt), findsNothing);

    await tester.pump(const Duration(milliseconds: 700));
    await tester.pump();
    await tester.pump(const Duration(seconds: 2));
    await tester.pump();
    await tester.pump(const Duration(seconds: 4));
    expect(find.text(en.touchScreenPrompt), findsNothing);

    await tester.pump(const Duration(seconds: 1));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 900));

    expect(find.text(en.touchScreenPrompt), findsOneWidget);
  });

  testWidgets('shows the home actions and opens preferences', (tester) async {
    await pumpApp(tester);
    await enterHome(tester);

    expect(find.byType(TicTacToeTitleLogo), findsWidgets);
    expect(find.text(en.localGameAction), findsOneWidget);
    expect(find.text(en.aiGameAction), findsOneWidget);
    expect(find.text(en.scoreTitle), findsOneWidget);

    await tester.tap(find.text(en.settingsTitle));
    await tester.pumpAndSettle();

    expect(find.text(en.audioTitle), findsOneWidget);
    expect(find.text(en.languageTitle), findsOneWidget);
    expect(find.text(en.scoreTitle), findsNothing);
  });

  testWidgets('opens the score dialog from home', (tester) async {
    await pumpApp(tester);
    await enterHome(tester);

    await tester.tap(find.text(en.scoreTitle));
    await tester.pumpAndSettle();

    expect(find.text(en.recordTitle), findsOneWidget);
    expect(find.text(en.humanScoreLabel), findsOneWidget);
    expect(find.text(en.resetScoreAction), findsOneWidget);
  });

  testWidgets('changes the interface language from system settings', (
    tester,
  ) async {
    await pumpApp(tester);
    await enterHome(tester);

    await tester.tap(find.text(en.settingsTitle));
    await tester.pumpAndSettle();
    await tester.tap(find.text(en.languageTitle));
    await tester.pumpAndSettle();

    expect(find.text(en.englishLanguageLabel), findsOneWidget);
    expect(find.text(en.frenchLanguageLabel), findsOneWidget);
    expect(find.text(en.spanishLanguageLabel), findsOneWidget);
    expect(find.text(en.germanLanguageLabel), findsOneWidget);

    await tester.tap(find.text(en.frenchLanguageLabel));
    await tester.pumpAndSettle();

    expect(find.text(fr.languageTitle), findsOneWidget);
    expect(find.text(fr.systemHeaderTitle), findsOneWidget);
  });

  testWidgets('starts a local game in one tap', (tester) async {
    await pumpApp(tester);
    await enterHome(tester);

    await tester.tap(find.text(en.localGameAction));
    await finishGameLoading(tester);

    expect(find.text(en.humanVsHumanLabel), findsNothing);
    expect(find.text(en.humanTurnStatus), findsOneWidget);
    expect(find.text(en.cpuTurnStatus), findsOneWidget);

    final boardRect = tester.getRect(find.byType(GameBoard));
    final humanLabelRect = tester.getRect(find.text(en.humanTurnStatus));
    final cpuLabelRect = tester.getRect(find.text(en.cpuTurnStatus));

    expect(cpuLabelRect.bottom, lessThanOrEqualTo(boardRect.top));
    expect(humanLabelRect.top, greaterThanOrEqualTo(boardRect.bottom));

    await tester.tapAt(
      boardRect.topLeft + Offset(boardRect.width / 6, boardRect.height / 6),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.image(const AssetImage(AppAssets.markX)), findsOneWidget);

    await tester.tapAt(
      boardRect.topLeft + Offset(boardRect.width / 6, boardRect.height / 6),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.image(const AssetImage(AppAssets.markX)), findsOneWidget);
    expect(find.image(const AssetImage(AppAssets.markO)), findsNothing);
  });

  testWidgets('ignores simultaneous board taps in the same frame', (
    tester,
  ) async {
    final pressedCells = <int>[];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox.square(
              dimension: 300,
              child: GameBoard(
                board: Board.empty(),
                result: const GameResult.ongoing(),
                onCellPressed: pressedCells.add,
              ),
            ),
          ),
        ),
      ),
    );

    final boardRect = tester.getRect(find.byType(GameBoard));
    final firstCell =
        boardRect.topLeft + Offset(boardRect.width / 6, boardRect.height / 6);
    final secondCell =
        boardRect.topLeft + Offset(boardRect.width / 2, boardRect.height / 6);

    final firstTap = await tester.startGesture(firstCell, pointer: 1);
    final secondTap = await tester.startGesture(secondCell, pointer: 2);
    await firstTap.up();
    await secondTap.up();
    await tester.pump();

    expect(tester.takeException(), isNull);
    expect(pressedCells, [0]);
  });

  testWidgets('asks for difficulty before starting an AI game', (tester) async {
    await pumpApp(tester);
    await enterHome(tester);

    await tester.tap(find.text(en.aiGameAction));
    await tester.pumpAndSettle();

    expect(find.text(en.selectDifficultyTitle), findsOneWidget);
    expect(find.text(en.easyLabel), findsOneWidget);
    expect(find.text(en.hardLabel), findsOneWidget);

    await tester.tap(find.text(en.hardLabel));
    await finishGameLoading(tester);

    expect(find.text(en.humanVsCpuLabel), findsNothing);
    expect(find.text(en.humanTurnStatus), findsOneWidget);
    expect(find.text(en.cpuTurnStatus), findsOneWidget);
  });
}
