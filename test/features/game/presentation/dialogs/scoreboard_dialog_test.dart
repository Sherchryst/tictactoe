import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tictactoe/core/design_system/theme/app_theme.dart';
import 'package:tictactoe/core/di/audio_providers.dart';
import 'package:tictactoe/core/di/storage_providers.dart';
import 'package:tictactoe/core/preferences/application/controllers/app_preferences_controller.dart';
import 'package:tictactoe/features/game/domain/entities/cpu_boss.dart';
import 'package:tictactoe/features/game/domain/entities/game_result.dart';
import 'package:tictactoe/features/game/presentation/controllers/scoreboard_controller.dart';
import 'package:tictactoe/features/game/presentation/widgets/dialogs/scoreboard_dialog.dart';
import 'package:tictactoe/l10n/app_localizations.dart';
import 'package:tictactoe/l10n/app_localizations_en.dart';

import '../../../../testing/in_memory_key_value_storage.dart';
import '../../../../testing/mock_stubs.dart';
import '../../../../testing/mocks.mocks.dart';
import '../../../../testing/provider_container_factory.dart';

void main() {
  final en = AppLocalizationsEn();

  ProviderContainer createContainer() {
    final audio = MockAudioController();
    stubAudioController(audio);

    return createTestContainer(
      registerTearDown: addTearDown,
      overrides: [
        audioControllerProvider.overrideWithValue(audio),
        keyValueStorageProvider.overrideWithValue(InMemoryKeyValueStorage()),
      ],
    );
  }

  Future<void> pumpDialog(
    WidgetTester tester,
    ProviderContainer container,
  ) async {
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: AppTheme.dark(),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const ScoreboardDialog(),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('shows only the total Tarnished record', (tester) async {
    final container = createContainer();
    await container
        .read(scoreboardControllerProvider.notifier)
        .record(CpuBossId.radahn, GameOutcome.humanWin);
    await container
        .read(scoreboardControllerProvider.notifier)
        .record(CpuBossId.mohg, GameOutcome.cpuWin);
    await container
        .read(scoreboardControllerProvider.notifier)
        .record(CpuBossId.malenia, GameOutcome.draw);

    await pumpDialog(tester, container);

    expect(find.text(en.tarnishedRecordTitle), findsOneWidget);
    expect(find.text(en.tarnishedVictoryLabel), findsOneWidget);
    expect(find.text(en.tarnishedDefeatLabel), findsOneWidget);
    expect(find.text(en.tarnishedDrawLabel), findsOneWidget);
    expect(find.text(en.tarnishedFightLabel), findsOneWidget);
    expect(find.text(en.bossRadahnName), findsNothing);
    expect(find.text(en.bossMohgName), findsNothing);
    expect(find.text(en.bossMaleniaName), findsNothing);
  });

  testWidgets('asks before resetting the score by default', (tester) async {
    final container = createContainer();
    await pumpDialog(tester, container);

    await tester.tap(find.text(en.resetScoreAction));
    await tester.pumpAndSettle();

    expect(find.text(en.resetScoreConfirmMessage), findsOneWidget);
    expect(find.text(en.resetScoreDontAskAgain), findsOneWidget);
  });

  testWidgets('canceling grace confirmation keeps the record', (tester) async {
    final container = createContainer();
    await container
        .read(scoreboardControllerProvider.notifier)
        .record(CpuBossId.radahn, GameOutcome.humanWin);
    await pumpDialog(tester, container);

    await tester.tap(find.text(en.resetScoreAction));
    await tester.pumpAndSettle();
    await tester.tap(find.text(en.backTooltip).last);
    await tester.pumpAndSettle();

    final scoreboard = await container.read(
      scoreboardControllerProvider.future,
    );
    expect(scoreboard.tarnishedRecord.humanWins, 1);
  });

  testWidgets('do not ask again disables grace confirmation', (tester) async {
    final container = createContainer();
    await container
        .read(scoreboardControllerProvider.notifier)
        .record(CpuBossId.radahn, GameOutcome.humanWin);
    await pumpDialog(tester, container);

    await tester.tap(find.text(en.resetScoreAction));
    await tester.pumpAndSettle();
    await tester.tap(find.text(en.resetScoreDontAskAgain));
    await tester.pumpAndSettle();
    await tester.tap(find.text(en.resetScoreConfirmAction));
    await tester.pumpAndSettle();

    final preferences = await container.read(
      appPreferencesControllerProvider.future,
    );
    final scoreboard = await container.read(
      scoreboardControllerProvider.future,
    );
    expect(preferences.confirmScoreReset, isFalse);
    expect(scoreboard.tarnishedRecord.attempts, 0);
  });
}
