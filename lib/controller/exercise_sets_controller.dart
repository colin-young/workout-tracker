import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:workout_tracker/data/repositories/exercise_sets_repository.dart';
import 'package:workout_tracker/data/repositories/workout_record_repository.dart';
import 'package:workout_tracker/domain/exercise.dart';
import 'package:workout_tracker/domain/set_entry.dart';
import 'package:workout_tracker/domain/exercise_sets.dart';

import 'package:workout_tracker/utility/exercise_sets_extensions.dart';

part 'exercise_sets_controller.g.dart';

@riverpod
class ExerciseSetsController extends _$ExerciseSetsController {
  @override
  FutureOr<List<ExerciseSets>> build() async {
    // developer.log('initializing', name: 'ExerciseSetsController.build');

    ref.onDispose(() async {
      // developer.log('ref.dispose', name: 'ExerciseSetsController');

      await Future.wait([
        _currentExerciseController.close(),
        _upcomingExercisesController.close(),
        _completedExercisesController.close(),
      ]);
    });

    final exerciseSets = ref.watch(getAllExerciseSetsStreamProvider.future);

    state = const AsyncLoading();
    state = await AsyncValue.guard(() => exerciseSets);

    return exerciseSets;
  }

  final _currentSetController = StreamController<ExerciseSets>.broadcast();
  Stream<ExerciseSets> get streamSets => _currentSetController.stream;

  final _currentExerciseController = StreamController<Exercise>.broadcast();
  Stream<Exercise> get streamExercise => _currentExerciseController.stream;

  final _upcomingExercisesController =
      StreamController<List<Exercise>>.broadcast();
  Stream<List<Exercise>> get streamUpcoming =>
      _upcomingExercisesController.stream;

  final _completedExercisesController =
      StreamController<List<Exercise>>.broadcast();
  Stream<List<Exercise>> get streamCompleted =>
      _completedExercisesController.stream;

  Future<void> completeWorkoutSet({required int workoutSetId}) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final exercise = await ref
          .read(exerciseSetsRepositoryProvider)
          .getEntity(workoutSetId);
      await ref
          .watch(exerciseSetsRepositoryProvider)
          .update(exercise.copyWith(isComplete: true));

      ref.invalidate(getAllExerciseSetsByExerciseStreamProvider);

      return await ref.watch(getAllExerciseSetsStreamProvider.future);
    });
  }

  Future<void> addWorkoutSet(
      {required int workoutRecordId, required SetEntry newSet}) async {
    state = const AsyncLoading();

    final currentSets = await ref.read(
        workoutCurrentExerciseStreamProvider(workoutRecordId: workoutRecordId)
            .future);

    state = await AsyncValue.guard(() async {
      if (currentSets != null) {
        final updatedSet =
            currentSets.copyWith(sets: [...currentSets.sets, newSet]);
        await ref.read(updateExerciseSetsProvider(exercise: updatedSet).future);
        _currentSetController.add(updatedSet);
        final workoutRecord = await ref
            .read(workoutRecordRepositoryProvider)
            .getEntity(workoutRecordId);
         await ref.read(workoutRecordRepositoryProvider).insert(workoutRecord
            .copyWith(lastActivityAt: updatedSet.latestDateTime()));
      }

      ref.invalidate(getAllExerciseSetsByExerciseStreamProvider);

      return await ref.watch(getAllExerciseSetsStreamProvider.future);
    });
  }

  Future<void> reorderIncompleteExercises(
      {required int workoutRecordId,
      required int oldIndex,
      required int newIndex,
      bool skipFirst = false}) async {
    state = const AsyncLoading();

    final currentSets = await ref.read(
        getIncompleteExerciseSetsStreamProvider(workoutId: workoutRecordId)
            .future);

    state = await AsyncValue.guard(() async {
      final startIndex = skipFirst ? 1 : 0;
      final original = currentSets[oldIndex + startIndex];
      final isLast = newIndex >= currentSets.length - startIndex;
      List<ExerciseSets> newExercises = [];

      // order start is order from first record, even if skipping
      var currentOrder = currentSets[0].order;

      for (var index = 0; index < currentSets.length; index++) {
        // if at insert position, add moved item
        if (index == newIndex + startIndex) {
          currentOrder = addToExerciseSetsList(
              original, currentOrder, newExercises,
              action: 'Moving');
        }
        // if not at original position, add current item
        if (index != oldIndex + startIndex) {
          currentOrder = addToExerciseSetsList(
              currentSets[index], currentOrder, newExercises);
        }
      }

      if (isLast) {
        currentOrder = addToExerciseSetsList(
            original, currentOrder, newExercises,
            action: 'Moving');
      }

      await Future.wait([
        for (var index = 0; index < newExercises.length; index++)
          {
            ref
                .read(exerciseSetsRepositoryProvider)
                .update(newExercises[index]),
          }
      ] as Iterable<Future>);

      return await ref.watch(getAllExerciseSetsStreamProvider.future);
    });
  }

  int addToExerciseSetsList(
      ExerciseSets value, int currentOrder, List<ExerciseSets> newExercises,
      {String action = 'Adding'}) {

    if (value.order != currentOrder) {
      newExercises.add(value.copyWith(order: currentOrder));
    }

    return currentOrder + 1;
  }
}
