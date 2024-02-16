import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:workout_tracker/components/card_title_divider.dart';
import 'package:workout_tracker/controller/exercise_controller.dart';
import 'package:workout_tracker/domain/exercise.dart';

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
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      appBar: AppBar(
        title: Text(
          "Exercises",
          style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        elevation: 2.0,
      ),
      body: Consumer(builder: (_, WidgetRef ref, __) {
        final workoutDefinitionsAsync = ref.watch(exerciseControllerProvider);

        return workoutDefinitionsAsync.when(
            data: (exercises) => StreamBuilder<List<Exercise>>(
                stream: exercises,
                builder: (BuildContext context,
                    AsyncSnapshot<List<Exercise>> snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  switch (snapshot.connectionState) {
                    case ConnectionState.waiting:
                      return const Center(child: CircularProgressIndicator());
                    default:
                      var items = snapshot.data!;
                      return Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: items.length,
                          itemBuilder: (BuildContext context, int index) {
                            var entry = items[index];
                            return Card(
                              child: Padding(
                                padding: const EdgeInsets.all(8),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Text(
                                          entry.name,
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleMedium,
                                        ),
                                      ],
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                          crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Opacity(
                                          opacity: .2,
                                          child: Icon(getExerciseIcon(entry.exerciseType!), size: 60,)),
                                        Text(entry.exerciseType!, style: Theme.of(context).textTheme.bodyMedium,),
                                      ],
                                    ),
                                    entry.note != null ? const CardTitleDivider(child: Text("Notes")) : const SizedBox(),
                                    entry.note != null ? Text(entry.note!, softWrap: true,) : const SizedBox(),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      );
                  }
                }),
            error: (e, st) => Text(e.toString()),
            loading: () => const Center(child: CircularProgressIndicator()));
      }),
    );
  }
}
