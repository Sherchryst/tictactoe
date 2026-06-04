import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:tictactoe/features/game/domain/entities/board.dart';
import 'package:tictactoe/features/game/domain/entities/cpu_boss.dart';
import 'package:tictactoe/features/game/domain/entities/game_result.dart';
import 'package:tictactoe/features/game/domain/entities/game_session.dart';
import 'package:tictactoe/features/game/domain/entities/game_setup.dart';
import 'package:tictactoe/features/game/domain/entities/mark.dart';
import 'package:tictactoe/features/game/presentation/audio/game_audio_effects.dart';

import '../../../../testing/mock_stubs.dart';
import '../../../../testing/mocks.mocks.dart';

void main() {
  GameSession session({
    Board? board,
    GameMode mode = GameMode.guidedTrial,
    CpuBossId bossId = CpuBossId.guided,
    Mark currentMark = Mark.x,
    GameResult result = const GameResult.ongoing(),
  }) {
    return GameSession(
      board: board ?? Board.empty(),
      currentMark: currentMark,
      mode: mode,
      bossId: bossId,
      result: result,
    );
  }

  group('GameAudioEffects', () {
    test('plays human and CPU move sounds for newly placed marks', () async {
      final audio = MockAudioController();
      stubAudioController(audio);
      final effects = GameAudioEffects(audio);

      await effects.playBoardDelta(
        previousBoard: Board.empty(),
        nextSession: session(
          board: Board.empty().place(Mark.x, 0).place(Mark.o, 1),
        ),
      );

      verifyInOrder([audio.playHumanMark(), audio.playCpuMark()]);
      verifyNoMoreInteractions(audio);
    });

    test('does not play a move sound for the initial board', () async {
      final audio = MockAudioController();
      stubAudioController(audio);
      final effects = GameAudioEffects(audio);

      await effects.playBoardDelta(
        previousBoard: null,
        nextSession: session(board: Board.empty().place(Mark.x, 0)),
      );

      verifyNever(audio.playHumanMark());
      verifyNever(audio.playCpuMark());
      verifyNoMoreInteractions(audio);
    });

    test('plays the boss rune intro sound for CPU rounds only', () async {
      final audio = MockAudioController();
      stubAudioController(audio);
      final effects = GameAudioEffects(audio);

      await effects.playBossRuneIntro(
        session(mode: GameMode.noMercyRun, bossId: CpuBossId.radahn),
      );
      await effects.playBossRuneIntro(session(mode: GameMode.localDuel));

      verify(audio.playCpuMark()).called(1);
      verifyNoMoreInteractions(audio);
    });

    test('maps draw intro to draw audio', () async {
      final audio = MockAudioController();
      stubAudioController(audio);
      final effects = GameAudioEffects(audio);

      await effects.playResultIntro(session(result: const GameResult.draw()));

      verify(audio.playDraw()).called(1);
      verifyNoMoreInteractions(audio);
    });

    test('maps CPU win intro to death intro audio', () async {
      final audio = MockAudioController();
      stubAudioController(audio);
      final effects = GameAudioEffects(audio);

      await effects.playResultIntro(
        session(
          mode: GameMode.noMercyRun,
          bossId: CpuBossId.radahn,
          result: const GameResult.win(winner: Mark.o, winningCells: [0, 1, 2]),
        ),
      );

      verify(audio.playDeathIntro()).called(1);
      verifyNoMoreInteractions(audio);
    });

    test('maps human and local wins intro to parry audio', () async {
      final audio = MockAudioController();
      stubAudioController(audio);
      final effects = GameAudioEffects(audio);

      await effects.playResultIntro(
        session(
          result: const GameResult.win(winner: Mark.x, winningCells: [0, 1, 2]),
        ),
      );
      await effects.playResultIntro(
        session(
          mode: GameMode.localDuel,
          result: const GameResult.win(winner: Mark.o, winningCells: [0, 1, 2]),
        ),
      );

      verify(audio.playParry()).called(2);
      verifyNoMoreInteractions(audio);
    });

    test('maps human win dialog reveal to victory audio', () async {
      final audio = MockAudioController();
      stubAudioController(audio);
      final effects = GameAudioEffects(audio);

      await effects.playDialogReveal(
        session(
          result: const GameResult.win(winner: Mark.x, winningCells: [0, 1, 2]),
        ),
      );

      verify(audio.playVictory()).called(1);
      verifyNoMoreInteractions(audio);
    });

    test('plays Malenia voice only when Malenia defeats the player', () async {
      final audio = MockAudioController();
      stubAudioController(audio);
      final effects = GameAudioEffects(audio);

      await effects.playDialogReveal(
        session(
          mode: GameMode.noMercyRun,
          bossId: CpuBossId.malenia,
          result: const GameResult.win(winner: Mark.o, winningCells: [0, 4, 8]),
        ),
      );

      verifyInOrder([audio.playDeath(), audio.playMaleniaVictoryLine()]);
      verifyNoMoreInteractions(audio);
    });

    test('does not play result audio while the game is ongoing', () async {
      final audio = MockAudioController();
      stubAudioController(audio);
      final effects = GameAudioEffects(audio);

      await effects.playResultIntro(session());

      verifyNoMoreInteractions(audio);
    });

    test('returns expected dialog delays', () {
      final audio = MockAudioController();
      stubAudioController(audio);
      final effects = GameAudioEffects(audio);

      expect(
        effects.dialogDelayFor(
          session(
            result: const GameResult.win(
              winner: Mark.x,
              winningCells: [0, 1, 2],
            ),
          ),
        ),
        GameAudioEffects.guidedVictoryDelay,
      );
      expect(
        effects.dialogDelayFor(
          session(
            mode: GameMode.noMercyRun,
            bossId: CpuBossId.radahn,
            result: const GameResult.win(
              winner: Mark.x,
              winningCells: [0, 1, 2],
            ),
          ),
        ),
        GameAudioEffects.noMercyVictoryBannerDelay,
      );
      expect(
        effects.dialogDelayFor(session(result: const GameResult.draw())),
        GameAudioEffects.drawCriticalImpactDuration,
      );
    });

    test('holds CPU and human win dialog reveals for solo modes', () {
      final audio = MockAudioController();
      stubAudioController(audio);
      final effects = GameAudioEffects(audio);

      expect(
        effects.dialogRevealLeadFor(
          session(
            mode: GameMode.noMercyRun,
            bossId: CpuBossId.radahn,
            result: const GameResult.win(
              winner: Mark.o,
              winningCells: [0, 1, 2],
            ),
          ),
        ),
        const Duration(milliseconds: 1500),
      );
      expect(
        effects.dialogRevealLeadFor(
          session(
            mode: GameMode.noMercyRun,
            bossId: CpuBossId.radahn,
            result: const GameResult.win(
              winner: Mark.x,
              winningCells: [0, 1, 2],
            ),
          ),
        ),
        GameAudioEffects.soloVictorySoundDuration,
      );
    });
  });
}
