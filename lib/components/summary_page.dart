import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:workout_tracker/components/workouts/exercise_sets/workout_exercise_card_view.dart';
import 'package:workout_tracker/components/workout_summary_card.dart';
import 'package:workout_tracker/controller/user_preferences_state.dart';
import 'package:workout_tracker/data/repositories/exercise_sets_repository.dart';
import 'package:workout_tracker/data/repositories/user_preferences_repository.dart';
import 'dart:developer' as developer;

import 'package:workout_tracker/data/repositories/workout_record_repository.dart';
import 'package:workout_tracker/utility/exercise_sets_extensions.dart';
import 'package:workout_tracker/utility/separated_list.dart';

class SummaryPage extends ConsumerWidget with UserPreferencesState {
  SummaryPage({super.key});

  final GlobalKey _one = GlobalKey();
  final GlobalKey _two = GlobalKey();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workoutRecordAsync = ref.watch(getLastworkoutRecordProvider);
    final prefs = userPreferences(ref);

    if (!prefs.showcase.summaryPage) {
      switch (workoutRecordAsync) {
        case AsyncData():
          WidgetsBinding.instance.addPostFrameCallback(
              (_) => ShowCaseWidget.of(context).startShowCase([_one, _two]));
          ref.read(updateUserPreferencesProvider(
              userPreferences: prefs.copyWith(
                  showcase: prefs.showcase.copyWith(summaryPage: true))));
      }
    }

    return workoutRecordAsync.when(
        data: (workoutRecord) {
          developer.log('workoutId: ${workoutRecord.id}', name: 'SummaryPage');

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  WorkoutSummaryCard(workoutRecord.id),
                  Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: Card.filled(
                      elevation: 3,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Recent Exercises',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(
                              width: double.infinity,
                              height: 5,
                            ),
                            Consumer(
                              builder: (context, ref, child) {
                                const inset = 16.0;
                                final workoutSetsResults =
                                    ref.watch(getAllExerciseSetsStreamProvider);
                                return workoutSetsResults.when(
                                    data: (workoutSets) {
                                      workoutSets.sort((a, b) => b
                                          .latestDateTime()
                                          .compareTo(a.latestDateTime()));
                                      return Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: workoutSets
                                            .where((element) =>
                                                element.sets.isNotEmpty)
                                            .take(15)
                                            .map((e) {
                                          return WorkoutExerciseCardView(
                                              inset: inset, workoutExercise: e);
                                        }).separatedList(const SizedBox(
                                          height: inset,
                                        )),
                                      );
                                    },
                                    error: (e, st) => Text('SummaryPage: $e'),
                                    loading: () => const Center(
                                          child: CircularProgressIndicator(),
                                        ));
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
        error: (e, st) => Text(e.toString()),
        loading: () => const CircularProgressIndicator());
  }
}
