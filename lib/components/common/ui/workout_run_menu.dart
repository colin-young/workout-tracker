import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:workout_tracker/data/repositories/workout_record_repository.dart';
import 'package:workout_tracker/domain/exercise_sets.dart';
import 'package:workout_tracker/domain/workout_record.dart';
import 'package:workout_tracker/utility/relative_date.dart';

class WorkoutRunMenu extends ConsumerWidget {
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

    return MenuAnchor(
      menuChildren: [
        ...(switch (isCompleteResult) {
          AsyncValue(:final value?) => value,
          _ => false
        }
            ? switch (workoutDefinitionsResult) {
                AsyncValue(:final value?) => value
                    .map((i) => MenuItemButton(
                        leadingIcon: const Icon(Icons.play_arrow),
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
              } : []),
        ...switch (isCompleteResult) {
          AsyncValue(:final value?) => value
              ? []
              : switch (lastWorkoutRecordResult) {
                  AsyncValue(:final value?) => [
                      MenuItemButton(
                        leadingIcon: const Icon(Icons.play_arrow),
                        onPressed: () {
                          context.go('/workout/${value.id}');
                        },
                        child: const Text('Resume Current'),
                      ),
                      MenuItemButton(
                        leadingIcon: const Icon(Icons.playlist_add_check),
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
        }
      ],
      builder: (context, controller, child) {
        return ChipTheme(
          data: ChipTheme.of(context).copyWith(),
          child: ActionChip(
            avatar: const Icon(Icons.menu),
            label: const Text('Routines'),
            // backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
            side: BorderSide.none,
            onPressed: () {
              if (controller.isOpen) {
                controller.close();
              } else {
                controller.open();
              }
            },
          ),
        );
      },
    );
  }
}
