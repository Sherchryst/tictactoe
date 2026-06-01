import '../entities/scoreboard.dart';

abstract interface class ScoreboardRepository {
  Future<Scoreboard> load();

  Future<void> save(Scoreboard scoreboard);

  Future<void> reset();
}
