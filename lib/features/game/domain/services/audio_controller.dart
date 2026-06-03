import 'package:tictactoe/features/game/domain/entities/menu_sfx.dart';
import 'package:tictactoe/features/game/domain/entities/music_track.dart';

abstract interface class AudioController {
  Future<void> playTrack(MusicTrack track);

  Future<void> prepareGame();

  Future<void> playMenuSfx(MenuSfx intent);

  Future<void> pauseMusic();

  Future<void> stopMusic();

  void setMusicEnabled(bool enabled);

  void setSfxEnabled(bool enabled);

  void setMusicVolume(double volume);

  void setSfxVolume(double volume);

  Future<void> playMove({required bool isPlayerX});

  Future<void> playParry();

  Future<void> playVictory();

  Future<void> playDeathIntro();

  Future<void> playDeath();

  Future<void> playDraw();

  Future<void> playRestart();
}
