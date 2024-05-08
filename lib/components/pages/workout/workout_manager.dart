import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:workout_tracker/components/common/ui/exercise_sets/exercise_sets_list_with_sets_tile.dart';
import 'package:workout_tracker/components/pages/workout/set_recorder.dart';
import 'package:workout_tracker/data/timer_controller.dart';
import 'package:workout_tracker/data/repositories/exercise_sets_repository.dart';
import 'package:workout_tracker/data/repositories/workout_record_repository.dart';
import 'package:workout_tracker/components/timer/timer_event.dart';

class WorkoutManager extends ConsumerWidget {
  const WorkoutManager({super.key, required this.workoutRecordId});

  final int workoutRecordId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workoutSetsResult =
        ref.watch(getWorkoutSetsStreamProvider(workoutId: workoutRecordId));

    switch (workoutSetsResult) {
      case AsyncValue(:final value?):
        // if no exercises, assume this is a new arbirtrary workout and immediately show add exercises screen
        if (value.isEmpty) {
          SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
            context.go('/workout/$workoutRecordId/addExercise');
          });
        }

        // if all exercises are complete, mark workout as complete and return to previous screen
        if (value.isNotEmpty && !value.any((element) => !element.isComplete)) {
          ref.read(completeAllWorkoutExercisesProvider(
              workoutRecordId: workoutRecordId));
          ref.watch(getAllowedEventsProvider.future).then((value) {
            if (value.contains(Reset())) {
              ref.read(timerControllerProvider.notifier).handleEvent(Reset());
            }
          });

          SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
            context.go('/');
          });
        }
    }

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            SetRecorder(
              key: ValueKey('setRecorder$workoutRecordId'),
              workoutRecordId: workoutRecordId,
            ),
            const SizedBox(
              height: 16,
            ),
            Card(
              color: Theme.of(context).colorScheme.surface,
              elevation: 5,
              margin: const EdgeInsets.all(0),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    UpcomingExercises(workoutRecordId: workoutRecordId),
                    const SizedBox(
                      height: 16,
                    ),
                    CompletedExercises(workoutRecordId: workoutRecordId),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
