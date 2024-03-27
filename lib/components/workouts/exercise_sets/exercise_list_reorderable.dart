import 'package:flutter/material.dart';
import 'package:workout_tracker/components/workouts/exercise_sets/exercise_sets_list_tile.dart';
import 'package:workout_tracker/domain/workout_exercise.dart';

class ExerciseListReorderable extends StatelessWidget {
  const ExerciseListReorderable({
    super.key,
    required this.textStyle,
    required this.updateReps,
    required this.exercises,
  });

  final TextStyle? textStyle;
  final void Function(int) updateReps;
  final List<WorkoutExercise> exercises;

  @override
  Widget build(BuildContext context) {
    return ReorderableListView.builder(
      shrinkWrap: true,
      itemCount: exercises.length,
      itemBuilder: (context, index) {
        return Card(
          key: Key('$index'),
          child: ExerciseSetsListTile(
              icon: exercises[index].exercise.exerciseType?.icon,
              title: exercises[index].exercise.name),
        );
      },
      onReorder: (oldIndex, newIndex) {},
    );
  }
}
