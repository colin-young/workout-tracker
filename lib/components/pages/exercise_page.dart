import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:workout_tracker/components/common/custom_scaffold.dart';
import 'package:workout_tracker/components/workouts/exercise_sets/exercise_view_card.dart';
import 'package:workout_tracker/controller/workout_definition_controller.dart';
import 'package:workout_tracker/data/repositories/exercise_repository.dart';
import 'package:workout_tracker/domain/exercise.dart';
import 'package:workout_tracker/domain/workout_definition.dart';
import 'package:workout_tracker/utility/constants.dart';

class ExercisePage extends StatelessWidget {
  const ExercisePage({super.key});

  IconData getExerciseIcon(String icon) {
    switch (icon) {
      case 'dumbbell':
        return FontAwesomeIcons.dumbbell;
      case 'machine':
        return FontAwesomeIcons.gears;
      default:
        return FontAwesomeIcons.question;
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      title: const Text('Exercises'),
      body: Consumer(builder: (_, WidgetRef ref, __) {
        final exerciseResult = ref.watch(getExercisesProvider);

        return switch (exerciseResult) {
          AsyncValue(:final value?) => Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: value.length,
                      itemBuilder: (BuildContext context, int index) {
                        var entry = value[index];
                        return Dismissible(
                          onDismissed: (direction) {
                            ref.read(
                                deleteExerciseProvider(exerciseId: entry.id));
                            final routines = ref.watch(
                                workoutDefinitionControllerProvider.future);

                            switch (routines) {
                              case AsyncValue(:final value?):
                                for (final routine in value.where((e) => e
                                    .exercises
                                    .any((ex) => ex.id == entry.id))) {
                                  ref
                                      .read(workoutDefinitionControllerProvider
                                          .notifier)
                                      .updateWorkoutDefinition(
                                          definition: routine.copyWith(
                                              exercises: routine.exercises
                                                  .where(
                                                      (ex) => ex.id != entry.id)
                                                  .toList()));
                                }
                            }
                          },
                          confirmDismiss: (direction) => showDialog(
                            context: context,
                            builder: (context) {
                              return ConfirmDismissDialog(entry: entry);
                            },
                          ),
                          key: ValueKey(value[index].id),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              ExerciseViewCard(entry: entry),
                              TextButton(
                                child: const Text('Edit'),
                                onPressed: () => context
                                    .go('/exercises/exercise/${entry.id}/edit'),
                              ),
                              const Divider(),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: Constants.floatingActionButtonHeight),
                ],
              ),
            ),
          _ => const CircularProgressIndicator(),
        };
      }),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          context.go('/exercises/exercise/-1/edit');
        },
        label: const Text('Add exercise'),
        icon: const Icon(Icons.add),
      ),
    );
  }
}

class ConfirmDismissDialog extends ConsumerWidget {
  const ConfirmDismissDialog({
    super.key,
    required this.entry,
  });

  final Exercise entry;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final routinesResult = ref.watch(workoutDefinitionControllerProvider);

    return AlertDialog(
      title: Text('Delete exercise \'${entry.name.toLowerCase()}\'?'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
              'The exercise \'${entry.name.toLowerCase()}\' will be deleted. Previously recorded sets containing this exercise will not be affected.'),
          const SizedBox(height: 12),
          ...switch (routinesResult) {
            AsyncValue(:final List<WorkoutDefinition> value?) => value
                    .where((e) => e.exercises.any((ex) => ex.id == entry.id))
                    .isNotEmpty
                ? [
                    Text(
                        'The following routines will be updated to remove ${entry.name.toLowerCase()}:'),
                    const Divider(),
                    Column(
                        mainAxisSize: MainAxisSize.min,
                        children: value
                            .where((e) =>
                                e.exercises.any((ex) => ex.id == entry.id))
                            .map((e) => Text(e.name))
                            .toList()),
                    const Divider(),
                  ]
                : [],
            _ => [const CircularProgressIndicator()],
          },
        ],
      ),
      actions: [
        TextButton(
            onPressed: () => context.pop(false), child: const Text('Keep')),
        TextButton(
            onPressed: () => context.pop(true), child: const Text('Delete')),
      ],
    );
  }
}
