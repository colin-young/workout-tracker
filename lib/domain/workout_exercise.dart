import 'package:flutter_application_1/domain/exercise.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter/foundation.dart';

part 'workout_exercise.freezed.dart';
part 'workout_exercise.g.dart';

@freezed
abstract class WorkoutExercise with _$WorkoutExercise {
  const factory WorkoutExercise({
    required int order,
    required Exercise exercise,
  }) = _WorkoutExercise;

  factory WorkoutExercise.fromJson(Map<String, Object?> json) =>
      _$WorkoutExerciseFromJson(json);
}
