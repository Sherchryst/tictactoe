import 'package:tictactoe/features/game/domain/entities/game_result.dart';
import 'package:tictactoe/features/game/domain/entities/scoreboard.dart';

abstract interface class ScoreboardRepository {
  Future<Scoreboard> load();

  Future<void> save(Scoreboard scoreboard);

  Future<Scoreboard> record(GameOutcome outcome);

  Future<void> reset();
}
