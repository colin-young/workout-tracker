import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:workout_tracker/components/workouts/exercise_sets/exercise_sets_list_tile.dart';
import 'package:workout_tracker/controller/exercise_sets_controller.dart';
import 'package:workout_tracker/data/repositories/exercise_sets_repository.dart';
import 'package:workout_tracker/domain/exercise_sets.dart';
import 'package:workout_tracker/utility/exercise_sets_extensions.dart';
import 'dart:developer' as developer;

class ExerciseSetsListWithSetsTile extends ConsumerWidget {
  const ExerciseSetsListWithSetsTile(
      {super.key,
      required List<ExerciseSets> workoutSets,
      required this.workoutRecordId,
      required this.swapEnabled})
      : _workoutSets = workoutSets;

  final List<ExerciseSets> _workoutSets;
  final int workoutRecordId;
  final bool swapEnabled;

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
                          label: const Text('Make Current'),
                          onPressed: () {
                            ref
                                .read(exerciseSetsControllerProvider.notifier)
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

    return Card.outlined(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          IncompleteActions(
            workoutRecordId: workoutRecordId,
            textStyle: textStyle,
            nextExerciseSets: nextExerciseSets,
            swapEnabled: upcomingExercises.isNotEmpty,
          ),
          ExerciseSetsListWithSetsTile(
            workoutRecordId: workoutRecordId,
            workoutSets: upcomingExercises,
            swapEnabled: upcomingExercises.isNotEmpty,
          )
        ]),
      ),
    );
  }
}

class IncompleteActions extends ConsumerWidget {
  const IncompleteActions({
    super.key,
    required this.workoutRecordId,
    required this.textStyle,
    required this.swapEnabled,
    this.nextExerciseSets,
  });

  final int workoutRecordId;
  final TextTheme textStyle;
  final ExerciseSets? nextExerciseSets;
  final bool swapEnabled;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return nextExerciseSets != null
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text('Up Next', style: textStyle.titleMedium),
                  ]),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ActionChip(
                    label: const Text('Add'),
                    avatar: const Icon(Icons.add_outlined),
                    onPressed: () {
                      context.go('/workout/$workoutRecordId/addExercise');
                    },
                  ),
                ],
              ),
            ],
          )
        : const SizedBox();
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

    return Card.outlined(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text('Completed', style: textStyle.titleMedium),
          ExerciseSetsListWithSetsTile(
            workoutRecordId: workoutRecordId,
            workoutSets: completedExercises,
            swapEnabled: false,
          )
        ]),
      ),
    );
  }
}
