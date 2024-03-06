import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:workout_tracker/components/common/rounded_button.dart';
import 'package:workout_tracker/controller/workout_definition_controller.dart';
import 'package:workout_tracker/data/repositories/mock_data.dart';
import 'package:workout_tracker/domain/workout_exercise.dart';

class RoutineManager extends ConsumerWidget {
  const RoutineManager({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      elevation: 5,
      shape: const BeveledRectangleBorder(),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              "Title",
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            Text(
              "Subheading",
              style: Theme.of(context).textTheme.bodySmall,
            ),
            Wrap(
                alignment: WrapAlignment.spaceAround,
                runAlignment: WrapAlignment.spaceAround,
                children: [
                  RoundedButton(
                    onPressed: () async {
                      await ref
                        .read(workoutDefinitionControllerProvider.notifier)
                        .createWorkoutDefinition(
                            name: "New Routine",
                            exercises: [
                          const WorkoutExercise(order: 1, exercise: bicepsCurl),
                          const WorkoutExercise(
                              order: 2, exercise: seatedLegCurl),
                          const WorkoutExercise(order: 3, exercise: pecFly),
                          const WorkoutExercise(
                              order: 4, exercise: legExtension),
                        ]);
                    },
                    text: Text("New Routine",
                        style: Theme.of(context).textTheme.bodyMedium),
                    icon: Icons.add,
                    iconSize: 20,
                  ),
                  RoundedButton(
                    onPressed: () => GoRouter.of(context).go("/exercises"),
                    text: Text("Exercises",
                        style: Theme.of(context).textTheme.bodyMedium),
                    icon: FontAwesomeIcons.weightHanging,
                    iconSize: 14,
                  ),
                ]),
            Consumer(
              builder: (_, WidgetRef ref, __) {
                final workoutDefinitionsAsync =
                    ref.watch(workoutDefinitionControllerProvider);

                return workoutDefinitionsAsync.when(
                    data: (workoutDefinitions) => Wrap(
                            alignment: WrapAlignment.spaceAround,
                            runAlignment: WrapAlignment.spaceAround,
                            children: [
                              for (var definition in workoutDefinitions)
                                RoundedButton(
                                    onPressed: () {},
                                    text: Text(definition.name,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium),
                                    icon: Icons.play_arrow),
                            ]),
                    error: (e, st) => Text(e.toString()),
                    loading: () => const Center(child: CircularProgressIndicator()));
              },
            ),
          ],
        ),
      ),
    );
  }
}
