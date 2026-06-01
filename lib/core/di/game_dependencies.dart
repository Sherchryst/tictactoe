import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/game/data/datasources/local_game_preferences_data_source.dart';
import '../../features/game/data/repositories/local_game_settings_repository.dart';
import '../../features/game/data/repositories/local_scoreboard_repository.dart';
import '../../features/game/domain/repositories/game_settings_repository.dart';
import '../../features/game/domain/repositories/scoreboard_repository.dart';
import '../../features/game/domain/usecases/load_game_settings.dart';
import '../../features/game/domain/usecases/load_scoreboard.dart';
import '../../features/game/domain/usecases/play_human_move.dart';
import '../../features/game/domain/usecases/record_game_outcome.dart';
import '../../features/game/domain/usecases/reset_scoreboard.dart';
import '../../features/game/domain/usecases/save_game_settings.dart';
import '../../features/game/domain/usecases/start_game.dart';
import '../../features/game/domain/usecases/start_new_round.dart';
import '../storage/key_value_storage.dart';
import '../storage/shared_preferences_key_value_storage.dart';

final sharedPreferencesProvider = Provider<SharedPreferencesAsync>((ref) {
  return SharedPreferencesAsync();
});

final keyValueStorageProvider = Provider<KeyValueStorage>((ref) {
  return SharedPreferencesKeyValueStorage(ref.watch(sharedPreferencesProvider));
});

final localGamePreferencesDataSourceProvider =
    Provider<LocalGamePreferencesDataSource>((ref) {
      return LocalGamePreferencesDataSource(ref.watch(keyValueStorageProvider));
    });

final gameSettingsRepositoryProvider = Provider<GameSettingsRepository>((ref) {
  return LocalGameSettingsRepository(
    ref.watch(localGamePreferencesDataSourceProvider),
  );
});

final scoreboardRepositoryProvider = Provider<ScoreboardRepository>((ref) {
  return LocalScoreboardRepository(
    ref.watch(localGamePreferencesDataSourceProvider),
  );
});

final loadGameSettingsProvider = Provider<LoadGameSettings>((ref) {
  return LoadGameSettings(ref.watch(gameSettingsRepositoryProvider));
});

final saveGameSettingsProvider = Provider<SaveGameSettings>((ref) {
  return SaveGameSettings(ref.watch(gameSettingsRepositoryProvider));
});

final loadScoreboardProvider = Provider<LoadScoreboard>((ref) {
  return LoadScoreboard(ref.watch(scoreboardRepositoryProvider));
});

final recordGameOutcomeProvider = Provider<RecordGameOutcome>((ref) {
  return RecordGameOutcome(ref.watch(scoreboardRepositoryProvider));
});

final resetScoreboardProvider = Provider<ResetScoreboard>((ref) {
  return ResetScoreboard(ref.watch(scoreboardRepositoryProvider));
});

final startGameProvider = Provider<StartGame>((ref) {
  return const StartGame();
});

final startNewRoundProvider = Provider<StartNewRound>((ref) {
  return const StartNewRound();
});

final playHumanMoveProvider = Provider<PlayHumanMove>((ref) {
  return PlayHumanMove();
});
