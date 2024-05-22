import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:workout_tracker/components/pages/routine/routine_card.dart';
import 'package:workout_tracker/data/workout_definition_controller.dart';
import 'package:workout_tracker/domain/workout_definition.dart';

class RoutineManager extends ConsumerWidget {
  const RoutineManager({
    super.key,
    this.newRoutine = false,
    this.onSave,
    this.onCancel,
  });

  final bool newRoutine;
  final Function? onSave;
  final Function? onCancel;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final routinesResult = ref.watch(workoutDefinitionControllerProvider);

    return switch (routinesResult) {
      AsyncValue(:final List<WorkoutDefinition> value?) => () {
          final definitions = [
            ...value,
            ...newRoutine ? [WorkoutDefinition.init()] : [],
          ];

          return ListView.builder(
            shrinkWrap: true,
            itemCount: definitions.length,
            itemBuilder: (context, index) {
              var textTheme = Theme.of(context).textTheme;

              return Dismissible(
                key: ValueKey('routine${definitions[index].id}'),
                onDismissed: (direction) async {
                  await ref
                      .read(workoutDefinitionControllerProvider.notifier)
                      .deleteWorkoutDefinition(
                          definitionId: definitions[index].id);
                },
                confirmDismiss: (direction) => showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text('Delete ${definitions[index].name}?'),
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
                    definition: definitions[index],
                    textTheme: textTheme,
                    isEditing: false || definitions[index].id == -1,
                    onSave: onSave,
                    onCancel: onCancel,
                  ),
                ),
              );
            },
          );
        }(),
      _ => const SizedBox()
    };
  }
}
