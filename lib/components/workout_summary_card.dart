import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:workout_tracker/components/common/card_title_divider.dart';
import 'package:workout_tracker/components/common/relative_date.dart';
import 'package:workout_tracker/components/common/rounded_button.dart';
import 'package:workout_tracker/data/repositories/workout_record_repository.dart';
import 'package:workout_tracker/domain/workout_record.dart';

class WorkoutSummaryCard extends StatelessWidget {
  final WorkoutRecord workoutRecord;

  const WorkoutSummaryCard(
    this.workoutRecord, {
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    var labelStyle = Theme.of(context).textTheme.bodyMedium!;
    return Padding(
        padding: const EdgeInsets.all(5.0),
        child: Card(
            elevation: 5.0,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(children: <Widget>[
                Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        workoutRecord.fromWorkoutDefinition.name,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      Consumer(
                        builder: (context, ref, child) {
                          final isCompleteFuture = ref.watch(
                              isWorkoutCompleteProvider(
                                  workoutRecordId: workoutRecord.id));
                          return isCompleteFuture.when(
                              data: (isComplete) => isComplete
                                  ? const SizedBox()
                                  : RoundedButton(
                                      onPressed: () {
                                        context
                                            .go('/workout/${workoutRecord.id}');
                                      },
                                      text: Text(
                                        "Continue Current",
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium,
                                      ),
                                      icon: Icons.play_arrow),
                              error: (e, st) => const SizedBox(),
                              loading: () => const SizedBox()
                              );
                        },
                      )
                    ]),
                CardTitleDivider(child: Consumer(
                  builder: (context, ref, child) {
                    final finishedAtFuture = ref.watch(
                        workoutFinishedAtProvider(
                            workoutRecordId: workoutRecord.id));

                    return finishedAtFuture.when(
                        data: (finishedAt) =>
                            RelativeDate(finishedAt, style: labelStyle),
                        error: (Object e, StackTrace st) => Text(e.toString()),
                        loading: () => const Center(
                              child: CircularProgressIndicator(),
                            ));
                  },
                )),
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Consumer(
                        builder: (context, ref, child) {
                          final totalExercisesFuture = ref.watch(
                              workoutTotalExercisesProvider(
                                  workoutRecordId: workoutRecord.id));

                          return totalExercisesFuture.when(
                              data: (exercisesCount) =>
                                  Text('$exercisesCount exercises'),
                              error: (e, st) => const Text('No exercises'),
                              loading: () => const Text('loading'));
                        },
                      ),
                      Consumer(
                        builder: (context, ref, child) {
                          final totalRepsFutures = ref.watch(
                              totalWorkoutRepsProvider(
                                  workoutRecordId: workoutRecord.id));

                          return totalRepsFutures.when(
                              data: (exercisesCount) =>
                                  Text('$exercisesCount reps'),
                              error: (e, st) => const Text('No exercises'),
                              loading: () => const Text('loading'));
                        },
                      ),
                      Consumer(
                        builder: (context, ref, child) {
                          final totalWeightFutures = ref.watch(
                              workoutTotalWeightProvider(
                                  workoutRecordId: workoutRecord.id));

                          return totalWeightFutures.when(
                              data: (weight) {
                                final weightUnitsFuture = ref.watch(
                                    workoutSetsUnitsProvider(
                                        workoutRecordId: workoutRecord.id));

                                return weightUnitsFuture.when(
                                    data: (units) => Text('$weight $units'),
                                    error: (e, st) =>
                                        const Text('No exercises'),
                                    loading: () => const Text('loading'));
                              },
                              error: (e, st) => const Text('No exercises'),
                              loading: () => const Text('loading'));
                        },
                      ),
                    ],
                  ),
                ),
              ]),
            )));
  }
}
