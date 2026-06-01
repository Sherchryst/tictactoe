import '../entities/scoreboard.dart';
import '../repositories/scoreboard_repository.dart';

final class LoadScoreboard {
  const LoadScoreboard(this._repository);

  final ScoreboardRepository _repository;

  Future<Scoreboard> call() {
    return _repository.load();
  }
}
