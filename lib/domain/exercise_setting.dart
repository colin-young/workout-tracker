import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter/foundation.dart';

part 'exercise_setting.freezed.dart';
part 'exercise_setting.g.dart';

@freezed
abstract class ExerciseSetting with _$ExerciseSetting {
  const factory ExerciseSetting(
      {required String setting, required String value}) = _ExerciseSetting;

  factory ExerciseSetting.fromJson(Map<String, Object?> json) =>
      _$ExerciseSettingFromJson(json);
}
