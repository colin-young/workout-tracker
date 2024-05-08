import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:workout_tracker/components/common/ui/card/action_card_header.dart';
import 'package:workout_tracker/components/common/ui/card/workout_tracker_card.dart';
import 'package:workout_tracker/components/common/ui/exercise_sets/exercise_sets_list_tile.dart';
import 'package:workout_tracker/data/exercise_sets_controller.dart';
import 'package:workout_tracker/data/repositories/exercise_sets_repository.dart';
import 'package:workout_tracker/domain/exercise_sets.dart';
import 'package:workout_tracker/utility/exercise_sets_extensions.dart';

class ExerciseSetsListWithSetsTile extends ConsumerWidget {
  const ExerciseSetsListWithSetsTile({
    super.key,
    required List<ExerciseSets> workoutSets,
    required this.workoutRecordId,
    required this.swapEnabled,
    required this.emptyListMessage,
  }) : _workoutSets = workoutSets;

  final List<ExerciseSets> _workoutSets;
  final int workoutRecordId;
  final bool swapEnabled;
  final String emptyListMessage;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      width: double.infinity,
      color: Theme.of(context).colorScheme.surface,
      child: _workoutSets.isNotEmpty
          ? ReorderableListView.builder(
              onReorder: (oldIndex, newIndex) {
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
                    onDismissed: (direction) async {
                      await ref.read(deleteExerciseSetsProvider(
                              exerciseId: _workoutSets[index].id)
                          .future);
                    },
                    child: ExerciseSetsListTile(
                      icon: _workoutSets[index].exercise.exerciseType!.icon,
                      title: _workoutSets[index].exercise.name,
                      subtitle: _workoutSets[index].displayString(),
                      trailing: swapEnabled && index == 0
                          ? Padding(
                              padding: const EdgeInsets.only(right: 12),
                              child: ActionChip(
                                avatar: const Icon(Icons.swap_vert),
                                label: const Text('Make current'),
                                onPressed: () {
                                  ref
                                      .read(exerciseSetsControllerProvider
                                          .notifier)
                                      .reorderIncompleteExercises(
                                          workoutRecordId: workoutRecordId,
                                          oldIndex: 0,
                                          newIndex: 2,
                                          skipFirst: false);
                                },
                              ),
                            )
                          : null,
                    ),
                  ))
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(emptyListMessage),
            ),
    );
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
        workoutCurrentExerciseStreamProvider(workoutRecordId: workoutRecordId));

    return switch (currentExerciseResult) {
      AsyncValue(:final value?) => UpcomingExercisesDisplay(
          nextExerciseSets: value,
          workoutRecordId: workoutRecordId,
          textStyle: textStyle,
        ),
      _ => const SizedBox()
    };
  }
}

class UpcomingExercisesDisplay extends ConsumerWidget {
  final int workoutRecordId;
  final TextTheme textStyle;
  final ExerciseSets nextExerciseSets;

  const UpcomingExercisesDisplay(
      {super.key,
      required this.workoutRecordId,
      required this.textStyle,
      required this.nextExerciseSets});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workoutSetsResult = ref.watch(getUpcomingExerciseSetsStreamProvider(
        workoutId: workoutRecordId, exerciseId: nextExerciseSets.exercise.id));

    return switch (workoutSetsResult) {
      AsyncValue(:final value?) => IncompleteExercisesList(
          allExerciseSets: value,
          nextExerciseSets: nextExerciseSets,
          textStyle: textStyle,
          workoutRecordId: workoutRecordId,
        ),
      _ => const SizedBox(),
    };
  }
}

class IncompleteExercisesList extends ConsumerWidget {
  final List<ExerciseSets> allExerciseSets;
  final int workoutRecordId;
  final TextTheme textStyle;
  final ExerciseSets nextExerciseSets;

  const IncompleteExercisesList(
      {super.key,
      required this.allExerciseSets,
      required this.workoutRecordId,
      required this.textStyle,
      required this.nextExerciseSets});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final upcomingExercises =
        allExerciseSets.where((element) => !element.isComplete).toList();

    return WorkoutTrackerCard(
        header: ActionCardHeader(
          title: 'Up next',
          workoutRecordId: workoutRecordId,
          textStyle: textStyle,
          swapEnabled: upcomingExercises.isNotEmpty,
          actions: [
            TextButton(
              onPressed: () {
                context.go('/workout/$workoutRecordId/addExercise');
              }, child: const Text('Add exercise'),
            ),
          ],
        ),
        body: ExerciseSetsListWithSetsTile(
          workoutRecordId: workoutRecordId,
          workoutSets: upcomingExercises,
          swapEnabled: upcomingExercises.isNotEmpty,
          emptyListMessage: 'All exercises started',
        ));
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
        workoutCurrentExerciseStreamProvider(workoutRecordId: workoutRecordId));

    return switch (currentExerciseResult) {
      AsyncValue(:final value?) => CompletedExercisesDisplay(
          nextExerciseSets: value,
          workoutRecordId: workoutRecordId,
          textStyle: textStyle,
        ),
      _ => const SizedBox()
    };
  }
}

class CompletedExercisesDisplay extends ConsumerWidget {
  final int workoutRecordId;
  final TextTheme textStyle;
  final ExerciseSets nextExerciseSets;

  const CompletedExercisesDisplay(
      {super.key,
      required this.workoutRecordId,
      required this.textStyle,
      required this.nextExerciseSets});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workoutSetsFuture = ref.watch(
        getCompletedExerciseSetsStreamProvider(workoutId: workoutRecordId));

    return switch (workoutSetsFuture) {
      AsyncValue(:final value?) => CompletedExercisesList(
          workoutRecordId: workoutRecordId,
          workoutSets: value,
          textStyle: textStyle,
        ),
      _ => const SizedBox()
    };
  }
}

class CompletedExercisesList extends ConsumerWidget {
  final List<ExerciseSets> workoutSets;
  final int workoutRecordId;
  final TextTheme textStyle;

  const CompletedExercisesList(
      {super.key,
      required this.workoutRecordId,
      required this.workoutSets,
      required this.textStyle});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var completedExercises =
        workoutSets.where((element) => element.isComplete).toList();

    return WorkoutTrackerCard(
        header: ActionCardHeader(
          title: 'Completed',
          workoutRecordId: workoutRecordId,
          textStyle: textStyle,
          swapEnabled: completedExercises.isNotEmpty,
        ),
        body: ExerciseSetsListWithSetsTile(
          workoutRecordId: workoutRecordId,
          workoutSets: completedExercises,
          swapEnabled: false,
          emptyListMessage: 'Exercises appear here when all sets are completed',
        ));
  }
}
