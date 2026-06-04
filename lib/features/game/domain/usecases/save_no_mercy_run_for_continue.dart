import 'package:tictactoe/features/game/domain/entities/game_session.dart';
import 'package:tictactoe/features/game/domain/repositories/no_mercy_run_repository.dart';
import 'package:tictactoe/features/game/domain/services/no_mercy_run_progression.dart';

final class SaveNoMercyRunForContinue {
  const SaveNoMercyRunForContinue({
    required NoMercyRunRepository repository,
    NoMercyRunProgression progression = const NoMercyRunProgression(),
  }) : _repository = repository,
       _progression = progression;

  final NoMercyRunRepository _repository;
  final NoMercyRunProgression _progression;

  Future<bool> call(GameSession session) async {
    if (!session.isNoMercy) {
      return false;
    }

    final persistedSession = _progression.sessionForContinue(session);
    if (persistedSession == null) {
      return false;
    }

    await _repository.save(persistedSession);
    return true;
  }
}
