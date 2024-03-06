import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:workout_tracker/data/repositories/exercise_repository.dart';
import 'package:workout_tracker/data/repositories/exercise_sets_repository.dart';
import 'package:workout_tracker/data/repositories/workout_record_repository.dart';
import 'package:workout_tracker/domain/set_entry.dart';
import 'package:workout_tracker/domain/exercise_sets.dart';
import 'dart:developer' as developer;

part 'exercise_sets_controller.g.dart';

@riverpod
class ExerciseSetsController extends _$ExerciseSetsController {
  @override
  FutureOr<List<ExerciseSets>> build() async {
    developer.log('initializing', name: 'ExerciseSetsController');

    ref.onDispose(() {
      developer.log('ref.dispose', name: 'ExerciseSetsController');
    });

    final exerciseSets = ref.watch(getAllExerciseSetsProvider.future);

    state = const AsyncLoading();
    state = await AsyncValue.guard(() => exerciseSets);
    return exerciseSets;
  }

  Future<void> addWorkoutSet(
      {required int workoutRecordId, required SetEntry newSet}) async {
    state = const AsyncLoading();

    final workoutRecord = await ref.read(
        getWorkoutRecordProvider(workoutRecordId: workoutRecordId).future);
    final exerciseSets = await ref.read(
        getAllWorkoutExerciseSetsProvider(workoutRecordId: workoutRecordId)
            .future);

    state = await AsyncValue.guard(() async {
      final exerciseId = workoutRecord.currentExercise!.id;

      if (exerciseSets.any((element) => element.exercise.id == exerciseId)) {
        final oldSet =
            exerciseSets.firstWhere((e) => e.exercise.id == exerciseId);
        final updatedSet = oldSet.copyWith(sets: [...oldSet.sets, newSet]);
        await ref.read(updateExerciseSetsProvider(exercise: updatedSet).future);
      } else {
        final exercise =
            await ref.read(getExerciseProvider(entityId: exerciseId).future);
        final newExerciseSets = ExerciseSets(
            workoutId: workoutRecordId,
            exercise: exercise,
            sets: [newSet],
            isComplete: false);
        await ref
            .read(insertExerciseSetsProvider(exercise: newExerciseSets).future);
      }

      // await Future.delayed(const Duration(seconds: 2));
      return await ref.watch(getAllExerciseSetsProvider.future);
    });

    ref.invalidate(getAllExerciseSetsProvider);
  }
}
