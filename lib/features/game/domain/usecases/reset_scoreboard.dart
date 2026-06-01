import '../repositories/scoreboard_repository.dart';

final class ResetScoreboard {
  const ResetScoreboard(this._repository);

  final ScoreboardRepository _repository;

  Future<void> call() {
    return _repository.reset();
  }
}
