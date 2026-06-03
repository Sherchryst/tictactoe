import 'package:tictactoe/features/game/domain/entities/game_result.dart';
import 'package:tictactoe/features/game/domain/entities/scoreboard.dart';
import 'package:tictactoe/features/game/domain/repositories/scoreboard_repository.dart';

final class RecordGameOutcome {
  const RecordGameOutcome(this._repository);

  final ScoreboardRepository _repository;

  Future<Scoreboard> call(GameOutcome outcome) {
    return _repository.record(outcome);
  }
}
