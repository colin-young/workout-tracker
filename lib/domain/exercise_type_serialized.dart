import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:workout_tracker/domain/exercise_type.dart';

part 'exercise_type_serialized.freezed.dart';
part 'exercise_type_serialized.g.dart';

@freezed
abstract class ExerciseTypeSerialized with _$ExerciseTypeSerialized {
  const factory ExerciseTypeSerialized({required String display}) = _ExerciseTypeSerialized;

  factory ExerciseTypeSerialized.fromJson(Map<String, dynamic> json) =>
      _$ExerciseTypeSerializedFromJson(json);

  const ExerciseTypeSerialized._();

  ExerciseType get deserialize => ExerciseType.deserialize(display);
}
