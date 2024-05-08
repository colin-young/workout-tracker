import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:workout_tracker/components/pages/routine/routine_card.dart';
import 'package:workout_tracker/data/workout_definition_controller.dart';
import 'package:workout_tracker/domain/workout_definition.dart';

class RoutineManager extends ConsumerWidget {
  const RoutineManager({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final routinesResult = ref.watch(workoutDefinitionControllerProvider);

    return switch (routinesResult) {
      AsyncValue(:final List<WorkoutDefinition> value?) => ListView.builder(
          shrinkWrap: true,
          itemCount: value.length,
          itemBuilder: (context, index) {
            var textTheme = Theme.of(context).textTheme;

            return Dismissible(
              key: ValueKey('routine${value[index].id}'),
              onDismissed: (direction) async {
                await ref
                    .read(workoutDefinitionControllerProvider.notifier)
                    .deleteWorkoutDefinition(definitionId: value[index].id);
              },
              confirmDismiss: (direction) => showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text('Delete ${value[index].name}?'),
                      content: const Text(
                          'Deleting a routine definition cannot be undone.'),
                      actions: [
                        TextButton(
                            onPressed: () => context.pop(false),
                            child: const Text('Keep')),
                        TextButton(
                            onPressed: () => context.pop(true),
                            child: const Text('Delete'))
                      ],
                    );
                  }),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: RoutineCard(
                  definition: value[index],
                  textTheme: textTheme,
                  isEditing: false,
                ),
              ),
            );
          },
        ),
      _ => const SizedBox()
    };
  }
}
