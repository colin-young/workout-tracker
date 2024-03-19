import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workout_tracker/components/workouts/workout_manager.dart';
import 'package:workout_tracker/controller/exercise_sets_controller.dart';
import 'package:workout_tracker/data/repositories/workout_record_repository.dart';

class WorkoutPage extends ConsumerWidget {
  const WorkoutPage({required this.title, required this.workoutId, super.key});

  final String title;
  final String workoutId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final int workoutRecordId = int.parse(workoutId);

    return Scaffold(
        appBar: AppBar(title: Consumer(builder: (_, WidgetRef ref, __) {
          final workoutResult = ref.watch(
              workoutCurrentExerciseProvider(workoutRecordId: workoutRecordId));

          return workoutResult.when(
            data: (sets) => Text(sets?.exercise.name ?? ''),
            error: (error, stackTrace) => Text(error.toString()),
            loading: () => const CircularProgressIndicator(),
          );
        })),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: WorkoutManager(
            workoutRecordId: workoutRecordId,
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            ref
                .watch(workoutCurrentExerciseProvider(
                        workoutRecordId: workoutRecordId)
                    .future)
                .then((value) {
              if (value != null) {
                ref
                    .read(exerciseSetsControllerProvider.notifier)
                    .completeWorkoutSet(workoutSetId: value.id);
              }
            });
          },
          child: const Icon(Icons.check),
        ));
  }
}
