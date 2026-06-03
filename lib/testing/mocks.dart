// ignore_for_file: depend_on_referenced_packages

import 'package:mockito/annotations.dart';
import 'package:tictactoe/core/storage/key_value_storage.dart';
import 'package:tictactoe/features/game/domain/repositories/app_preferences_repository.dart';
import 'package:tictactoe/features/game/domain/repositories/audio_settings_repository.dart';
import 'package:tictactoe/features/game/domain/repositories/scoreboard_repository.dart';
import 'package:tictactoe/features/game/domain/services/audio_controller.dart';
import 'package:tictactoe/features/game/domain/services/cpu_strategy.dart';
import 'package:tictactoe/features/game/domain/services/music_player.dart';
import 'package:tictactoe/features/game/domain/services/sfx_player.dart';

@GenerateNiceMocks([
  MockSpec<AppPreferencesRepository>(),
  MockSpec<AudioController>(),
  MockSpec<AudioSettingsRepository>(),
  MockSpec<CpuStrategy>(),
  MockSpec<KeyValueStorage>(),
  MockSpec<MusicPlayer>(),
  MockSpec<ScoreboardRepository>(),
  MockSpec<SfxPlayer>(),
])
void main() {}
