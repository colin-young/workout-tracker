import 'package:flutter_application_1/domain/workout_exercise.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter/foundation.dart';

part 'workout_definition.freezed.dart';
part 'workout_definition.g.dart';

@freezed
abstract class WorkoutDefinition with _$WorkoutDefinition {
  const factory WorkoutDefinition({
    required String name,
    required List<WorkoutExercise> exercises,
  }) = _WorkoutDefinition;

  factory WorkoutDefinition.fromJson(Map<String, Object?> json) =>
      _$WorkoutDefinitionFromJson(json);
}
