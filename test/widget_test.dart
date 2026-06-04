import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mockito/mockito.dart';
import 'package:tictactoe/app.dart';
import 'package:tictactoe/core/design_system/tokens/app_assets.dart';
import 'package:tictactoe/core/design_system/tokens/app_durations.dart';
import 'package:tictactoe/core/design_system/widgets/tic_tac_toe_title_logo.dart';
import 'package:tictactoe/core/di/audio_providers.dart';
import 'package:tictactoe/core/di/storage_providers.dart';
import 'package:tictactoe/core/router/app_router.dart';
import 'package:tictactoe/features/game/domain/entities/game_session.dart';
import 'package:tictactoe/features/game/domain/entities/game_setup.dart';
import 'package:tictactoe/features/game/presentation/controllers/game_view_state.dart';
import 'package:tictactoe/features/game/presentation/widgets/game_board.dart';
import 'package:tictactoe/l10n/app_localizations_en.dart';
import 'package:tictactoe/l10n/app_localizations_fr.dart';

import 'testing/in_memory_key_value_storage.dart';
import 'testing/mock_stubs.dart';
import 'testing/mocks.mocks.dart';

const _titleRouteArrivalBuffer = Duration(milliseconds: 700);
const _titlePromptHiddenCheckLead = Duration(seconds: 4);
const _homeRouteSettle = Duration(milliseconds: 900);
const _loadingRouteArrivalBuffer = Duration(seconds: 1);
const _loadingCinematicBuffer = Duration(seconds: 5);
const _loadingSealBuffer = Duration(milliseconds: 600);
const _loadingGameRouteBuffer = Duration(milliseconds: 800);
const _loadingFinalFrameBuffer = Duration(milliseconds: 200);
final _boardMarkAssertBuffer =
    AppDurations.boardMarkReveal + AppDurations.micro;

Future<void> pumpAnimationSteps(
  WidgetTester tester,
  Iterable<Duration> steps, {
  bool settleEachStep = true,
}) async {
  for (final step in steps) {
    await tester.pump(step);
    if (settleEachStep) {
      await tester.pump();
    }
  }
}

