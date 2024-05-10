import 'package:workout_tracker/domain/workout_exercise.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter/foundation.dart';

part 'workout_definition.freezed.dart';
part 'workout_definition.g.dart';

@freezed
abstract class WorkoutDefinition with _$WorkoutDefinition {
  const factory WorkoutDefinition({
    @Default(-1) int id,
    required String name,
    required List<WorkoutExercise> exercises,
  }) = _WorkoutDefinition;

  factory WorkoutDefinition.fromJson(Map<String, dynamic> json) =>
      _$WorkoutDefinitionFromJson(json);

  factory WorkoutDefinition.init() {
    return const WorkoutDefinition(id: -1, name: '', exercises: []);
  }
}
