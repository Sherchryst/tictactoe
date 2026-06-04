import 'package:tictactoe/features/game/domain/entities/game_session.dart';
import 'package:tictactoe/features/game/domain/entities/scoreboard.dart';
import 'package:tictactoe/features/game/domain/repositories/scoreboard_repository.dart';

final class RecordNoMercyOutcome {
  const RecordNoMercyOutcome(this._repository);

  final ScoreboardRepository _repository;

  Future<Scoreboard?> call(GameSession session) {
    final outcome = session.participantOutcome;
    if (!session.isNoMercy || outcome == null) {
      return Future.value();
    }

    return _repository.record(session.bossId, outcome);
  }
}
