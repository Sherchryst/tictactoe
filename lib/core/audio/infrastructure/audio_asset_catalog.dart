import 'package:tictactoe/core/assets/audio_assets.dart';
import 'package:tictactoe/core/audio/domain/entities/menu_sfx.dart';
import 'package:tictactoe/core/audio/domain/entities/music_track.dart';

final class AudioTrackBinding {
  const AudioTrackBinding({
    required this.asset,
    required this.transitionDuration,
    this.startAt = Duration.zero,
  });

  final String asset;
  final Duration transitionDuration;
  final Duration startAt;
}

final class AudioSfxBinding {
  const AudioSfxBinding(this.asset, this.volumeMultiplier);

  final String asset;
  final double volumeMultiplier;
}

final class AudioAssetCatalog {
  const AudioAssetCatalog();

  static const _menuTransition = Duration(milliseconds: 420);
  static const _gameTransition = Duration(milliseconds: 900);
  static const _menuStartOffset = Duration(seconds: 12);

  static const _trackBindings = <MusicTrack, AudioTrackBinding>{
    MusicTrack.menu: AudioTrackBinding(
      asset: AudioAssets.musicLoop,
      transitionDuration: _menuTransition,
      startAt: _menuStartOffset,
    ),
    MusicTrack.recusants: AudioTrackBinding(
      asset: AudioAssets.recusantsMusic,
      transitionDuration: _gameTransition,
    ),
    MusicTrack.radahn: AudioTrackBinding(
      asset: AudioAssets.radahnMusic,
      transitionDuration: _gameTransition,
    ),
    MusicTrack.mohg: AudioTrackBinding(
      asset: AudioAssets.mohgMusic,
      transitionDuration: _gameTransition,
    ),
    MusicTrack.malenia: AudioTrackBinding(
      asset: AudioAssets.maleniaMusic,
      transitionDuration: _gameTransition,
    ),
  };

  static const _menuSfxBindings = <MenuSfx, AudioSfxBinding>{
    MenuSfx.select: AudioSfxBinding(AudioAssets.selection, 0.78),
    MenuSfx.activate: AudioSfxBinding(AudioAssets.titleStart, 0.86),
    MenuSfx.reset: AudioSfxBinding(AudioAssets.restartGrace, 0.86),
  };

  static const warmUpAssets = <String>[
    AudioAssets.titleStart,
    AudioAssets.selection,
    AudioAssets.parry,
    AudioAssets.victory,
    AudioAssets.deathIntro,
    AudioAssets.death,
    AudioAssets.criticalHit,
    AudioAssets.slashSword,
    AudioAssets.flaskUse,
    AudioAssets.maleniaVictoryLine,
    AudioAssets.restartGrace,
  ];

  static const humanMark = AudioSfxBinding(AudioAssets.flaskUse, 0.58);
  static const cpuMark = AudioSfxBinding(AudioAssets.slashSword, 0.72);
  static const maleniaVictoryLine = AudioSfxBinding(
    AudioAssets.maleniaVictoryLine,
    0.94,
  );
  static const parry = AudioSfxBinding(AudioAssets.parry, 0.74);
  static const victory = AudioSfxBinding(AudioAssets.victory, 0.9);
  static const deathIntro = AudioSfxBinding(AudioAssets.deathIntro, 0.86);
  static const death = AudioSfxBinding(AudioAssets.death, 0.92);
  static const draw = AudioSfxBinding(AudioAssets.criticalHit, 0.86);

  AudioTrackBinding track(MusicTrack track) => _trackBindings[track]!;

  AudioSfxBinding menuSfx(MenuSfx intent) => _menuSfxBindings[intent]!;
}
