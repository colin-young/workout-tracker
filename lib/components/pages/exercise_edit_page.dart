import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workout_tracker/components/exercises/exercise_edit_form.dart';
import 'package:workout_tracker/data/repositories/exercise_repository.dart';

class ExerciseEditPage extends StatelessWidget {
  const ExerciseEditPage(
      {required this.title, required this.exerciseId, super.key});

  final String title;
  final String exerciseId;

  @override
  Widget build(BuildContext context) {
    final int exerciseIdKey = int.parse(exerciseId);

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Consumer(builder: (_, WidgetRef ref, __) {
        final exercise =
            ref.watch(GetExerciseProvider(entityId: exerciseIdKey));

        return exercise.when(
            data: (exercise) => Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ExerciseEditForm(
                    exercise: exercise,
                  ),
                ),
            error: (e, st) => Text(e.toString()),
            loading: () => const Center(child: CircularProgressIndicator()));
      }),
    );
  }
}
