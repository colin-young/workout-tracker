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
abstract class UserPreferences with _$UserPreferences {
  const factory UserPreferences({
    required String weightUnits,
    required Duration timerLength,
    required UserPreferencesAutoCloseWorkout autoCloseWorkout,
    required double chartOpacity,
    required List<String> weightUnitList,
    required List<String> exerciseType,
  }) = _UserPreferences;

  factory UserPreferences.fromJson(Map<String, dynamic> json) =>
      _$UserPreferencesFromJson(json);

  static String storeName = 'userPreferences';
}
