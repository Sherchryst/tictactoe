import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tictactoe/features/game/presentation/widgets/home/home_menu_action.dart';
import 'package:tictactoe/features/game/presentation/widgets/home/title_menu.dart';
import 'package:tictactoe/features/game/presentation/widgets/home/title_menu_item.dart';
import 'package:tictactoe/l10n/app_localizations.dart';

void main() {
  testWidgets('selects New Game by default when there is no saved run', (
    tester,
  ) async {
    await pumpTitleMenu(tester, showContinue: false);

    final items = menuItems(tester);

    expect(items.first.action, HomeMenuAction.solo);
    expect(items.first.selected, isTrue);
    expect(items.where((item) => item.selected), hasLength(1));
  });

  testWidgets('selects Continue by default when a saved run exists', (
    tester,
  ) async {
    await pumpTitleMenu(tester, showContinue: true);

    final items = menuItems(tester);

    expect(items.first.action, HomeMenuAction.continueRun);
    expect(items.first.selected, isTrue);
    expect(items.where((item) => item.selected), hasLength(1));
  });

  testWidgets('shows Credits as the last action when unlocked', (tester) async {
    await pumpTitleMenu(tester, showContinue: true, showCredits: true);

    final items = menuItems(tester);

    expect(items.last.action, HomeMenuAction.credits);
    expect(items.first.action, HomeMenuAction.continueRun);
    expect(items.first.selected, isTrue);
  });
}

Future<void> pumpTitleMenu(
  WidgetTester tester, {
  required bool showContinue,
  bool showCredits = false,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: TitleMenu(
          selectedAction: firstHomeMenuAction(
            showContinue: showContinue,
            showCredits: showCredits,
          ),
          pressedAction: null,
          onSelected: (_) {},
          showContinue: showContinue,
          showCredits: showCredits,
        ),
      ),
    ),
  );
}

List<TitleMenuItem> menuItems(WidgetTester tester) {
  return tester.widgetList<TitleMenuItem>(find.byType(TitleMenuItem)).toList();
}
