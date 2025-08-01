import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workout_tracker/components/common/custom_scaffold.dart';
import 'package:workout_tracker/components/pages/workout/workout_manager.dart';
import 'package:workout_tracker/data/exercise_sets_controller.dart';
import 'package:workout_tracker/data/repositories/exercise_sets_repository.dart';

class WorkoutPage extends ConsumerWidget {
  const WorkoutPage({required this.title, required this.workoutId, super.key});

  final String title;
  final String workoutId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final int workoutRecordId = int.parse(workoutId);
    final workoutResult = ref.watch(
        workoutCurrentExerciseStreamProvider(workoutRecordId: workoutRecordId));

    return CustomScaffold(
      title: switch (workoutResult) {
        AsyncValue(:final value, hasValue: true) =>
          Text(value?.exercise.name ?? ''),
        AsyncError(:final error) => Text(error.toString()),
        _ => Container()
      },
      body: WorkoutManager(
        workoutRecordId: workoutRecordId,
      ),
      floatingActionButton: CompleteSetsFAB(workoutRecordId: workoutRecordId),
    );
  }
}

class CompleteSetsFAB extends ConsumerWidget {
  const CompleteSetsFAB({
    super.key,
    required this.workoutRecordId,
  });

  final int workoutRecordId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final canComplete =
        ref.watch(canCompleteSetsProvider(workoutRecordId: workoutRecordId));

    return switch (canComplete) {
      AsyncValue(:final value?) => value
          ? FloatingActionButton.extended(
              onPressed: () {
                ref
                    .read(workoutCurrentExerciseStreamProvider(
                            workoutRecordId: workoutRecordId)
                        .future)
                    .then((sets) {
                  if (sets != null) {
                    ref
                        .read(exerciseSetsControllerProvider.notifier)
                        .completeWorkoutSet(workoutSetId: sets.id);
                  }
                });
              },
              label: const Text('Complete sets'),
              icon: const Icon(Icons.check),
            )
          : Container(),
      _ => Container()
    };
  }
}
