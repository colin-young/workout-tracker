import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workout_tracker/components/exercises/exercise_list_with_sets_tile.dart';
import 'package:workout_tracker/components/workouts/set_recorder.dart';
import 'package:workout_tracker/controller/user_preferences_state.dart';

class WorkoutManager extends ConsumerWidget with UserPreferencesState {
  const WorkoutManager({super.key, required this.workoutRecordId});

  final int workoutRecordId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefs = userPreferences(ref);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          children: [
            SetRecorder(
              weightUnits: prefs.weightUnits,
              workoutRecordId: workoutRecordId,
            ),
            const SizedBox(
              height: 16,
            ),
            UpcomingExercises(workoutRecordId: workoutRecordId),
            CompletedExercises(workoutRecordId: workoutRecordId),
          ],
        ),
      ),
    );
  }
}
