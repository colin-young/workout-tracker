import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workout_tracker/components/exercises/exercise_list_reorderable.dart';
import 'package:workout_tracker/components/exercises/exercise_list_with_sets_tile.dart';
import 'package:workout_tracker/components/workouts/set_recorder.dart';
import 'package:workout_tracker/controller/user_preferences_state.dart';
import 'package:workout_tracker/controller/workout_record_controller.dart';
import 'package:workout_tracker/data/repositories/exercise_sets_repository.dart';

class WorkoutManager extends ConsumerWidget with UserPreferencesState {
  const WorkoutManager({super.key, required this.workoutRecordId});

  final int workoutRecordId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var prefs = userPreferences(ref);
    var textStyle = Theme.of(context).textTheme;
    var textTitle = textStyle.titleLarge;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          SetRecorder(
            weightUnits: prefs.weightUnits,
            workoutRecordId: workoutRecordId,
          ),
          const SizedBox(
            height: 16,
          ),
          Text('Up Next', style: textStyle.titleMedium),
          Consumer(builder: (context, ref, child) {
            // TODO convert to use exercisesInWorkout provider
            final workoutResult = ref.watch(workoutRecordControllerProvider(
                workoutRecordId: workoutRecordId));
            return workoutResult.when(
                data: (workout) {
                  final workoutSetsFuture = ref.watch(
                      getAllWorkoutExerciseSetsProvider(
                          workoutRecordId: workoutRecordId));

                  return workoutSetsFuture.when(
                      data: (workoutSets) => ExerciseListReorderable(
                          textStyle: textTitle,
                          updateReps: (e) {},
                          exercises: workout.fromWorkoutDefinition.exercises
                              .where((element) =>
                                  !workoutSets.any((s) =>
                                      s.exercise.id == element.exercise.id &&
                                      s.isComplete) &&
                                  element.exercise.id !=
                                      workout.currentExercise!.id)
                              .toList()),
                      error: (e, st) => Text(e.toString()),
                      loading: () => const Center(
                            child: CircularProgressIndicator(),
                          ));
                },
                error: (e, st) => Text(e.toString()),
                loading: () => const Center(
                      child: CircularProgressIndicator(),
                    ));
          }),
          Text('Completed', style: textStyle.titleMedium),
          Consumer(builder: (context, ref, child) {
            final workoutSetsFuture = ref.watch(
                getAllWorkoutExerciseSetsProvider(
                    workoutRecordId: workoutRecordId));

            return workoutSetsFuture.when(
                data: (workoutSets) => ExerciseListWithSetsTile(
                    workoutSets: workoutSets
                        .where((element) => element.isComplete)
                        .toList()),
                error: (e, st) => Text(e.toString()),
                loading: () => const Center(
                      child: CircularProgressIndicator(),
                    ));
          })
        ],
      ),
    );
  }
}
