import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:workout_tracker/components/exercises/exercise_view_card.dart';
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
    var onBackgroundColor = Theme.of(context).colorScheme.onSecondary;
    var backgroundColor = Theme.of(context).colorScheme.secondary;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Exercises"),
      ),
      body: Consumer(builder: (_, WidgetRef ref, __) {
        final exerciseResult = ref.watch(exerciseControllerProvider);

        return exerciseResult.when(
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
                            return GestureDetector(
                              onDoubleTap: () => context
                                  .go('/exercises/exercise/${entry.id}/edit'),
                              child: ExerciseViewCard(entry: entry, backgroundColor: backgroundColor, onBackgroundColor: onBackgroundColor),
                            );
                          },
                        ),
                      );
                  }
                }),
            error: (e, st) => Text(e.toString()),
            loading: () => const Center(child: CircularProgressIndicator()));
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.go('/exercises/exercise/-1/edit');
        },
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        shape: const CircleBorder(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
