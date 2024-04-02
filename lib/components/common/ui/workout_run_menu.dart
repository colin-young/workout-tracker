import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workout_tracker/data/repositories/workout_record_repository.dart';
import 'package:workout_tracker/utility/relative_date.dart';

class WorkoutRunMenu extends ConsumerWidget {
  const WorkoutRunMenu({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workoutDefinitionsAsync = ref.watch(getLastWorkoutDateProvider);

    return MenuAnchor(
      menuChildren: switch (workoutDefinitionsAsync) {
        AsyncData(:final value) => value
            .map((i) => MenuItemButton(
                leadingIcon: const Icon(Icons.play_circle),
                child: Text(i.date == null
                    ? 'Start ${i.definition.name}'
                    : 'Start ${i.definition.name} - ${i.date!.getRelativeDateString()}')))
            .toList(),
        _ => [],
      },
      builder: (context, controller, child) {
        return ActionChip(
          avatar: const Icon(Icons.menu),
          label: const Text('Routines'),
          backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
          side:BorderSide.none,
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
