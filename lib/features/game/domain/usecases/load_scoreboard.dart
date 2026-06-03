import 'package:tictactoe/features/game/domain/entities/scoreboard.dart';
import 'package:tictactoe/features/game/domain/repositories/scoreboard_repository.dart';

final class LoadScoreboard {
  const LoadScoreboard(this._repository);

  final ScoreboardRepository _repository;

  Future<Scoreboard> call() => _repository.load();
}
