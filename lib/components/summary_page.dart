import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:workout_tracker/components/routine_manager.dart';
import 'package:workout_tracker/components/workouts/exercise_sets/workout_exercise_card_view.dart';
import 'package:workout_tracker/components/workout_summary_card.dart';
import 'package:workout_tracker/data/repositories/exercise_sets_repository.dart';
import 'dart:developer' as developer;

import 'package:workout_tracker/data/repositories/workout_record_repository.dart';

class SummaryPage extends ConsumerWidget {
  SummaryPage({super.key});

  final GlobalKey _one = GlobalKey();
  final GlobalKey _two = GlobalKey();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workoutRecordAsync = ref.watch(getLastworkoutRecordProvider);

    WidgetsBinding.instance.addPostFrameCallback(
        (_) => ShowCaseWidget.of(context).startShowCase([_one, _two]));

    return workoutRecordAsync.when(
        data: (workoutRecord) {
          developer.log('workoutId: ${workoutRecord.id}', name: 'SummaryPage');

          return Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Showcase(
                    targetPadding: const EdgeInsets.all(5),
                    key: _one,
                    title: 'Last Workout Summary',
                    description: "Shows the most recently completed workout",
                    tooltipBackgroundColor: Theme.of(context).primaryColor,
                    textColor: Colors.white,
                    child: WorkoutSummaryCard(workoutRecord.id)),
                Expanded(
                  child: Showcase(
                    targetPadding: const EdgeInsets.all(5),
                    key: _two,
                    title: 'Recent Exercises',
                    description: "Shows the exercises recorded during the last workout.",
                    tooltipBackgroundColor: Theme.of(context).primaryColor,
                    textColor: Colors.white,
                    child: Consumer(
                    builder: (context, ref, child) {
                      final workoutSetsResults = ref.watch(
                          getAllWorkoutExerciseSetsInProgressProvider(
                              workoutRecordId: workoutRecord.id));
                      return workoutSetsResults.when(
                          data: (workoutSets) => ListView(
                                shrinkWrap: true,
                                children: workoutSets
                                    .map((e) => WorkoutExerciseCardView(
                                        workoutExercise: e))
                                    .toList(),
                              ),
                          error: (e, st) => Text('SummaryPage: $e'),
                          loading: () => const Center(
                                child: CircularProgressIndicator(),
                              ));
                    },
                  ),
                  ),
                ),
                const RoutineManager(),
              ],
            ),
          );
        },
        error: (e, st) => Text(e.toString()),
        loading: () => const CircularProgressIndicator());
  }
}
