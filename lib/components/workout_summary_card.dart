import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:workout_tracker/components/common/ui/card_title_divider.dart';
import 'package:workout_tracker/components/common/relative_date.dart';
import 'package:workout_tracker/data/user_preferences_state.dart';
import 'package:workout_tracker/data/repositories/workout_record_repository.dart';
import 'package:workout_tracker/utility/workout_utilities.dart';

class WorkoutSummaryCard extends ConsumerWidget with UserPreferencesState {
  final int workoutRecordId;

  const WorkoutSummaryCard(
    this.workoutRecordId, {
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workoutRecordResult = ref.watch(
        getWorkoutRecordStreamProvider(workoutRecordId: workoutRecordId));
    final isCompleteFuture =
        ref.watch(isWorkoutCompleteProvider(workoutRecordId: workoutRecordId));
    final finishedAtFuture =
        ref.watch(workoutFinishedAtProvider(workoutRecordId: workoutRecordId));
    final totalExercisesFuture = ref
        .watch(workoutTotalExercisesProvider(workoutRecordId: workoutRecordId));
    final totalRepsFutures =
        ref.watch(totalWorkoutRepsProvider(workoutRecordId: workoutRecordId));
    final totalWeightFutures =
        ref.watch(workoutTotalWeightProvider(workoutRecordId: workoutRecordId));
    final prefs = userPreferences(ref);

    var labelStyle = Theme.of(context).textTheme.bodyMedium!;

    switch (isCompleteFuture) {
      case AsyncValue(:final value?):
        if (!value) {
          if (userPreferences(ref).autoCloseWorkout.autoClose) {
            final finishedAtFuture = ref.watch(
                workoutFinishedAtProvider(workoutRecordId: workoutRecordId));
            final finishedAt = switch (finishedAtFuture) {
              AsyncValue(:final value?) => value,
              _ => DateTime.now()
            };
            if (DateTime.now().difference(finishedAt) >
                userPreferences(ref).autoCloseWorkout.autoCloseWorkoutAfter) {
              ref.read(completeAllWorkoutExercisesProvider(
                  workoutRecordId: workoutRecordId));
            }
          }
        }
    }

    return Card(
        elevation: 5.0,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(children: <Widget>[
            Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  switch (workoutRecordResult) {
                    AsyncValue(:final value?) => Text(
                        value.name(),
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    _ => const SizedBox(width: 0, height: 0),
                  },
                  switch (isCompleteFuture) {
                    AsyncValue(:final value?) => value
                        ? const SizedBox()
                        : FilledButton.tonal(
                            onPressed: () {
                              context.go('/workout/$workoutRecordId');
                            },
                            child: const Text('Continue current'),
                          ),
                    _ => const SizedBox(),
                  },
                ]),
            CardTitleDivider(
                child: switch (finishedAtFuture) {
              AsyncValue(:final value?) =>
                RelativeDate(value, style: labelStyle),
              _ => const SizedBox(width: 0, height: 0),
            }),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                mainAxisSize: MainAxisSize.max,
                children: [
                  switch (totalExercisesFuture) {
                    AsyncValue(:final value, hasValue: true) =>
                      Text('$value exercises'),
                    _ => const SizedBox(width: 0, height: 0),
                  },
                  switch (totalRepsFutures) {
                    AsyncValue(:final value, hasValue: true) =>
                      Text('$value reps'),
                    _ => const SizedBox(width: 0, height: 0),
                  },
                  switch (totalWeightFutures) {
                    AsyncValue(:final value, hasValue: true) =>
                      Text('$value ${prefs.weightUnits}'),
                    _ => const Text('No exercises'),
                  },
                ],
              ),
            ),
          ]),
        ));
  }
}
