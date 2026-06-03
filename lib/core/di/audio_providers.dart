import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:tictactoe/core/audio/domain/entities/audio_preferences.dart';
import 'package:tictactoe/core/audio/domain/services/audio_controller.dart';
import 'package:tictactoe/core/audio/domain/services/audio_preferences_controller.dart';
import 'package:tictactoe/core/audio/infrastructure/app_audio_controller.dart';

part 'audio_providers.g.dart';

@Riverpod(keepAlive: true)
AudioController audioController(Ref ref) {
  return ref.watch(appAudioControllerProvider.notifier);
}

@Riverpod(keepAlive: true)
AudioPreferencesController audioPreferencesController(Ref ref) {
  return ref.watch(appAudioControllerProvider.notifier);
}

@Riverpod(keepAlive: true)
AudioPreferences audioPreferences(Ref ref) {
  return ref.watch(appAudioControllerProvider);
}
