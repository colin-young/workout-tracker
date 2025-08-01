import 'package:workout_tracker/domain/exercise.dart';
import 'package:workout_tracker/domain/set_entry.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter/foundation.dart';

part 'exercise_sets.freezed.dart';
part 'exercise_sets.g.dart';

@freezed
abstract class ExerciseSets with _$ExerciseSets {
  const factory ExerciseSets({
    @Default(-1) int id,
    required int workoutId,
    required int order,
    required Exercise exercise,
    required List<SetEntry> sets,
    required bool isComplete,
  }) = _ExerciseSets;

  factory ExerciseSets.fromJson(Map<String, dynamic> json) =>
      _$ExerciseSetsFromJson(json);
}
