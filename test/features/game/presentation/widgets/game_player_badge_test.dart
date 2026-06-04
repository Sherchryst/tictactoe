import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tictactoe/core/design_system/theme/app_palette.dart';
import 'package:tictactoe/core/design_system/tokens/app_assets.dart';
import 'package:tictactoe/features/game/domain/entities/cpu_boss.dart';
import 'package:tictactoe/features/game/domain/entities/game_result.dart';
import 'package:tictactoe/features/game/domain/entities/game_session.dart';
import 'package:tictactoe/features/game/domain/entities/game_setup.dart';
import 'package:tictactoe/features/game/domain/entities/mark.dart';
import 'package:tictactoe/features/game/presentation/utils/styles/game_player_badge_types.dart';
import 'package:tictactoe/features/game/presentation/widgets/game_player_badge.dart';
import 'package:tictactoe/features/game/presentation/widgets/no_mercy_cycle_badge.dart';
import 'package:tictactoe/l10n/app_localizations.dart';
import 'package:tictactoe/l10n/app_localizations_en.dart';

void main() {
  final en = AppLocalizationsEn();

  testWidgets('splits No Mercy boss name and title over two lines', (
    tester,
  ) async {
    final session = GameSession.newGame(GameSetup.noMercy(CpuBossId.mohg));

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: GamePlayerBadge(
            participant: session.participantFor(session.opponentMark),
            session: session,
            active: true,
            side: GamePlayerBadgeSide.right,
          ),
        ),
      ),
    );

    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is RichText &&
            widget.text.toPlainText() == 'Mohg\nLord of Blood',
        description: 'Mohg boss RichText',
      ),
      findsOneWidget,
    );
  });

  testWidgets('does not render NG+ on the boss badge', (tester) async {
    final session = GameSession.newGame(
      GameSetup.noMercy(CpuBossId.malenia, noMercyCycle: 2),
    );

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: GamePlayerBadge(
            participant: session.participantFor(session.opponentMark),
            session: session,
            active: true,
            side: GamePlayerBadgeSide.right,
          ),
        ),
      ),
    );

    expect(find.text(en.noMercyCycleBadge(2)), findsNothing);
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is RichText &&
            widget.text.toPlainText() == 'Malenia\nBlade of Miquella',
        description: 'Malenia boss RichText without NG+',
      ),
      findsOneWidget,
    );
  });

  testWidgets('renders a standalone No Mercy cycle badge', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: NoMercyCycleBadge(cycle: 2)),
      ),
    );

    expect(find.text(en.noMercyCycleBadge(2)), findsOneWidget);
    expect(_fontFamilyFor(en.noMercyCycleBadge(2), '+'), AppPalette.serifFont);
  });

  testWidgets('uses the dead boss rune after a No Mercy victory', (
    tester,
  ) async {
    final session = GameSession.newGame(GameSetup.noMercy(CpuBossId.mohg))
        .copyWith(
          result: const GameResult.win(winner: Mark.x, winningCells: [0, 1, 2]),
        );

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: GamePlayerBadge(
            participant: session.participantFor(session.opponentMark),
            session: session,
            active: false,
            side: GamePlayerBadgeSide.right,
          ),
        ),
      ),
    );

    expect(find.image(const AssetImage(AppAssets.mohgDead)), findsOneWidget);
    expect(find.image(const AssetImage(AppAssets.mohg)), findsNothing);
  });

  testWidgets('can hide the static badge while the boss intro moves it', (
    tester,
  ) async {
    final session = GameSession.newGame(GameSetup.noMercy(CpuBossId.radahn));

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: GamePlayerBadge(
            participant: session.participantFor(session.opponentMark),
            session: session,
            active: true,
            side: GamePlayerBadgeSide.right,
            visible: false,
          ),
        ),
      ),
    );

    final opacity = tester.widget<Opacity>(find.byType(Opacity).first);

    expect(opacity.opacity, 0);
  });

  testWidgets('uses rune arc for the human badge in No Mercy', (tester) async {
    final session = GameSession.newGame(GameSetup.noMercy(CpuBossId.radahn));

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: GamePlayerBadge(
            participant: session.participantFor(session.humanMark),
            session: session,
            active: true,
            side: GamePlayerBadgeSide.left,
          ),
        ),
      ),
    );

    expect(find.image(const AssetImage(AppAssets.runeArc)), findsOneWidget);
    expect(find.image(const AssetImage(AppAssets.flask)), findsNothing);
  });
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
