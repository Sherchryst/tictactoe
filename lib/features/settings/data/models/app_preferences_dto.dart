import 'package:json_annotation/json_annotation.dart';

import 'package:tictactoe/features/settings/domain/entities/app_preferences.dart';

part 'app_preferences_dto.g.dart';

@JsonSerializable()
final class AppPreferencesDto {
  const AppPreferencesDto({required this.localePreference});

  factory AppPreferencesDto.fromDomain(AppPreferences preferences) {
    return AppPreferencesDto(localePreference: preferences.localePreference);
  }

  factory AppPreferencesDto.fromJson(Map<String, dynamic> json) {
    return _$AppPreferencesDtoFromJson(json);
  }

  @JsonKey(defaultValue: AppLocalePreference.english)
  final AppLocalePreference localePreference;

  Map<String, dynamic> toJson() => _$AppPreferencesDtoToJson(this);

  AppPreferences toDomain() {
    return AppPreferences(localePreference: localePreference);
  }
}
