import 'package:tictactoe/core/async/serial_task_queue.dart';
import 'package:tictactoe/features/game/data/datasources/local_no_mercy_run_data_source.dart';
import 'package:tictactoe/features/game/data/models/no_mercy_run_dto.dart';
import 'package:tictactoe/features/game/domain/entities/game_session.dart';
import 'package:tictactoe/features/game/domain/repositories/no_mercy_run_repository.dart';

final class LocalNoMercyRunRepository implements NoMercyRunRepository {
  LocalNoMercyRunRepository(this._dataSource);

  final LocalNoMercyRunDataSource _dataSource;
  final _mutationQueue = SerialTaskQueue();

  @override
  Future<GameSession?> load() async {
    await _mutationQueue.waitForIdle();
    final run = await _dataSource.loadRun();
    return run?.toDomain();
  }

  @override
  Future<void> save(GameSession session) {
    return _enqueueMutation(
      () => _dataSource.saveRun(NoMercyRunDto.fromDomain(session)),
    );
  }

  @override
  Future<void> clear() {
    return _enqueueMutation(_dataSource.clearRun);
  }

  Future<T> _enqueueMutation<T>(Future<T> Function() operation) {
    return _mutationQueue.enqueue(operation);
  }
}
