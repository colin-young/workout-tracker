import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:workout_tracker/components/common/custom_scaffold.dart';
import 'package:workout_tracker/components/common/timer_widget.dart';
import 'package:workout_tracker/components/workouts/workout_manager.dart';
import 'package:workout_tracker/controller/exercise_sets_controller.dart';
import 'package:workout_tracker/controller/timer_controller.dart';
import 'package:workout_tracker/data/repositories/exercise_sets_repository.dart';
import 'package:workout_tracker/timer/timer_context.dart';
import 'package:workout_tracker/timer/timer_event.dart';

class WorkoutPage extends ConsumerWidget {
  const WorkoutPage({required this.title, required this.workoutId, super.key});

  final String title;
  final String workoutId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final int workoutRecordId = int.parse(workoutId);

    return CustomScaffold(
      appBar: AppBar(
        title: Consumer(builder: (_, WidgetRef ref, __) {
          final workoutResult = ref.watch(
              workoutCurrentExerciseProvider(workoutRecordId: workoutRecordId));

          return switch (workoutResult) {
            AsyncData(:final value) => Text(value?.exercise.name ?? ''),
            AsyncError(:final error) => Text(error.toString()),
            _ => Container()
          };
        }),
        actions: [
          IconButton(
              icon: const Icon(Icons.add_circle_outline),
              onPressed: () {
                context.go('/workout/$workoutId/addExercise');
              }),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: WorkoutManager(
          workoutRecordId: workoutRecordId,
        ),
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
                ref.read(getAllowedEventsProvider.future).then((value) {
                  if (value.any((element) => element.name == Running().name)) {
                    ref
                        .read(timerControllerProvider.notifier)
                        .handleEvent(Reset());
                  }
                  ref
                      .read(timerControllerProvider.notifier)
                      .handleEvent(Start());
                });
              },
              child: const Icon(Icons.check),
            )
          : Container(),
      _ => Container()
    };
  }
}
