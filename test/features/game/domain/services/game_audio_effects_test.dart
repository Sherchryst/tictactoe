import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:tictactoe/features/game/domain/entities/board.dart';
import 'package:tictactoe/features/game/domain/entities/cell.dart';
import 'package:tictactoe/features/game/domain/entities/game_result.dart';
import 'package:tictactoe/features/game/domain/entities/game_setup.dart';
import 'package:tictactoe/features/game/domain/entities/player.dart';
import 'package:tictactoe/features/game/domain/services/game_audio_effects.dart';

import 'package:tictactoe/testing/mock_stubs.dart';
import 'package:tictactoe/testing/mocks.mocks.dart';

void main() {
  group('GameAudioEffects', () {
    test('plays one move sound for each newly placed mark', () async {
      final audio = MockAudioController();
      stubAudioController(audio);
      final effects = GameAudioEffects(audio);

      await effects.playBoardDelta(
        previousBoard: Board.empty(),
        nextBoard: Board.empty().place(Cell.human, 0).place(Cell.cpu, 1),
      );

      verifyInOrder([
        audio.playMove(isPlayerX: true),
        audio.playMove(isPlayerX: false),
      ]);
      verifyNoMoreInteractions(audio);
    });

    test('does not play a move sound for the initial board', () async {
      final audio = MockAudioController();
      stubAudioController(audio);
      final effects = GameAudioEffects(audio);

      await effects.playBoardDelta(
        previousBoard: null,
        nextBoard: Board.empty().place(Cell.human, 0),
      );

      verifyNever(audio.playMove(isPlayerX: anyNamed('isPlayerX')));
      verifyNoMoreInteractions(audio);
    });

    test('maps draw intro to draw audio', () async {
      final audio = MockAudioController();
      stubAudioController(audio);
      final effects = GameAudioEffects(audio);

      await effects.playResultIntro(
        const GameResult.draw(),
        GameMode.humanVsCpu,
      );

      verify(audio.playDraw()).called(1);
      verifyNoMoreInteractions(audio);
    });

    test('maps solo CPU win intro to death intro audio', () async {
      final audio = MockAudioController();
      stubAudioController(audio);
      final effects = GameAudioEffects(audio);

      await effects.playResultIntro(
        const GameResult.win(winner: Player.cpu, winningCells: [0, 1, 2]),
        GameMode.humanVsCpu,
      );

      verify(audio.playDeathIntro()).called(1);
      verifyNoMoreInteractions(audio);
    });

    test('maps solo player win intro to parry audio only', () async {
      final audio = MockAudioController();
      stubAudioController(audio);
      final effects = GameAudioEffects(audio);

      await effects.playResultIntro(
        const GameResult.win(winner: Player.human, winningCells: [0, 1, 2]),
        GameMode.humanVsCpu,
      );

      verify(audio.playParry()).called(1);
      verifyNoMoreInteractions(audio);
    });

    test('maps duel win intro to parry audio', () async {
      final audio = MockAudioController();
      stubAudioController(audio);
      final effects = GameAudioEffects(audio);

      await effects.playResultIntro(
        const GameResult.win(winner: Player.cpu, winningCells: [0, 1, 2]),
        GameMode.humanVsHuman,
      );

      verify(audio.playParry()).called(1);
      verifyNoMoreInteractions(audio);
    });

    test('maps solo player win dialog reveal to victory audio', () async {
      final audio = MockAudioController();
      stubAudioController(audio);
      final effects = GameAudioEffects(audio);

      await effects.playDialogReveal(
        const GameResult.win(winner: Player.human, winningCells: [0, 1, 2]),
        GameMode.humanVsCpu,
      );

      verify(audio.playVictory()).called(1);
      verifyNoMoreInteractions(audio);
    });

    test('maps duel dialog reveal to victory audio', () async {
      final audio = MockAudioController();
      stubAudioController(audio);
      final effects = GameAudioEffects(audio);

      await effects.playDialogReveal(
        const GameResult.win(winner: Player.cpu, winningCells: [0, 1, 2]),
        GameMode.humanVsHuman,
      );

      verify(audio.playVictory()).called(1);
      verifyNoMoreInteractions(audio);
    });

    test('maps solo CPU win dialog reveal to final death audio', () async {
      final audio = MockAudioController();
      stubAudioController(audio);
      final effects = GameAudioEffects(audio);

      await effects.playDialogReveal(
        const GameResult.win(winner: Player.cpu, winningCells: [0, 1, 2]),
        GameMode.humanVsCpu,
      );

      verify(audio.playDeath()).called(1);
      verifyNoMoreInteractions(audio);
    });

    test('does not play result audio while the game is ongoing', () async {
      final audio = MockAudioController();
      stubAudioController(audio);
      final effects = GameAudioEffects(audio);

      await effects.playResultIntro(
        const GameResult.ongoing(),
        GameMode.humanVsCpu,
      );

      verifyNoMoreInteractions(audio);
    });

    test('delays win dialogs longer than draw dialogs', () {
      final audio = MockAudioController();
      stubAudioController(audio);
      final effects = GameAudioEffects(audio);

      expect(
        effects.dialogDelayFor(
          const GameResult.win(winner: Player.human, winningCells: [0, 1, 2]),
          GameMode.humanVsCpu,
        ),
        GameAudioEffects.parryDuration,
      );
      expect(
        effects.dialogDelayFor(
          const GameResult.win(winner: Player.human, winningCells: [0, 1, 2]),
          GameMode.humanVsHuman,
        ),
        const Duration(milliseconds: 1250),
      );
      expect(
        effects.dialogDelayFor(const GameResult.draw(), GameMode.humanVsCpu),
        GameAudioEffects.drawCriticalImpactDuration,
      );
    });

    test('holds solo CPU win dialog after final death audio', () {
      final audio = MockAudioController();
      stubAudioController(audio);
      final effects = GameAudioEffects(audio);

      expect(
        effects.dialogRevealLeadFor(
          const GameResult.win(winner: Player.cpu, winningCells: [0, 1, 2]),
          GameMode.humanVsCpu,
        ),
        const Duration(milliseconds: 1500),
      );
      expect(
        effects.dialogRevealLeadFor(
          const GameResult.win(winner: Player.human, winningCells: [0, 1, 2]),
          GameMode.humanVsCpu,
        ),
        GameAudioEffects.soloVictorySoundDuration,
      );
    });
  });
}
