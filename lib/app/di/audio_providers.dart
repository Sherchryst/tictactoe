import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:tictactoe/features/game/data/services/game_audio_controller.dart';
import 'package:tictactoe/features/game/domain/entities/game_audio_settings.dart';
import 'package:tictactoe/features/game/domain/services/audio_controller.dart';

part 'audio_providers.g.dart';

@Riverpod(keepAlive: true)
AudioController audioController(Ref ref) {
  return ref.watch(gameAudioControllerProvider.notifier);
}

@Riverpod(keepAlive: true)
GameAudioSettings audioSettings(Ref ref) {
  return ref.watch(gameAudioControllerProvider);
}
