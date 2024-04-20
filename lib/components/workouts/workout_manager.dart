import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workout_tracker/components/workouts/exercise_sets/exercise_sets_list_with_sets_tile.dart';
import 'package:workout_tracker/components/workouts/exercise_sets/set_recorder.dart';

class WorkoutManager extends ConsumerWidget {
  const WorkoutManager({super.key, required this.workoutRecordId});

  final int workoutRecordId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                    const SizedBox(height: 16,),
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
