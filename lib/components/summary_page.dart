import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workout_tracker/components/routine_manager.dart';
import 'package:workout_tracker/components/workout_exercise_card_view.dart';
import 'package:workout_tracker/components/workout_summary_card.dart';
import 'package:workout_tracker/data/repositories/workout_record_repository.dart';

class SummaryPage extends ConsumerWidget {
  const SummaryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workoutRecordAsync = ref.watch(getLastWorkoutRecordProvider);

    return workoutRecordAsync.when(
        data: (workoutRecord) => Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                WorkoutSummaryCard(workoutRecord),
                Expanded(
                  child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: workoutRecord.sets.length,
                      itemBuilder: (BuildContext context, int index) {
                        return WorkoutExerciseCardView(
                            workoutExercise: workoutRecord.sets[index]);
                      }),
                ),
                const RoutineManager(),
              ],
            ),
        error: (e, st) => Text(e.toString()),
        loading: () => const CircularProgressIndicator());
  }
}
