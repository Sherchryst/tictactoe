import 'package:audio_session/audio_session.dart';

import 'package:tictactoe/core/logging/app_logger.dart';

final class AudioSessionConfigurator {
  AudioSessionConfigurator({
    AudioSessionConfiguration configuration =
        const AudioSessionConfiguration.music(),
  }) : _configuration = configuration;

  final AudioSessionConfiguration _configuration;
  bool _configured = false;

  Future<void> configure() async {
    if (_configured) {
      return;
    }

    try {
      final session = await AudioSession.instance;
      await session.configure(_configuration);
      _configured = true;
    } catch (error, stackTrace) {
      AppLogger.warning(
        'Audio session could not be configured.',
        name: 'tictactoe.audio.session',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }
}
