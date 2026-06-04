import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mockito/mockito.dart';
import 'package:tictactoe/core/assets/audio_assets.dart';
import 'package:tictactoe/core/audio/domain/entities/audio_preferences.dart';
import 'package:tictactoe/core/audio/domain/entities/music_track.dart';
import 'package:tictactoe/core/audio/infrastructure/app_audio_controller.dart';
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
            startAt: anyNamed('startAt'),
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
            startAt: anyNamed('startAt'),
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

        await controller.playTrack(MusicTrack.radahn);
        verifyNever(
          musicPlayer.play(
            any,
            targetVolume: anyNamed('targetVolume'),
            transitionDuration: anyNamed('transitionDuration'),
            startAt: anyNamed('startAt'),
          ),
        );

        settingsLoad.complete(const AudioPreferences());
        await container.pump();
        await Future<void>.delayed(Duration.zero);

        verify(
          musicPlayer.play(
            AudioAssets.radahnMusic,
            targetVolume: AudioPreferences.defaultMusicVolume,
            transitionDuration: anyNamed('transitionDuration'),
            startAt: Duration.zero,
          ),
        ).called(1);
      },
    );

    test('starts menu music after the opening 12 seconds', () async {
      final repository = MockAudioPreferencesRepository();
      final musicPlayer = MockMusicPlayer();
      stubAudioPreferencesRepository(repository);
      final container = createContainer(
        repository: repository,
        musicPlayer: musicPlayer,
      );
      final controller = container.read(appAudioControllerProvider.notifier);
      await container.pump();
      await Future<void>.delayed(Duration.zero);
      clearInteractions(musicPlayer);

      await controller.playTrack(MusicTrack.menu);

      verify(
        musicPlayer.play(
          AudioAssets.musicLoop,
          targetVolume: AudioPreferences.defaultMusicVolume,
          transitionDuration: anyNamed('transitionDuration'),
          startAt: const Duration(seconds: 12),
        ),
      ).called(1);
    });

    test(
      'prepares the requested boss track instead of Recusants by default',
      () async {
        final repository = MockAudioPreferencesRepository();
        final musicPlayer = MockMusicPlayer();
        stubAudioPreferencesRepository(repository);
        final container = createContainer(
          repository: repository,
          musicPlayer: musicPlayer,
        );
        final controller = container.read(appAudioControllerProvider.notifier);
        await container.pump();
        await Future<void>.delayed(Duration.zero);
        clearInteractions(musicPlayer);

        await controller.playTrack(MusicTrack.mohg);
        await controller.prepareGame();

        verify(musicPlayer.prepare(AudioAssets.mohgMusic)).called(1);
        verifyNever(musicPlayer.prepare(AudioAssets.recusantsMusic));
      },
    );

    test('resumes the last requested music track', () async {
      final repository = MockAudioPreferencesRepository();
      final musicPlayer = MockMusicPlayer();
      stubAudioPreferencesRepository(repository);
      final container = createContainer(
        repository: repository,
        musicPlayer: musicPlayer,
      );
      final controller = container.read(appAudioControllerProvider.notifier);
      await container.pump();
      await Future<void>.delayed(Duration.zero);

      await controller.playTrack(MusicTrack.mohg);
      clearInteractions(musicPlayer);

      await controller.resumeMusic();

      verify(
        musicPlayer.play(
          AudioAssets.mohgMusic,
          targetVolume: AudioPreferences.defaultMusicVolume,
          transitionDuration: anyNamed('transitionDuration'),
          startAt: Duration.zero,
        ),
      ).called(1);
    });

    test('prepares Recusants by default for non-boss fights', () async {
      final repository = MockAudioPreferencesRepository();
      final musicPlayer = MockMusicPlayer();
      stubAudioPreferencesRepository(repository);
      final container = createContainer(
        repository: repository,
        musicPlayer: musicPlayer,
      );
      final controller = container.read(appAudioControllerProvider.notifier);
      await container.pump();
      await Future<void>.delayed(Duration.zero);
      clearInteractions(musicPlayer);

      await controller.prepareGame();

      verify(musicPlayer.prepare(AudioAssets.recusantsMusic)).called(1);
    });
  });
}
