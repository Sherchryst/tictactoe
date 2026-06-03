// ignore_for_file: depend_on_referenced_packages

import 'package:mockito/mockito.dart';
import 'package:tictactoe/core/audio/domain/entities/audio_preferences.dart';

import 'mocks.mocks.dart';

void stubAudioController(MockAudioController audio) {
  when(
    audio.playMove(isPlayerX: anyNamed('isPlayerX')),
  ).thenAnswer((_) async {});
  when(audio.playParry()).thenAnswer((_) async {});
  when(audio.playVictory()).thenAnswer((_) async {});
  when(audio.playDeathIntro()).thenAnswer((_) async {});
  when(audio.playDeath()).thenAnswer((_) async {});
  when(audio.playDraw()).thenAnswer((_) async {});
  when(audio.playRestart()).thenAnswer((_) async {});
  when(audio.prepareGame()).thenAnswer((_) async {});
  when(audio.pauseMusic()).thenAnswer((_) async {});
  when(audio.stopMusic()).thenAnswer((_) async {});
  when(audio.playTrack(any)).thenAnswer((_) async {});
  when(audio.playMenuSfx(any)).thenAnswer((_) async {});
}

void stubAudioPreferencesRepository(
  MockAudioPreferencesRepository repository, {
  Future<AudioPreferences>? load,
}) {
  provideDummy<AudioPreferences>(const AudioPreferences());
  when(
    repository.load(),
  ).thenAnswer((_) => load ?? Future.value(const AudioPreferences()));
  when(repository.save(any)).thenAnswer((_) async {});
}

void stubMusicPlayer(MockMusicPlayer musicPlayer) {
  when(
    musicPlayer.play(
      any,
      targetVolume: anyNamed('targetVolume'),
      transitionDuration: anyNamed('transitionDuration'),
    ),
  ).thenAnswer((_) async {});
  when(musicPlayer.prepare(any)).thenAnswer((_) async {});
  when(
    musicPlayer.pause(fadeDuration: anyNamed('fadeDuration')),
  ).thenAnswer((_) async {});
  when(
    musicPlayer.stop(fadeDuration: anyNamed('fadeDuration')),
  ).thenAnswer((_) async {});
  when(musicPlayer.setVolume(any)).thenAnswer((_) async {});
  when(musicPlayer.dispose()).thenAnswer((_) async {});
}

void stubSfxPlayer(MockSfxPlayer sfxPlayer) {
  when(
    sfxPlayer.play(any, volume: anyNamed('volume')),
  ).thenAnswer((_) async {});
  when(sfxPlayer.warmUp(any)).thenAnswer((_) async {});
  when(sfxPlayer.dispose()).thenAnswer((_) async {});
}

void stubCpuStrategy(MockCpuStrategy strategy, {required int move}) {
  when(strategy.chooseMove(any, any)).thenReturn(move);
}
