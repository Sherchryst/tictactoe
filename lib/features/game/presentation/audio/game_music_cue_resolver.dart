import 'package:tictactoe/core/audio/domain/entities/music_track.dart';
import 'package:tictactoe/features/game/domain/entities/cpu_boss.dart';
import 'package:tictactoe/features/game/domain/entities/game_session.dart';

final class GameMusicCueResolver {
  const GameMusicCueResolver();

  MusicTrack trackFor(GameSession session) {
    return switch (session.bossId) {
      CpuBossId.guided => MusicTrack.recusants,
      CpuBossId.radahn => MusicTrack.radahn,
      CpuBossId.mohg => MusicTrack.mohg,
      CpuBossId.malenia => MusicTrack.malenia,
    };
  }
}
