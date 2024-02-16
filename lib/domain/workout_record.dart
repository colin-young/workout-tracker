import 'package:workout_tracker/domain/exercise.dart';
import 'package:workout_tracker/domain/workout_definition.dart';
import 'package:workout_tracker/domain/workout_sets.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter/foundation.dart';

part 'workout_record.freezed.dart';
part 'workout_record.g.dart';

@freezed
abstract class WorkoutRecord implements _$WorkoutRecord {
  const WorkoutRecord._();

  const factory WorkoutRecord(
      {@Default(-1) int id,
      required WorkoutDefinition fromWorkoutDefinition,
      Exercise? currentExercise,
      required List<WorkoutSets> sets,
      required DateTime startedAt,
      @Default(false) bool isActive}) = _WorkoutRecord;

  factory WorkoutRecord.fromJson(Map<String, dynamic> json) =>
      _$WorkoutRecordFromJson(json);

  bool isComplete() => !sets.any((element) => !element.isComplete);
  DateTime finishedAt() {
    var list = sets.expand((e) => e.sets).toList();
    list.sort((a, b) => a.finishedAt.compareTo(b.finishedAt));
    return list.first.finishedAt;
  }

  String units() {
    if (sets.isEmpty) {
      return "";
    }
    return sets.fold("", (previousValue, element) {
      var nextValue = element.sets.fold(
          "",
          (prev, curr) =>
              prev == "" || prev == curr.units ? curr.units : "unknown");

      return previousValue == "" || previousValue == nextValue
          ? nextValue
          : "unknown";
    });
  }

  int totalWeight() {
    // get sum of reps times weight properties
    // get the sum of reps times weight properties in Dart Language:
    if (sets.isEmpty) {
      return 0;
    }
    // TODO convert to userPrefsWeightUnits
    return sets.fold(
        0,
        (previousValue, element) =>
            previousValue +
            element.sets
                .fold(0, (prev, curr) => prev + (curr.reps * curr.weight)));
  }

  int totalExercises() {
    return sets.length;
  }

  int totalReps() {
    return sets.fold(
        0,
        (previousValue, element) =>
            previousValue +
            element.sets.fold(0, (prev, curr) => prev + curr.reps));
  }
}
