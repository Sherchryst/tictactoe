import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tictactoe/core/design_system/tokens/app_assets.dart';
import 'package:tictactoe/features/game/domain/entities/board.dart';
import 'package:tictactoe/features/game/domain/entities/cpu_boss.dart';
import 'package:tictactoe/features/game/domain/entities/game_session.dart';
import 'package:tictactoe/features/game/domain/entities/game_setup.dart';
import 'package:tictactoe/features/game/domain/entities/mark.dart';
import 'package:tictactoe/features/game/presentation/controllers/game_view_state.dart';
import 'package:tictactoe/features/game/presentation/widgets/game_board.dart';

void main() {
  testWidgets('uses rune arc for human marks in No Mercy', (tester) async {
    final session = GameSession.newGame(
      GameSetup.noMercy(CpuBossId.radahn),
    ).copyWith(board: Board.empty().place(Mark.x, 0));

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox.square(
            dimension: 320,
            child: GameBoard(
              session: session,
              phase: GameViewPhase.awaitingHumanMove,
              onCellPressed: (_) {},
            ),
          ),
        ),
      ),
    );

    expect(find.image(const AssetImage(AppAssets.runeArc)), findsOneWidget);
    expect(find.image(const AssetImage(AppAssets.markX)), findsNothing);
  });
}
