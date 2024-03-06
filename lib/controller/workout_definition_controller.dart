import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:workout_tracker/data/workout_definition/workout_definitions_repository.dart';
import 'package:workout_tracker/domain/workout_definition.dart';
import 'package:workout_tracker/domain/workout_exercise.dart';

part 'workout_definition_controller.g.dart';

@riverpod
class WorkoutDefinitionController extends _$WorkoutDefinitionController {
  @override
  FutureOr<List<WorkoutDefinition>> build() async {
    final definitionsRepository =
        ref.watch(workoutDefinitionsRepositoryProvider);
    return definitionsRepository.getAllEntities();
  }

  Future<int> createWorkoutDefinition(
      {required String name, required List<WorkoutExercise> exercises}) async {
    final definitionsRepository =
        ref.watch(workoutDefinitionsRepositoryProvider);
    final newDefinition = WorkoutDefinition(name: name, exercises: exercises);

    state = const AsyncLoading();
    var id = await definitionsRepository.insert(newDefinition);
    
    state = await AsyncValue.guard(() async {
      return definitionsRepository.getAllEntities();
    });
    return id;
  }

  Future<List<WorkoutDefinition>> getWorkoutDefinitions() async {
    final definitionsRepository =
        ref.watch(workoutDefinitionsRepositoryProvider);
    state = const AsyncLoading();
    var definitions = definitionsRepository.getAllEntities();
    state = await AsyncValue.guard(() async => definitions);
    return definitions;
  }
}
