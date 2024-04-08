import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_preferences.freezed.dart';
part 'user_preferences.g.dart';

@freezed
abstract class UserPreferencesAutoCloseWorkout with _$UserPreferencesAutoCloseWorkout {
  const factory UserPreferencesAutoCloseWorkout({
    required bool autoClose,
    required Duration autoCloseWorkoutAfter,
  }) = _UserPreferencesAutoCloseWorkout;

  factory UserPreferencesAutoCloseWorkout.fromJson(Map<String, dynamic> json) =>
      _$UserPreferencesAutoCloseWorkoutFromJson(json);
}

@freezed
abstract class UserPreferencesShowcase with _$UserPreferencesShowcase {
  const factory UserPreferencesShowcase({
    required bool summaryPage,
  }) = _UserPreferencesShowcase;

  factory UserPreferencesShowcase.fromJson(Map<String, dynamic> json) =>
    _$UserPreferencesShowcaseFromJson(json);
}

@freezed
abstract class UserPreferences with _$UserPreferences {
  const factory UserPreferences({
    required String weightUnits,
    required UserPreferencesAutoCloseWorkout autoCloseWorkout,
    required UserPreferencesShowcase showcase,
  }) = _UserPreferences;

  factory UserPreferences.fromJson(Map<String, dynamic> json) =>
      _$UserPreferencesFromJson(json);

  static String storeName = 'userPreferences';
}
