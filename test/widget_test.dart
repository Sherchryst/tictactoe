import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tictactoe/app.dart';
import 'package:tictactoe/core/di/game_dependencies.dart';
import 'package:tictactoe/features/game/presentation/game_copy.dart';

import 'helpers/fake_key_value_storage.dart';

void main() {
  Future<void> pumpApp(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          keyValueStorageProvider.overrideWithValue(FakeKeyValueStorage()),
        ],
        child: const TicTacToeApp(),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('shows the home actions and opens preferences', (tester) async {
    await pumpApp(tester);

    expect(find.text(GameCopy.appTitle), findsOneWidget);
    expect(find.text(GameCopy.localGameAction), findsOneWidget);
    expect(find.text(GameCopy.aiGameAction), findsOneWidget);

    await tester.tap(find.text(GameCopy.settingsTitle));
    await tester.pumpAndSettle();

    expect(find.text(GameCopy.themeTitle), findsOneWidget);
    expect(find.text(GameCopy.scoreTitle), findsOneWidget);
  });

  testWidgets('starts a local game in one tap', (tester) async {
    await pumpApp(tester);

    await tester.tap(find.text(GameCopy.localGameAction));
    await tester.pumpAndSettle();

    expect(find.text(GameCopy.humanVsHumanLabel), findsOneWidget);
    expect(find.text(GameCopy.playerXScoreLabel), findsOneWidget);
    expect(find.text(GameCopy.playerOScoreLabel), findsOneWidget);
  });

  testWidgets('asks for difficulty before starting an AI game', (tester) async {
    await pumpApp(tester);

    await tester.tap(find.text(GameCopy.aiGameAction));
    await tester.pumpAndSettle();

    expect(find.text(GameCopy.selectDifficultyTitle), findsOneWidget);
    expect(find.text(GameCopy.easyLabel), findsOneWidget);
    expect(find.text(GameCopy.hardLabel), findsOneWidget);

    await tester.tap(find.text(GameCopy.hardLabel));
    await tester.pumpAndSettle();

    expect(find.text(GameCopy.humanVsCpuLabel), findsOneWidget);
    expect(find.text(GameCopy.humanScoreLabel), findsOneWidget);
    expect(find.text(GameCopy.cpuScoreLabel), findsOneWidget);
  });
}
