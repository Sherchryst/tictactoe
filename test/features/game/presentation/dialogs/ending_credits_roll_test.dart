import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tictactoe/core/design_system/theme/app_theme.dart';
import 'package:tictactoe/features/game/presentation/dialogs/ending_credits_roll.dart';
import 'package:tictactoe/l10n/app_localizations.dart';
import 'package:tictactoe/l10n/app_localizations_en.dart';

void main() {
  final en = AppLocalizationsEn();

  testWidgets('rolls credits and closes after every line leaves the screen', (
    tester,
  ) async {
    var completed = false;

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark(),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: Builder(
            builder: (context) {
              return TextButton(
                onPressed: () async {
                  await EndingCreditsRoll.show(context: context);
                  completed = true;
                },
                child: const Text('open credits'),
              );
            },
          ),
        ),
      ),
    );

    await tester.tap(find.text('open credits'));
    await tester.pump();

    expect(find.text(en.noMercyAction), findsOneWidget);
    expect(find.text(en.creditsMusicRecusants), findsOneWidget);
    expect(find.text(en.creditsDesignerName), findsOneWidget);
    expect(completed, isFalse);

    await tester.pump(
      EndingCreditsRoll.rollDuration + const Duration(milliseconds: 120),
    );
    await tester.pump();
    await tester.pump();

    expect(completed, isTrue);
    expect(find.text(en.noMercyAction), findsNothing);
    expect(find.text(en.creditsMusicRecusants), findsNothing);
  });

  testWidgets('closes before running the completion callback', (tester) async {
    var callbackCalled = false;
    var showReturned = false;

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark(),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: Builder(
            builder: (context) {
              return TextButton(
                onPressed: () async {
                  await EndingCreditsRoll.show(
                    context: context,
                    onComplete: () {
                      callbackCalled = true;
                    },
                  );
                  showReturned = true;
                },
                child: const Text('open credits'),
              );
            },
          ),
        ),
      ),
    );

    await tester.tap(find.text('open credits'));
    await tester.pump();
    await tester.pump(
      EndingCreditsRoll.rollDuration + const Duration(milliseconds: 120),
    );
    await tester.pump();
    await tester.pump();

    expect(callbackCalled, isTrue);
    expect(showReturned, isTrue);
    expect(find.text(en.noMercyAction), findsNothing);
  });
}
