import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:workout_tracker/data/repositories/exercise_repository.dart';
import 'package:workout_tracker/domain/exercise.dart';
import 'package:workout_tracker/domain/exercise_setting.dart';
import 'package:workout_tracker/domain/exercise_type.dart';

part 'exercise_controller.g.dart';

@riverpod
class ExerciseController extends _$ExerciseController {
  @override
  FutureOr<Stream<List<Exercise>>> build() async {
    final definitionsRepository =
        ref.watch(exerciseRepositoryProvider);
    return definitionsRepository.getAllEntitiesStream();
  }

  Future<int> createExercise(
      {required String name, required ExerciseType exerciseType, required String note, required List<ExerciseSetting> setting}) async {
    final definitionsRepository =
        ref.watch(exerciseRepositoryProvider);
    final newExercise = Exercise(name: name, exerciseType: exerciseType, note: note, settings: setting);

    state = const AsyncLoading();
    var id = await definitionsRepository.insert(newExercise);

    state = await AsyncValue.guard(() async {
      return definitionsRepository.getAllEntitiesStream();
    });
    return id;
  }

  Future<Stream<List<Exercise>>> getExercises() async {
    final definitionsRepository =
        ref.watch(exerciseRepositoryProvider);
    state = const AsyncLoading();
    var definitions = definitionsRepository.getAllEntitiesStream();
    state = await AsyncValue.guard(() async => definitions);
    return definitions;
  }
}
