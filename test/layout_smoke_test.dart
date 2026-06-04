import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tictactoe/core/design_system/theme/app_theme.dart';
import 'package:tictactoe/core/di/audio_providers.dart';
import 'package:tictactoe/core/di/storage_providers.dart';
import 'package:tictactoe/features/game/domain/entities/cpu_boss.dart';
import 'package:tictactoe/features/game/domain/entities/game_result.dart';
import 'package:tictactoe/features/game/domain/entities/game_session.dart';
import 'package:tictactoe/features/game/domain/entities/game_setup.dart';
import 'package:tictactoe/features/game/domain/entities/mark.dart';
import 'package:tictactoe/features/game/presentation/controllers/game_controller.dart';
import 'package:tictactoe/features/game/presentation/pages/game_page.dart';
import 'package:tictactoe/features/game/presentation/pages/home_page.dart';
import 'package:tictactoe/features/game/presentation/widgets/dialogs/difficulty_dialog.dart';
import 'package:tictactoe/features/game/presentation/widgets/dialogs/game_over_dialog.dart';
import 'package:tictactoe/features/game/presentation/widgets/dialogs/scoreboard_dialog.dart';
import 'package:tictactoe/features/settings/presentation/pages/settings_page.dart';
import 'package:tictactoe/l10n/app_localizations.dart';

import 'testing/in_memory_key_value_storage.dart';
import 'testing/mock_stubs.dart';
import 'testing/mocks.mocks.dart';

void main() {
  const viewports = <String, Size>{
    'compact': Size(390, 844),
    'desktop': Size(1280, 800),
  };

  testWidgets('home page does not overflow on compact and desktop viewports', (
    tester,
  ) async {
    for (final MapEntry(key: name, value: size) in viewports.entries) {
      await _withViewport(tester, size, () async {
        final container = _createContainer();
        await _pumpHost(tester, container, const HomePage());
        _expectNoFlutterException(tester, 'home page $name');
      });
    }
  });

  testWidgets('game page does not overflow on compact and desktop viewports', (
    tester,
  ) async {
    for (final MapEntry(key: name, value: size) in viewports.entries) {
      await _withViewport(tester, size, () async {
        final container = _createContainer();
        await container.read(gameControllerProvider.notifier).startLocalDuel();
        await _pumpHost(tester, container, const GamePage());
        _expectNoFlutterException(tester, 'game page $name');
      });
    }
  });

  testWidgets(
    'settings page does not overflow on compact and desktop viewports',
    (tester) async {
      for (final MapEntry(key: name, value: size) in viewports.entries) {
        await _withViewport(tester, size, () async {
          final container = _createContainer();
          await _pumpHost(
            tester,
            container,
            SettingsPage(onBack: () {}),
            settle: true,
          );
          _expectNoFlutterException(tester, 'settings page $name');
        });
      }
    },
  );

  testWidgets('game dialogs fit compact and desktop viewports', (tester) async {
    for (final MapEntry(key: name, value: size) in viewports.entries) {
      await _withViewport(tester, size, () async {
        await _pumpHost(tester, _createContainer(), const DifficultyDialog());
        _expectNoFlutterException(tester, 'difficulty dialog $name');

        await _pumpHost(tester, _createContainer(), const ScoreboardDialog());
        _expectNoFlutterException(tester, 'scoreboard dialog $name');

        await _pumpHost(
          tester,
          _createContainer(),
          GameOverDialog(session: _humanWin()),
        );
        _expectNoFlutterException(tester, 'game over dialog $name');
      });
    }
  });
}

ProviderContainer _createContainer() {
  final audio = MockAudioController();
  stubAudioController(audio);

  final container = ProviderContainer(
    overrides: [
      audioControllerProvider.overrideWithValue(audio),
      keyValueStorageProvider.overrideWithValue(InMemoryKeyValueStorage()),
    ],
  );
  addTearDown(container.dispose);
  return container;
}

Future<void> _pumpHost(
  WidgetTester tester,
  ProviderContainer container,
  Widget child, {
  bool settle = false,
}) async {
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        theme: AppTheme.dark(),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: child,
      ),
    ),
  );
  await tester.pump();
  if (settle) {
    await tester.pumpAndSettle();
  } else {
    await tester.pump(const Duration(milliseconds: 300));
  }
}

Future<void> _withViewport(
  WidgetTester tester,
  Size size,
  Future<void> Function() body,
) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = size;
  try {
    await body();
  } finally {
    await tester.pumpWidget(const SizedBox.shrink());
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  }
}

void _expectNoFlutterException(WidgetTester tester, String surface) {
  final exception = tester.takeException();
  expect(exception, isNull, reason: '$surface should render without overflow');
}

GameSession _humanWin() {
  return GameSession.newGame(GameSetup.localDuel()).copyWith(
    result: const GameResult.win(winner: Mark.x, winningCells: [0, 1, 2]),
    bossId: CpuBossId.guided,
  );
}
