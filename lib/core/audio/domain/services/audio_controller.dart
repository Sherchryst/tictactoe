import 'package:tictactoe/core/audio/domain/entities/menu_sfx.dart';
import 'package:tictactoe/core/audio/domain/entities/music_track.dart';

abstract interface class AudioController {
  Future<void> playTrack(MusicTrack track);

  Future<void> prepareGame();

  Future<void> playMenuSfx(MenuSfx intent);

  Future<void> pauseMusic();

  Future<void> stopMusic();

  Future<void> playHumanMark();

  Future<void> playCpuMark();

  Future<void> playMaleniaVictoryLine();

  Future<void> playParry();

  Future<void> playVictory();

  Future<void> playDeathIntro();

  Future<void> playDeath();

  Future<void> playDraw();

  Future<void> playRestart();
}
