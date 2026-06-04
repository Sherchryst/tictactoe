import 'package:tictactoe/core/async/serial_task_queue.dart';
import 'package:tictactoe/features/game/data/datasources/local_scoreboard_data_source.dart';
import 'package:tictactoe/features/game/data/models/scoreboard_dto.dart';
import 'package:tictactoe/features/game/domain/entities/cpu_boss.dart';
import 'package:tictactoe/features/game/domain/entities/game_result.dart';
import 'package:tictactoe/features/game/domain/entities/scoreboard.dart';
import 'package:tictactoe/features/game/domain/repositories/scoreboard_repository.dart';

final class LocalScoreboardRepository implements ScoreboardRepository {
  LocalScoreboardRepository(this._dataSource);

  final LocalScoreboardDataSource _dataSource;
  final _mutationQueue = SerialTaskQueue();

  @override
  Future<Scoreboard> load() async {
    await _mutationQueue.waitForIdle();
    return _loadNow();
  }

  @override
  Future<Scoreboard> record(CpuBossId bossId, GameOutcome outcome) {
    return _enqueueMutation(() async {
      final currentScoreboard = await _loadNow();
      final nextScoreboard = currentScoreboard.record(bossId, outcome);
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
    return _mutationQueue.enqueue(operation);
  }
}
