import 'package:tictactoe/features/game/data/datasources/local_game_preferences_data_source.dart';
import 'package:tictactoe/features/game/data/models/scoreboard_dto.dart';
import 'package:tictactoe/features/game/domain/entities/game_result.dart';
import 'package:tictactoe/features/game/domain/entities/scoreboard.dart';
import 'package:tictactoe/features/game/domain/repositories/scoreboard_repository.dart';

final class LocalScoreboardRepository implements ScoreboardRepository {
  LocalScoreboardRepository(this._dataSource);

  final LocalGamePreferencesDataSource _dataSource;
  Future<void> _mutationQueue = Future<void>.value();

  @override
  Future<Scoreboard> load() async {
    await _mutationQueue;
    return _loadNow();
  }

  @override
  Future<Scoreboard> record(GameOutcome outcome) {
    return _enqueueMutation(() async {
      final currentScoreboard = await _loadNow();
      final nextScoreboard = currentScoreboard.record(outcome);
      await _saveNow(nextScoreboard);
      return nextScoreboard;
    });
  }

  @override
  Future<void> reset() {
    return _enqueueMutation(_dataSource.resetScoreboard);
  }

  @override
  Future<void> save(Scoreboard scoreboard) {
    return _enqueueMutation(() => _saveNow(scoreboard));
  }

  Future<Scoreboard> _loadNow() async {
    final scoreboard = await _dataSource.loadScoreboard();
    return scoreboard?.toDomain() ?? Scoreboard.empty();
  }

  Future<void> _saveNow(Scoreboard scoreboard) {
    return _dataSource.saveScoreboard(ScoreboardDto.fromDomain(scoreboard));
  }

  Future<T> _enqueueMutation<T>(Future<T> Function() operation) {
    final queued = _mutationQueue.then((_) => operation());
    _mutationQueue = queued.then<void>((_) {}, onError: (_) {});
    return queued;
  }
}
