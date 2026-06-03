// ignore_for_file: depend_on_referenced_packages

import 'package:mockito/annotations.dart';
import 'package:tictactoe/core/audio/domain/repositories/audio_preferences_repository.dart';
import 'package:tictactoe/core/audio/domain/services/audio_controller.dart';
import 'package:tictactoe/core/audio/infrastructure/music_player.dart';
import 'package:tictactoe/core/audio/infrastructure/sfx_player.dart';
import 'package:tictactoe/core/storage/key_value_storage.dart';
import 'package:tictactoe/features/game/domain/repositories/scoreboard_repository.dart';
import 'package:tictactoe/features/game/domain/services/cpu_strategy.dart';
import 'package:tictactoe/features/settings/domain/repositories/app_preferences_repository.dart';

@GenerateNiceMocks([
  MockSpec<AppPreferencesRepository>(),
  MockSpec<AudioController>(),
  MockSpec<AudioPreferencesRepository>(),
  MockSpec<CpuStrategy>(),
  MockSpec<KeyValueStorage>(),
  MockSpec<MusicPlayer>(),
  MockSpec<ScoreboardRepository>(),
  MockSpec<SfxPlayer>(),
])
void main() {}
