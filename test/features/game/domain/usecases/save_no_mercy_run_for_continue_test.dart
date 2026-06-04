import 'package:flutter_test/flutter_test.dart';
import 'package:tictactoe/features/game/domain/entities/cpu_boss.dart';
import 'package:tictactoe/features/game/domain/entities/game_result.dart';
import 'package:tictactoe/features/game/domain/entities/game_session.dart';
import 'package:tictactoe/features/game/domain/entities/game_setup.dart';
import 'package:tictactoe/features/game/domain/entities/mark.dart';
import 'package:tictactoe/features/game/domain/repositories/no_mercy_run_repository.dart';
import 'package:tictactoe/features/game/domain/services/no_mercy_run_rules.dart';
import 'package:tictactoe/features/game/domain/usecases/save_no_mercy_run_for_continue.dart';

void main() {
  test('ignores non No Mercy sessions', () async {
    final repository = _FakeNoMercyRunRepository();
    final useCase = SaveNoMercyRunForContinue(repository: repository);

    final saved = await useCase(GameSession.newGame(GameSetup.guidedTrial()));

    expect(saved, isFalse);
    expect(repository.savedSession, isNull);
  });

  test('saves the next boss after a No Mercy boss defeat', () async {
    final repository = _FakeNoMercyRunRepository();
    final useCase = SaveNoMercyRunForContinue(repository: repository);
    final defeatedRadahn =
        GameSession.newGame(GameSetup.noMercy(CpuBossId.radahn)).copyWith(
          result: const GameResult.win(winner: Mark.x, winningCells: [0, 1, 2]),
        );

    final saved = await useCase(defeatedRadahn);

    expect(saved, isTrue);
    expect(repository.savedSession?.bossId, CpuBossId.mohg);
    expect(repository.savedSession?.result.isOngoing, isTrue);
  });

  test('does not save a completed max-cycle run', () async {
    final repository = _FakeNoMercyRunRepository();
    final useCase = SaveNoMercyRunForContinue(repository: repository);
    final completedRun =
        GameSession.newGame(
          GameSetup.noMercy(CpuBossId.malenia, noMercyCycle: maxNoMercyCycle),
        ).copyWith(
          result: const GameResult.win(winner: Mark.x, winningCells: [0, 1, 2]),
        );

    final saved = await useCase(completedRun);

    expect(saved, isFalse);
    expect(repository.savedSession, isNull);
  });
}

final class _FakeNoMercyRunRepository implements NoMercyRunRepository {
  GameSession? savedSession;

  @override
  Future<void> clear() async {}

  @override
  Future<GameSession?> load() async => savedSession;

  @override
  Future<void> save(GameSession session) async {
    savedSession = session;
  }
}
