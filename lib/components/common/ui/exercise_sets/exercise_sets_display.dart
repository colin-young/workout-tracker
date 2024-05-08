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

    return switch (workoutSetsResult) {
      AsyncValue(:final value?) => Center(
          child: Text(
            textAlign: TextAlign.center,
            value.displayString(),
            style: textStyle.bodyMedium,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      _ => const SizedBox()
    };
  }
}
