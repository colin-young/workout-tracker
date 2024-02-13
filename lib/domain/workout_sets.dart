import 'package:flutter_application_1/domain/exercise.dart';
import 'package:flutter_application_1/domain/set_entry.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter/foundation.dart';

part 'workout_sets.freezed.dart';
part 'workout_sets.g.dart';

@freezed
abstract class WorkoutSets with _$WorkoutSets {
  const factory WorkoutSets({
    required Exercise exercise,
    required List<SetEntry> sets,
    required bool isComplete,
  }) = _WorkoutSets;

  factory WorkoutSets.fromJson(Map<String, Object?> json) =>
      _$WorkoutSetsFromJson(json);
}
