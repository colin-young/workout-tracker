import 'package:flutter/material.dart';
import 'package:workout_tracker/domain/exercise.dart';

class ExerciseListWithTile extends StatelessWidget {
  const ExerciseListWithTile({
    super.key,
    required this.exercises,
    required this.workoutRecordId,
    required this.onTap,
    required this.isItemSelected,
  });

  final int workoutRecordId;
  final List<Exercise> exercises;
  final void Function(List<Exercise>, int) onTap;
  final bool Function(List<Exercise>, int) isItemSelected;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        shrinkWrap: true,
        itemCount: exercises.length,
        itemBuilder: (context, index) => Card(
            child: ListTile(
              key: Key('$index'),
              onTap: () {
                onTap(exercises, index);
              },
              leading: Icon(exercises[index].exerciseType!.icon),
              title: Text(exercises[index].name),
              trailing: Icon(isItemSelected(exercises, index)
                  ? Icons.check_box_outlined
                  : Icons.check_box_outline_blank),
            )));
  }
}
