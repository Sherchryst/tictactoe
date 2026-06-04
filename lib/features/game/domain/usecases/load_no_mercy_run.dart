import 'package:tictactoe/features/game/domain/entities/game_session.dart';
import 'package:tictactoe/features/game/domain/repositories/no_mercy_run_repository.dart';

final class LoadNoMercyRun {
  const LoadNoMercyRun(this._repository);

  final NoMercyRunRepository _repository;

  Future<GameSession?> call() => _repository.load();
}
