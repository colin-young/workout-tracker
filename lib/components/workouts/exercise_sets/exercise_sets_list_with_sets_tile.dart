import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workout_tracker/components/common/rounded_button.dart';
import 'package:workout_tracker/components/workouts/exercise_sets/exercise_sets_list_tile.dart';
import 'package:workout_tracker/controller/exercise_sets_controller.dart';
import 'package:workout_tracker/data/repositories/exercise_sets_repository.dart';
import 'package:workout_tracker/domain/exercise_sets.dart';
import 'package:workout_tracker/utility/exercise_sets_extensions.dart';
import 'dart:developer' as developer;

class ExerciseSetsListWithSetsTile extends ConsumerWidget {
  const ExerciseSetsListWithSetsTile({
    super.key,
    required List<ExerciseSets> workoutSets,
    required this.workoutRecordId,
  }) : _workoutSets = workoutSets;

  final List<ExerciseSets> _workoutSets;
  final int workoutRecordId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ReorderableListView.builder(
        onReorder: (oldIndex, newIndex) {
          developer.log('reorder ($oldIndex, $newIndex)',
              name: 'ExerciseListWithSetsTile.ReorderableListView.onReorder');
          ref
              .read(exerciseSetsControllerProvider.notifier)
              .reorderIncompleteExercises(
                  workoutRecordId: workoutRecordId,
                  oldIndex: oldIndex,
                  newIndex: newIndex,
                  skipFirst: true);
        },
        shrinkWrap: true,
        itemCount: _workoutSets.length,
        itemBuilder: (context, index) => Dismissible(
              key: Key('$index'),
          onDismissed: (direction) {
                ref.read(deleteExerciseSetsProvider(
                    exerciseId: _workoutSets[index].id));
          },
          child: Card(
              child: ExerciseSetsListTile(
                  icon: _workoutSets[index].exercise.exerciseType!.icon,
                  title: _workoutSets[index].exercise.name,
                  subtitle: _workoutSets[index].displayString())),
        ));
  }
}

class UpcomingExercises extends ConsumerWidget {
  const UpcomingExercises({
    required this.workoutRecordId,
    super.key,
  });

  final int workoutRecordId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var textStyle = Theme.of(context).textTheme;
    final currentExerciseResult = ref.watch(
        workoutCurrentExerciseProvider(workoutRecordId: workoutRecordId));

    return Column(
      children: [
        ...currentExerciseResult.when(
            data: (sets) {
              final workoutSetsFuture = ref.watch(
                  getUpcomingExerciseSetsStreamProvider(
                      workoutId: workoutRecordId,
                      exerciseId: sets!.exercise.id));

              return workoutSetsFuture.when(
                  data: (workoutSets) {
                    final upcomingExercises = workoutSets
                        .where((element) => !element.isComplete)
                        .toList();

                    return [
                      upcomingExercises.isNotEmpty
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    RoundedButton(
                                        text: const Text('Swap'),
                                        icon: Icons.swap_vert,
                                        width: 80,
                                        onPressed: () {
                                          ref
                                              .read(
                                                  exerciseSetsControllerProvider
                                                      .notifier)
                                              .reorderIncompleteExercises(
                                                  workoutRecordId:
                                                      workoutRecordId,
                                                  oldIndex: 0,
                                                  newIndex: 2,
                                                  skipFirst: false);
                                        }),
                                    RoundedButton(
                                        text: const Text('Remove'),
                                        icon: Icons.delete_forever,
                                        width: 80,
                                        onPressed: sets.sets.isEmpty
                                            ? () {
                                                const snackBar = SnackBar(
                                                  content: Text(
                                                      'Long-press to remove'),
                                                );

                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(snackBar);
                                              }
                                            : null,
                                        onLongPressed: sets.sets.isEmpty
                                            ? () {
                                                ref
                                                    .read(getIncompleteExerciseSetsStreamProvider(
                                                            workoutId:
                                                                workoutRecordId)
                                                        .future)
                                                    .then((value) {
                                                  if (value.isNotEmpty) {
                                                    ref.read(
                                                        deleteExerciseSetsProvider(
                                                            exerciseId: value
                                                                .first.id));
                                                  }
                                                });
                                              }
                                            : null),
                                  ],
                                ),
                                Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Text('Up Next',
                                          style: textStyle.titleMedium),
                                    ]),
                              ],
                            )
                          : const SizedBox(),
                      ExerciseSetsListWithSetsTile(
                          workoutRecordId: workoutRecordId,
                          workoutSets: upcomingExercises)
                    ];
                  },
                  error: (e, st) => [Text(e.toString())],
                  loading: () => [
                        const Center(
                          child: CircularProgressIndicator(),
                        )
                      ]);
            },
            error: (e, st) => [Text(e.toString())],
            loading: () => [
                  const Center(
                    child: CircularProgressIndicator(),
                  )
                ]),
      ],
    );
  }
}

class CompletedExercises extends ConsumerWidget {
  const CompletedExercises({
    required this.workoutRecordId,
    super.key,
  });

  final int workoutRecordId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var textStyle = Theme.of(context).textTheme;
    final currentExerciseResult = ref.watch(
        workoutCurrentExerciseProvider(workoutRecordId: workoutRecordId));

    return Column(
      children: [
        ...currentExerciseResult.when(
            data: (exerciseId) {
              final workoutSetsFuture = ref.watch(
                  getCompletedExerciseSetsStreamProvider(
                      workoutId: workoutRecordId));

              return workoutSetsFuture.when(
                  data: (workoutSets) {
                    var completedExercises = workoutSets
                        .where((element) => element.isComplete)
                        .toList();
                    return [
                      Text('Completed', style: textStyle.titleMedium),
                      ExerciseSetsListWithSetsTile(
                          workoutRecordId: workoutRecordId,
                          workoutSets: completedExercises)
                    ];
                  },
                  error: (e, st) => [Text(e.toString())],
                  loading: () => [
                        const Center(
                          child: CircularProgressIndicator(),
                        )
                      ]);
            },
            error: (e, st) => [Text(e.toString())],
            loading: () => [
                  const Center(
                    child: CircularProgressIndicator(),
                  )
                ]),
      ],
    );
  }
}
