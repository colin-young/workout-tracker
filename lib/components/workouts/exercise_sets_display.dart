import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workout_tracker/data/repositories/exercise_sets_repository.dart';
import 'package:workout_tracker/utility/exercise_sets_extensions.dart';

class ExerciseSetsDisplay extends ConsumerWidget {
  const ExerciseSetsDisplay(
      {required this.workoutRecordId, required this.exerciseId, super.key});

  final int workoutRecordId;
  final int exerciseId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var textStyle = Theme.of(context).textTheme;
    final workoutSetsResult = ref.watch(getWorkoutExerciseSetsStreamProvider(
        workoutId: workoutRecordId, exerciseId: exerciseId));

    return workoutSetsResult.when(
        data: (workoutSets) => Center(
              child: Text(
                textAlign: TextAlign.center,
                workoutSets.displayString(),
                style: textStyle.bodyMedium,
                overflow: TextOverflow.ellipsis,
              ),
            ),
        error: (e, st) => Text(e.toString()),
        loading: () => const Center(child: CircularProgressIndicator()));
  }
}
