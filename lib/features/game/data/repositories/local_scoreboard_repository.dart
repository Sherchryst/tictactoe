import '../../domain/entities/scoreboard.dart';
import '../../domain/repositories/scoreboard_repository.dart';
import '../datasources/local_game_preferences_data_source.dart';
import '../models/scoreboard_dto.dart';

final class LocalScoreboardRepository implements ScoreboardRepository {
  const LocalScoreboardRepository(this._dataSource);

  final LocalGamePreferencesDataSource _dataSource;

  @override
  Future<Scoreboard> load() async {
    final scoreboard = await _dataSource.loadScoreboard();
    return scoreboard?.toDomain() ?? Scoreboard.empty();
  }

  @override
  Future<void> reset() {
    return _dataSource.resetScoreboard();
  }

  @override
  Future<void> save(Scoreboard scoreboard) {
    return _dataSource.saveScoreboard(ScoreboardDto.fromDomain(scoreboard));
  }
}
