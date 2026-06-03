import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mockito/mockito.dart';
import 'package:tictactoe/core/assets/app_assets.dart';
import 'package:tictactoe/features/game/data/services/game_audio_controller.dart';
import 'package:tictactoe/features/game/domain/entities/game_audio_settings.dart';
import 'package:tictactoe/features/game/domain/entities/music_track.dart';

import 'package:tictactoe/testing/mock_stubs.dart';
import 'package:tictactoe/testing/mocks.mocks.dart';
import 'package:tictactoe/testing/provider_container_factory.dart';

void main() {
  ProviderContainer createContainer({
    required MockAudioSettingsRepository repository,
    required MockMusicPlayer musicPlayer,
    MockSfxPlayer? sfxPlayer,
  }) {
    final resolvedSfxPlayer = sfxPlayer ?? MockSfxPlayer();
    stubMusicPlayer(musicPlayer);
    stubSfxPlayer(resolvedSfxPlayer);

    return createTestContainer(
      registerTearDown: addTearDown,
      overrides: [
        localAudioSettingsRepositoryProvider.overrideWithValue(repository),
        musicPlayerProvider.overrideWithValue(musicPlayer),
        sfxPlayerProvider.overrideWithValue(resolvedSfxPlayer),
      ],
    );
  }

  group('GameAudioController', () {
    test(
      'does not play a pending track when loaded settings disable music',
      () async {
        final settingsLoad = Completer<GameAudioSettings>();
        final repository = MockAudioSettingsRepository();
        final musicPlayer = MockMusicPlayer();
        stubAudioSettingsRepository(repository, load: settingsLoad.future);
        final container = createContainer(
          repository: repository,
          musicPlayer: musicPlayer,
        );
        final controller = container.read(gameAudioControllerProvider.notifier);

        await controller.playTrack(MusicTrack.menu);
        verifyNever(
          musicPlayer.play(
            any,
            targetVolume: anyNamed('targetVolume'),
            transitionDuration: anyNamed('transitionDuration'),
          ),
        );

        settingsLoad.complete(const GameAudioSettings(musicEnabled: false));
        await container.pump();
        await Future<void>.delayed(Duration.zero);

        verifyNever(
          musicPlayer.play(
            any,
            targetVolume: anyNamed('targetVolume'),
            transitionDuration: anyNamed('transitionDuration'),
          ),
        );
        verify(
          musicPlayer.pause(fadeDuration: anyNamed('fadeDuration')),
        ).called(1);
      },
    );

    test(
      'plays the pending track after settings load when music is enabled',
      () async {
        final settingsLoad = Completer<GameAudioSettings>();
        final repository = MockAudioSettingsRepository();
        final musicPlayer = MockMusicPlayer();
        stubAudioSettingsRepository(repository, load: settingsLoad.future);
        final container = createContainer(
          repository: repository,
          musicPlayer: musicPlayer,
        );
        final controller = container.read(gameAudioControllerProvider.notifier);

        await controller.playTrack(MusicTrack.game);
        verifyNever(
          musicPlayer.play(
            any,
            targetVolume: anyNamed('targetVolume'),
            transitionDuration: anyNamed('transitionDuration'),
          ),
        );

        settingsLoad.complete(const GameAudioSettings());
        await container.pump();
        await Future<void>.delayed(Duration.zero);

        verify(
          musicPlayer.play(
            AppAssets.gameMusic,
            targetVolume: GameAudioSettings.defaultMusicVolume,
            transitionDuration: anyNamed('transitionDuration'),
          ),
        ).called(1);
      },
    );
  });
}
