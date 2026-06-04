import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tictactoe/core/di/game_dependencies.dart';
import 'package:tictactoe/features/game/domain/entities/game_session.dart';

part 'no_mercy_run_persistence.g.dart';

final class NoMercyRunPersistence {
  const NoMercyRunPersistence(this._ref);

  final Ref _ref;

  Future<bool> saveForContinue(GameSession session) {
    return _ref.read(saveNoMercyRunForContinueProvider).call(session);
  }

  Future<void> clear() {
    return _ref.read(clearNoMercyRunProvider).call();
  }
}

@Riverpod(keepAlive: true)
NoMercyRunPersistence noMercyRunPersistence(Ref ref) {
  return NoMercyRunPersistence(ref);
}
