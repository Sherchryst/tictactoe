import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mockito/mockito.dart';
import 'package:tictactoe/core/audio/domain/entities/audio_preferences.dart';
import 'package:tictactoe/core/audio/domain/entities/music_track.dart';
import 'package:tictactoe/core/audio/infrastructure/app_audio_controller.dart';
import 'package:tictactoe/core/design_system/tokens/app_assets.dart';
import 'package:tictactoe/core/di/audio_dependencies.dart';

import '../../../testing/mock_stubs.dart';
import '../../../testing/mocks.mocks.dart';
import '../../../testing/provider_container_factory.dart';

void main() {
  ProviderContainer createContainer({
    required MockAudioPreferencesRepository repository,
    required MockMusicPlayer musicPlayer,
    MockSfxPlayer? sfxPlayer,
  }) {
    final resolvedSfxPlayer = sfxPlayer ?? MockSfxPlayer();
    stubMusicPlayer(musicPlayer);
    stubSfxPlayer(resolvedSfxPlayer);

    return createTestContainer(
      registerTearDown: addTearDown,
      overrides: [
        localAudioPreferencesRepositoryProvider.overrideWithValue(repository),
        musicPlayerProvider.overrideWithValue(musicPlayer),
        sfxPlayerProvider.overrideWithValue(resolvedSfxPlayer),
      ],
    );
  }

  group('AppAudioController', () {
    test(
      'does not play a pending track when loaded settings disable music',
      () async {
        final settingsLoad = Completer<AudioPreferences>();
        final repository = MockAudioPreferencesRepository();
        final musicPlayer = MockMusicPlayer();
        stubAudioPreferencesRepository(repository, load: settingsLoad.future);
        final container = createContainer(
          repository: repository,
          musicPlayer: musicPlayer,
        );
        final controller = container.read(appAudioControllerProvider.notifier);

        await controller.playTrack(MusicTrack.menu);
        verifyNever(
          musicPlayer.play(
            any,
            targetVolume: anyNamed('targetVolume'),
            transitionDuration: anyNamed('transitionDuration'),
          ),
        );

        settingsLoad.complete(const AudioPreferences(musicEnabled: false));
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
        final settingsLoad = Completer<AudioPreferences>();
        final repository = MockAudioPreferencesRepository();
        final musicPlayer = MockMusicPlayer();
        stubAudioPreferencesRepository(repository, load: settingsLoad.future);
        final container = createContainer(
          repository: repository,
          musicPlayer: musicPlayer,
        );
        final controller = container.read(appAudioControllerProvider.notifier);

        await controller.playTrack(MusicTrack.game);
        verifyNever(
          musicPlayer.play(
            any,
            targetVolume: anyNamed('targetVolume'),
            transitionDuration: anyNamed('transitionDuration'),
          ),
        );

        settingsLoad.complete(const AudioPreferences());
        await container.pump();
        await Future<void>.delayed(Duration.zero);

        verify(
          musicPlayer.play(
            AppAssets.gameMusic,
            targetVolume: AudioPreferences.defaultMusicVolume,
            transitionDuration: anyNamed('transitionDuration'),
          ),
        ).called(1);
      },
    );
  });
}
