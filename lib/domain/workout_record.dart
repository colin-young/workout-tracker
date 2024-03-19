import 'package:workout_tracker/domain/workout_definition.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter/foundation.dart';

part 'workout_record.freezed.dart';
part 'workout_record.g.dart';

@freezed
abstract class WorkoutRecord implements _$WorkoutRecord {
  const WorkoutRecord._();

  const factory WorkoutRecord(
      {@Default(-1) int id,
      WorkoutDefinition? fromWorkoutDefinition,
      required DateTime startedAt,
      @Default(false) bool isActive}) = _WorkoutRecord;

  factory WorkoutRecord.fromJson(Map<String, dynamic> json) =>
      _$WorkoutRecordFromJson(json);
}
