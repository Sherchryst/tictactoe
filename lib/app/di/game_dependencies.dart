import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:tictactoe/core/storage/storage_providers.dart';
import 'package:tictactoe/features/game/data/datasources/local_game_preferences_data_source.dart';
import 'package:tictactoe/features/game/data/repositories/local_app_preferences_repository.dart';
import 'package:tictactoe/features/game/data/repositories/local_scoreboard_repository.dart';
import 'package:tictactoe/features/game/domain/repositories/app_preferences_repository.dart';
import 'package:tictactoe/features/game/domain/repositories/scoreboard_repository.dart';
import 'package:tictactoe/features/game/domain/services/cpu_strategy_resolver.dart';
import 'package:tictactoe/features/game/domain/usecases/load_preferences.dart';
import 'package:tictactoe/features/game/domain/usecases/load_scoreboard.dart';
import 'package:tictactoe/features/game/domain/usecases/play_cpu_turn.dart';
import 'package:tictactoe/features/game/domain/usecases/play_human_move.dart';
import 'package:tictactoe/features/game/domain/usecases/play_move.dart';
import 'package:tictactoe/features/game/domain/usecases/record_game_outcome.dart';
import 'package:tictactoe/features/game/domain/usecases/reset_scoreboard.dart';
import 'package:tictactoe/features/game/domain/usecases/save_preferences.dart';
import 'package:tictactoe/features/game/domain/usecases/start_game.dart';
import 'package:tictactoe/features/game/domain/usecases/start_new_round.dart';

export 'package:tictactoe/core/storage/storage_providers.dart';

part 'game_dependencies.g.dart';

@Riverpod(keepAlive: true)
LocalGamePreferencesDataSource localGamePreferencesDataSource(Ref ref) {
  return LocalGamePreferencesDataSource(ref.watch(keyValueStorageProvider));
}

@Riverpod(keepAlive: true)
AppPreferencesRepository appPreferencesRepository(Ref ref) {
  return LocalAppPreferencesRepository(
    ref.watch(localGamePreferencesDataSourceProvider),
  );
}

@Riverpod(keepAlive: true)
ScoreboardRepository scoreboardRepository(Ref ref) {
  return LocalScoreboardRepository(
    ref.watch(localGamePreferencesDataSourceProvider),
  );
}

@Riverpod(keepAlive: true)
CpuStrategyResolver cpuStrategyResolver(Ref ref) => CpuStrategyResolver();

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
  return PlayHumanMove(
    playMove: ref.watch(playMoveProvider),
    playCpuTurn: ref.watch(playCpuTurnProvider),
  );
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
RecordGameOutcome recordGameOutcome(Ref ref) {
  return RecordGameOutcome(ref.watch(scoreboardRepositoryProvider));
}

@Riverpod(keepAlive: true)
ResetScoreboard resetScoreboard(Ref ref) {
  return ResetScoreboard(ref.watch(scoreboardRepositoryProvider));
}

@Riverpod(keepAlive: true)
LoadPreferences loadPreferences(Ref ref) {
  return LoadPreferences(ref.watch(appPreferencesRepositoryProvider));
}

@Riverpod(keepAlive: true)
SavePreferences savePreferences(Ref ref) {
  return SavePreferences(ref.watch(appPreferencesRepositoryProvider));
}
