import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:workout_tracker/data/repositories/workout_record_repository.dart';
import 'package:workout_tracker/utility/relative_date.dart';

class WorkoutRunMenu extends ConsumerWidget {
  const WorkoutRunMenu({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workoutDefinitionsResult = ref.watch(getLastWorkoutDateProvider);
    final workoutRecordResult = ref.watch(getLastworkoutRecordProvider);
    final isCompleteResult = ref.watch(isWorkoutCompleteProvider(
        workoutRecordId: switch (workoutRecordResult) {
      AsyncData(:final value) => value.id,
      _ => -1
    }));

    return MenuAnchor(
      menuChildren: [
        ...(switch (workoutDefinitionsResult) {
          AsyncData(:final value) => value
              .map((i) => MenuItemButton(
                  leadingIcon: const Icon(Icons.play_arrow),
                  child: Text(i.date == null
                      ? 'Start ${i.definition.name}'
                      : 'Start ${i.definition.name} - ${i.date!.getRelativeDateString()}')))
              .toList(),
          _ => [],
        }),
        ...switch (isCompleteResult) {
          AsyncData(value: final isCompleteValue) => isCompleteValue
              ? []
              : switch (workoutRecordResult) {
                  AsyncData(value: final workoutRecordValue) =>
                        [
                            const PopupMenuDivider(),
                            MenuItemButton(
                              leadingIcon: const Icon(Icons.play_arrow),
                              child: const Text('Resume Current'),
                              onPressed: () {
                                context.go('/workout/${workoutRecordValue.id}');
                              },
                            ),
                            MenuItemButton(
                              leadingIcon: const Icon(Icons.playlist_add_check),
                              child: const Text('Mark Current Completed'),
                              onPressed: () {
                                ref.read(completeAllWorkoutExercisesProvider(
                                    workoutRecordId: workoutRecordValue.id));
                              },
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