void main() {
  final en = AppLocalizationsEn();
  final fr = AppLocalizationsFr();

  Future<void> pumpApp(WidgetTester tester) async {
    final audio = MockAudioController();
    stubAudioController(audio);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          audioControllerProvider.overrideWithValue(audio),
          keyValueStorageProvider.overrideWithValue(InMemoryKeyValueStorage()),
        ],
        child: const TicTacToeApp(),
      ),
    );
    await tester.pump();
  }

  Future<MockAudioController> pumpAppWithAudio(WidgetTester tester) async {
    final audio = MockAudioController();
    stubAudioController(audio);
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const SizedBox.shrink(),
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appRouterProvider.overrideWithValue(router),
          audioControllerProvider.overrideWithValue(audio),
          keyValueStorageProvider.overrideWithValue(InMemoryKeyValueStorage()),
        ],
        child: const TicTacToeApp(),
      ),
    );
    await tester.pump();
    return audio;
  }

  Future<void> finishSplash(WidgetTester tester) async {
    await tester.pump(AppDurations.splashScreen);
    await tester.pump();
  }

  Future<void> finishTitleIntro(WidgetTester tester) async {
    await finishSplash(tester);
    await pumpAnimationSteps(tester, [
      _titleRouteArrivalBuffer,
      AppDurations.titleLogoEntranceDelay,
      AppDurations.titlePromptDelay,
      AppDurations.titlePrompt,
    ]);
  }

  Future<void> enterHome(WidgetTester tester) async {
    await finishTitleIntro(tester);
    expect(find.text(en.touchScreenPrompt), findsOneWidget);

    await tester.tapAt(const Offset(400, 300));
    await tester.pump(_homeRouteSettle);
    await tester.pumpAndSettle();
  }

  Future<void> finishGameLoading(WidgetTester tester) async {
    await tester.pump();
    await pumpAnimationSteps(tester, [
      _loadingRouteArrivalBuffer,
      _loadingCinematicBuffer,
      _loadingSealBuffer,
      _loadingGameRouteBuffer,
      _loadingFinalFrameBuffer,
    ], settleEachStep: false);
  }

  Finder richTextPlain(String plainText) {
    return find.byWidgetPredicate(
      (widget) => widget is RichText && widget.text.toPlainText() == plainText,
      description: 'RichText("$plainText")',
    );
  }

  testWidgets('opens on the title screen before home', (tester) async {
    await pumpApp(tester);

    expect(find.image(const AssetImage(AppAssets.sigil)), findsOneWidget);
    expect(find.text(en.touchScreenPrompt), findsNothing);

    await finishSplash(tester);

    expect(find.byType(TicTacToeTitleLogo), findsWidgets);
    expect(find.text(en.touchScreenPrompt), findsNothing);

    await pumpAnimationSteps(tester, [
      _titleRouteArrivalBuffer,
      AppDurations.titleLogoEntranceDelay,
      _titlePromptHiddenCheckLead,
    ]);
    expect(find.text(en.touchScreenPrompt), findsNothing);

    await pumpAnimationSteps(tester, [
      AppDurations.titlePromptDelay - _titlePromptHiddenCheckLead,
      AppDurations.titlePrompt,
    ]);

    expect(find.text(en.touchScreenPrompt), findsOneWidget);
  });

  testWidgets('pauses music when the app leaves the foreground', (
    tester,
  ) async {
    final audio = await pumpAppWithAudio(tester);
    clearInteractions(audio);

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    await tester.pump();

    verify(audio.pauseMusic()).called(1);

    clearInteractions(audio);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
    await tester.pump();
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    await tester.pump();

    verifyNever(audio.pauseMusic());

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump();
    clearInteractions(audio);

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    await tester.pump();

    verify(audio.pauseMusic()).called(1);
  });

  testWidgets('shows the home actions and opens preferences', (tester) async {
    await pumpApp(tester);
    await enterHome(tester);

    expect(find.byType(TicTacToeTitleLogo), findsWidgets);
    expect(find.text(en.localGameAction), findsOneWidget);
    expect(find.text(en.aiGameAction), findsOneWidget);
    expect(find.text(en.continueRunAction), findsNothing);
    expect(find.text(en.scoreTitle), findsOneWidget);

    await tester.tap(find.text(en.settingsTitle));
    await tester.pumpAndSettle();

    expect(find.text(en.audioTitle), findsOneWidget);
    expect(find.text(en.scoreTitle), findsOneWidget);
    expect(find.text(en.languageTitle), findsOneWidget);
  });

  testWidgets('opens the score dialog from home', (tester) async {
    await pumpApp(tester);
    await enterHome(tester);

    await tester.tap(find.text(en.scoreTitle));
    await tester.pumpAndSettle();

    expect(find.text(en.recordTitle), findsOneWidget);
    expect(find.text(en.tarnishedRecordTitle), findsOneWidget);
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

    expect(find.text(fr.languageTitle), findsWidgets);
    expect(find.text(fr.systemHeaderTitle), findsOneWidget);
  });

  testWidgets('starts a local game in one tap', (tester) async {
    await pumpApp(tester);
    await enterHome(tester);

    await tester.tap(find.text(en.localGameAction));
    await finishGameLoading(tester);

    expect(find.text(en.humanVsHumanLabel), findsNothing);
    expect(find.text(en.playerOneStatus), findsOneWidget);
    expect(find.text(en.playerTwoStatus), findsOneWidget);

    final boardRect = tester.getRect(find.byType(GameBoard));
    final humanLabelRect = tester.getRect(find.text(en.playerOneStatus));
    final cpuLabelRect = tester.getRect(find.text(en.playerTwoStatus));

    expect(cpuLabelRect.bottom, lessThanOrEqualTo(boardRect.top));
    expect(humanLabelRect.top, greaterThanOrEqualTo(boardRect.bottom));

    await tester.tapAt(
      boardRect.topLeft + Offset(boardRect.width / 6, boardRect.height / 6),
    );
    await tester.pump();
    await tester.pump(_boardMarkAssertBuffer);

    expect(find.image(const AssetImage(AppAssets.markX)), findsOneWidget);

    await tester.tapAt(
      boardRect.topLeft + Offset(boardRect.width / 6, boardRect.height / 6),
    );
    await tester.pump();
    await tester.pump(_boardMarkAssertBuffer);

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
                session: GameSession.newGame(GameSetup.guidedTrial()),
                phase: GameViewPhase.awaitingHumanMove,
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
    expect(find.text(en.guidedTrialAction), findsOneWidget);
    expect(find.text(en.noMercyAction), findsOneWidget);

    await tester.tap(find.text(en.noMercyAction));
    await finishGameLoading(tester);

    expect(find.text(en.humanVsCpuLabel), findsNothing);
    expect(find.text(en.humanTurnStatus), findsOneWidget);
    expect(richTextPlain('Radahn\nStarscourge'), findsOneWidget);

    final radahnImages = find
        .image(const AssetImage(AppAssets.radahn))
        .evaluate()
        .map((element) => element.widget)
        .whereType<Image>();
    expect(radahnImages.any((image) => image.opacity?.value == 1), isTrue);
  });
}
