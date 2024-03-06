import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workout_tracker/components/routine_manager.dart';
import 'package:workout_tracker/components/exercises/workout_exercise_card_view.dart';
import 'package:workout_tracker/components/workout_summary_card.dart';
import 'package:workout_tracker/data/repositories/exercise_sets_repository.dart';
import 'package:workout_tracker/data/repositories/last_workout_repository.dart';

class SummaryPage extends ConsumerWidget {
  const SummaryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workoutRecordAsync = ref.watch(getLastworkoutRecordProvider);

    return workoutRecordAsync.when(
        data: (workoutRecord) => Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  WorkoutSummaryCard(workoutRecord),
                  Expanded(child: Consumer(
                    builder: (context, ref, child) {
                      final workoutSetsFuture = ref.watch(
                          getAllWorkoutExerciseSetsProvider(
                              workoutRecordId: workoutRecord.id));
                      return workoutSetsFuture.when(
                          data: (workoutSets) => ListView(
                                shrinkWrap: true,
                                children: workoutSets
                                    .map((e) => WorkoutExerciseCardView(
                                        workoutExercise: e))
                                    .toList(),
                              ),
                          error: (e, st) => Text(e.toString()),
                          loading: () => const Center(
                                child: CircularProgressIndicator(),
                              ));
                    },
                  )),
                  const RoutineManager(),
                ],
              ),
            ),
        error: (e, st) => Text(e.toString()),
        loading: () => const CircularProgressIndicator());
  }
}
