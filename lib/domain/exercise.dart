import 'package:flutter_application_1/domain/exercise_setting.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter/foundation.dart';

part 'exercise.freezed.dart';
part 'exercise.g.dart';

@freezed
abstract class Exercise with _$Exercise {
  const factory Exercise(
      {required String name,
      String? exerciseType,
      String? note,
      ExerciseSetting? setting}) = _Exercise;

  factory Exercise.fromJson(Map<String, Object?> json) =>
      _$ExerciseFromJson(json);
}
