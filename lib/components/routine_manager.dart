import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:workout_tracker/components/rounded_button.dart';
import 'package:workout_tracker/controller/workout_definition_controller.dart';
import 'package:workout_tracker/data/repositories/mock_data.dart';
import 'package:workout_tracker/domain/workout_definition.dart';
import 'package:workout_tracker/domain/workout_exercise.dart';
import 'dart:developer' as developer;

class RoutineManager extends ConsumerWidget {
  const RoutineManager({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    developer.log('Building RoutineManager component', name: 'debug');
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
                      developer.log('onPressed - 1', name: 'RoutineManager.RoundedButton');
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
                      developer.log('onPressed - 2',
                          name: 'RoutineManager.RoundedButton');
                    },
                    text: "New Routine",
                    icon: Icons.add,
                    iconSize: 20,
                  ),
                  RoundedButton(
                    onPressed: () => context.go("/exercises"),
                    text: "Exercises",
                    icon: FontAwesomeIcons.weightHanging,
                    iconSize: 14,
                  ),
                ]),
            Consumer(
              builder: (_, WidgetRef ref, __) {
                final workoutDefinitionsAsync =
                    ref.watch(workoutDefinitionControllerProvider);

                return workoutDefinitionsAsync.when(
                    data: (workoutDefinitions) => StreamBuilder<List<WorkoutDefinition>>(
                        stream: workoutDefinitions,
                        builder: (BuildContext context,
                            AsyncSnapshot<List<WorkoutDefinition>> snapshot) {
                          if (!snapshot.hasData) {
                            return const Center(child: CircularProgressIndicator());
                          }
                          switch (snapshot.connectionState) {
                            case ConnectionState.waiting:
                              return const Center(child: CircularProgressIndicator());
                            default:
                              var items = snapshot.data;
                              return Wrap(
                                  alignment: WrapAlignment.spaceAround,
                                  runAlignment: WrapAlignment.spaceAround,
                                  children: [
                                    for (var definition in items!)
                                      RoundedButton(
                                          onPressed: () => null,
                                          text: definition.name,
                                          icon: Icons.play_arrow),
                                  ]);
                              }
                          }
                        ),
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
