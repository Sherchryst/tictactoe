import '../entities/game_outcome.dart';
import '../entities/scoreboard.dart';
import '../repositories/scoreboard_repository.dart';

final class RecordGameOutcome {
  const RecordGameOutcome(this._repository);

  final ScoreboardRepository _repository;

  Future<Scoreboard> call(GameOutcome outcome) async {
    final currentScoreboard = await _repository.load();
    final nextScoreboard = currentScoreboard.record(outcome);
    await _repository.save(nextScoreboard);
    return nextScoreboard;
  }
}
