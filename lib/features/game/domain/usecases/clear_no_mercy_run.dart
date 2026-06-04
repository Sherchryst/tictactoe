import 'package:tictactoe/features/game/domain/repositories/no_mercy_run_repository.dart';

final class ClearNoMercyRun {
  const ClearNoMercyRun(this._repository);

  final NoMercyRunRepository _repository;

  Future<void> call() => _repository.clear();
}
