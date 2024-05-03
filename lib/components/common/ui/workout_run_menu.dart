import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:workout_tracker/controller/timer_controller.dart';
import 'package:workout_tracker/controller/user_preferences_state.dart';
import 'package:workout_tracker/data/repositories/workout_record_repository.dart';
import 'package:workout_tracker/domain/exercise_sets.dart';
import 'package:workout_tracker/domain/workout_record.dart';
import 'package:workout_tracker/timer/timer_event.dart';
import 'package:workout_tracker/timer/timer_set_dialog.dart';
import 'package:workout_tracker/utility/duration_extensions.dart';
import 'package:workout_tracker/utility/relative_date.dart';

class WorkoutRunMenu extends ConsumerWidget with UserPreferencesState {
  const WorkoutRunMenu({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workoutDefinitionsResult = ref.watch(getLastWorkoutDateProvider);
    final lastWorkoutRecordResult = ref.watch(getLastworkoutRecordProvider);
    final isCompleteResult = ref.watch(isWorkoutCompleteProvider(
        workoutRecordId: switch (lastWorkoutRecordResult) {
      AsyncValue(:final value?) => value.id,
      _ => -1
    }));

    var theme = Theme.of(context);
    var titleStyle = theme.textTheme.titleLarge?.copyWith(
      color: theme.colorScheme.outlineVariant,
    );

    var startArbitraryWorkoutMenuButton = MenuItemButton(
      child: const Text('Start new workout'),
      onPressed: () {
        ref
            .read(workoutRecordNotifierProvider.notifier)
            .addWorkoutRecord(WorkoutRecord(
                startedAt: DateTime.now(),
                lastActivityAt: DateTime.now(),
                isActive: true))
            .then((value) {
          context.go('/workout/$value');
        });
      },
    );

    var startDefinedWorkoutMenuButtons = switch (workoutDefinitionsResult) {
      AsyncValue(:final value?) => value
          .map((i) => MenuItemButton(
              onPressed: () {
                ref
                    .read(workoutRecordNotifierProvider.notifier)
                    .addWorkoutRecord(WorkoutRecord(
                      startedAt: DateTime.now(),
                      lastActivityAt: DateTime.now(),
                      fromWorkoutDefinition: i.definition,
                      isActive: true,
                    ))
                    .then((workoutId) {
                  Future.wait(i.definition.exercises.map((e) => ref
                      .read(workoutRecordNotifierProvider.notifier)
                      .addExerciseSets(
                          workoutRecordId: workoutId,
                          sets: ExerciseSets(
                              workoutId: workoutId,
                              order: e.order,
                              exercise: e.exercise,
                              sets: [],
                              isComplete: false)))).then((value) {
                    context.go('/workout/$workoutId');
                  });
                });
              },
              child: Text(i.date == null
                  ? 'Start ${i.definition.name}'
                  : 'Start ${i.definition.name} - ${i.date!.getRelativeDateString()}')))
          .toList(),
      _ => [],
    };

    var currentWorkoutMenuButtons = switch (isCompleteResult) {
      AsyncValue(:final value?) => value
          ? []
          : switch (lastWorkoutRecordResult) {
              AsyncValue(:final value?) => [
                  Center(child: Text('Current Routine', style: titleStyle)),
                  MenuItemButton(
                    onPressed: () {
                      context.go('/workout/${value.id}');
                    },
                    child: const Text('Resume Current'),
                  ),
                  MenuItemButton(
                    onPressed: () {
                      ref.read(completeAllWorkoutExercisesProvider(
                          workoutRecordId: value.id));
                    },
                    child: const Text('Mark Current Completed'),
                  ),
                ],
              _ => []
            },
      _ => []
    };

    var timerButtons = [
      Center(child: Text('Timers', style: titleStyle)),
      MenuItemButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) {
              return const TimerSetDialog(
                  buttonPadding: 24.0, gridSpacing: 4.0);
            },
          );
        },
        child: const Text('Start New Timer'),
      ),
      MenuItemButton(
        onPressed: () {
          ref
              .read(timerControllerProvider.notifier)
              .handleEvent(Reset(duration: userPreferences(ref).timerLength));
          ref.read(timerControllerProvider.notifier).handleEvent(Start());
        },
        child: Text(
            'Start timer for ${userPreferences(ref).timerLength.getDurationString()}'),
      ),
    ];

    var commonButtons = [
      Center(child: Text('Setup', style: titleStyle)),
      MenuItemButton(
        onPressed: () {
          context.go('/routines');
        },
        child: const Text('Manage Routines'),
      ),
      MenuItemButton(
        child: const Text('Manage Exercises'),
        onPressed: () {
          context.go('/exercises');
        },
      ),
      MenuItemButton(
        child: const Text('Licenses'),
        onPressed: () {
          context.go('/licenses');
        },
      ),
    ];

    var startWorkoutMenuButtons = switch (isCompleteResult) {
      AsyncValue(:final value?) => value,
      _ => false
    }
        ? [
            Center(
                child: Text(
              'Start a Routine',
              style: Theme.of(context).textTheme.titleLarge,
            )),
            ...startDefinedWorkoutMenuButtons,
            startArbitraryWorkoutMenuButton,
          ]
        : [];

    return MenuAnchor(
      menuChildren: [
        ...startWorkoutMenuButtons,
        ...currentWorkoutMenuButtons,
        ...timerButtons,
        ...commonButtons,
      ],
      builder: (context, controller, child) {
        return IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {
            if (controller.isOpen) {
              controller.close();
            } else {
              controller.open();
            }
          },
        );
      },
    );
  }
}
