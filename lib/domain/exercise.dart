import 'package:workout_tracker/domain/exercise_setting.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter/foundation.dart';
import 'package:workout_tracker/domain/exercise_type.dart';

part 'exercise.freezed.dart';
part 'exercise.g.dart';

@freezed
abstract class Exercise with _$Exercise {
  const factory Exercise({
    @Default(-1) int id,
    required String name,
    ExerciseType? exerciseType,
    String? note,
    required List<ExerciseSetting> settings,
  }) = _Exercise;

  factory Exercise.fromJson(Map<String, dynamic> json) =>
      _$ExerciseFromJson(json);
}
