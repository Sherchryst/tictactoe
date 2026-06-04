import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tictactoe/core/di/storage_providers.dart';
import 'package:tictactoe/features/game/data/datasources/local_no_mercy_run_data_source.dart';
import 'package:tictactoe/features/game/data/datasources/local_scoreboard_data_source.dart';
import 'package:tictactoe/features/game/data/repositories/local_no_mercy_run_repository.dart';
import 'package:tictactoe/features/game/data/repositories/local_scoreboard_repository.dart';
import 'package:tictactoe/features/game/domain/repositories/no_mercy_run_repository.dart';
import 'package:tictactoe/features/game/domain/repositories/scoreboard_repository.dart';
import 'package:tictactoe/features/game/domain/services/cpu_strategy_resolver.dart';
import 'package:tictactoe/features/game/domain/services/no_mercy_run_progression.dart';
import 'package:tictactoe/features/game/domain/usecases/clear_no_mercy_run.dart';
import 'package:tictactoe/features/game/domain/usecases/load_no_mercy_run.dart';
import 'package:tictactoe/features/game/domain/usecases/load_scoreboard.dart';
import 'package:tictactoe/features/game/domain/usecases/play_cpu_turn.dart';
import 'package:tictactoe/features/game/domain/usecases/play_human_move.dart';
import 'package:tictactoe/features/game/domain/usecases/play_move.dart';
import 'package:tictactoe/features/game/domain/usecases/record_game_outcome.dart';
import 'package:tictactoe/features/game/domain/usecases/record_no_mercy_outcome.dart';
import 'package:tictactoe/features/game/domain/usecases/reset_scoreboard.dart';
import 'package:tictactoe/features/game/domain/usecases/save_no_mercy_run.dart';
import 'package:tictactoe/features/game/domain/usecases/save_no_mercy_run_for_continue.dart';
import 'package:tictactoe/features/game/domain/usecases/start_game.dart';
import 'package:tictactoe/features/game/domain/usecases/start_new_round.dart';

part 'game_dependencies.g.dart';

@Riverpod(keepAlive: true)
LocalScoreboardDataSource localScoreboardDataSource(Ref ref) {
  return LocalScoreboardDataSource(ref.watch(keyValueStorageProvider));
}

@Riverpod(keepAlive: true)
ScoreboardRepository scoreboardRepository(Ref ref) {
  return LocalScoreboardRepository(
    ref.watch(localScoreboardDataSourceProvider),
  );
}

@Riverpod(keepAlive: true)
LocalNoMercyRunDataSource localNoMercyRunDataSource(Ref ref) {
  return LocalNoMercyRunDataSource(ref.watch(keyValueStorageProvider));
}

@Riverpod(keepAlive: true)
NoMercyRunRepository noMercyRunRepository(Ref ref) {
  return LocalNoMercyRunRepository(
    ref.watch(localNoMercyRunDataSourceProvider),
  );
}

@Riverpod(keepAlive: true)
CpuStrategyResolver cpuStrategyResolver(Ref ref) => CpuStrategyResolver();

@Riverpod(keepAlive: true)
NoMercyRunProgression noMercyRunProgression(Ref ref) {
  return const NoMercyRunProgression();
}

@Riverpod(keepAlive: true)
PlayMove playMove(Ref ref) => const PlayMove();

@Riverpod(keepAlive: true)
PlayCpuTurn playCpuTurn(Ref ref) {
  return PlayCpuTurn(
    playMove: ref.watch(playMoveProvider),
    strategyResolver: ref.watch(cpuStrategyResolverProvider),
  );
}

@Riverpod(keepAlive: true)
PlayHumanMove playHumanMove(Ref ref) {
  return PlayHumanMove(playMove: ref.watch(playMoveProvider));
}

@Riverpod(keepAlive: true)
StartGame startGame(Ref ref) => const StartGame();

@Riverpod(keepAlive: true)
StartNewRound startNewRound(Ref ref) => const StartNewRound();

@Riverpod(keepAlive: true)
LoadScoreboard loadScoreboard(Ref ref) {
  return LoadScoreboard(ref.watch(scoreboardRepositoryProvider));
}

@Riverpod(keepAlive: true)
LoadNoMercyRun loadNoMercyRun(Ref ref) {
  return LoadNoMercyRun(ref.watch(noMercyRunRepositoryProvider));
}

@Riverpod(keepAlive: true)
SaveNoMercyRun saveNoMercyRun(Ref ref) {
  return SaveNoMercyRun(ref.watch(noMercyRunRepositoryProvider));
}

@Riverpod(keepAlive: true)
SaveNoMercyRunForContinue saveNoMercyRunForContinue(Ref ref) {
  return SaveNoMercyRunForContinue(
    repository: ref.watch(noMercyRunRepositoryProvider),
    progression: ref.watch(noMercyRunProgressionProvider),
  );
}

@Riverpod(keepAlive: true)
ClearNoMercyRun clearNoMercyRun(Ref ref) {
  return ClearNoMercyRun(ref.watch(noMercyRunRepositoryProvider));
}

@Riverpod(keepAlive: true)
RecordGameOutcome recordGameOutcome(Ref ref) {
  return RecordGameOutcome(ref.watch(scoreboardRepositoryProvider));
}

@Riverpod(keepAlive: true)
RecordNoMercyOutcome recordNoMercyOutcome(Ref ref) {
  return RecordNoMercyOutcome(ref.watch(scoreboardRepositoryProvider));
}

@Riverpod(keepAlive: true)
ResetScoreboard resetScoreboard(Ref ref) {
  return ResetScoreboard(ref.watch(scoreboardRepositoryProvider));
}
