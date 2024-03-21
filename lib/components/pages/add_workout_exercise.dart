import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workout_tracker/controller/exercise_sets_controller.dart';
import 'package:workout_tracker/data/repositories/exercise_sets_repository.dart';

class AddWorkoutExercise extends ConsumerWidget {
  const AddWorkoutExercise({required this.title, required this.workoutId, super.key});

  final String title;
  final String workoutId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final int workoutRecordId = int.parse(workoutId);

    return Scaffold(
        appBar: AppBar(
          title: Consumer(builder: (_, WidgetRef ref, __) {
            final workoutResult = ref.watch(workoutCurrentExerciseProvider(
                workoutRecordId: workoutRecordId));
            return switch (workoutResult) {
              AsyncData(:final value) =>
                const Text('Add Exercise'),
              AsyncError(:final error) => Text(error.toString()),
              _ => Container()
            };
          }),
          actions: [
            IconButton(
                icon: const Icon(Icons.add_circle_outline), onPressed: () {}),
          ],
        ),
        body: const Padding(
          padding: EdgeInsets.all(16.0),
          child: Text('add exercise'),
        ),
        floatingActionButton:
            CompleteSetsFAB(workoutRecordId: workoutRecordId));
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
      AsyncData(:final value) => value
          ? FloatingActionButton(
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
            )
          : Container(),
      _ => Container()
    };
  }
}
