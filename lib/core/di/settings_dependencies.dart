import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tictactoe/core/di/storage_providers.dart';
import 'package:tictactoe/features/settings/data/datasources/local_app_preferences_data_source.dart';
import 'package:tictactoe/features/settings/data/repositories/local_app_preferences_repository.dart';
import 'package:tictactoe/features/settings/domain/repositories/app_preferences_repository.dart';
import 'package:tictactoe/features/settings/domain/usecases/load_preferences.dart';
import 'package:tictactoe/features/settings/domain/usecases/save_preferences.dart';

part 'settings_dependencies.g.dart';

@Riverpod(keepAlive: true)
LocalAppPreferencesDataSource localAppPreferencesDataSource(Ref ref) {
  return LocalAppPreferencesDataSource(ref.watch(keyValueStorageProvider));
}

@Riverpod(keepAlive: true)
AppPreferencesRepository appPreferencesRepository(Ref ref) {
  return LocalAppPreferencesRepository(
    ref.watch(localAppPreferencesDataSourceProvider),
  );
}

@Riverpod(keepAlive: true)
LoadPreferences loadPreferences(Ref ref) {
  return LoadPreferences(ref.watch(appPreferencesRepositoryProvider));
}

@Riverpod(keepAlive: true)
SavePreferences savePreferences(Ref ref) {
  return SavePreferences(ref.watch(appPreferencesRepositoryProvider));
}
