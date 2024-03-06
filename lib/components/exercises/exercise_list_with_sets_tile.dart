import 'package:flutter/material.dart';
import 'package:workout_tracker/components/exercises/exercise_list_tile.dart';
import 'package:workout_tracker/domain/exercise_sets.dart';
import 'package:workout_tracker/utility/sets_display_string.dart';

class ExerciseListWithSetsTile extends StatelessWidget {
  const ExerciseListWithSetsTile({
    super.key,
    required List<ExerciseSets> workoutSets,
  }) : _workoutSets = workoutSets;

  final List<ExerciseSets> _workoutSets;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        shrinkWrap: true,
        itemCount: _workoutSets.length,
        itemBuilder: (context, index) => Card(
            key: Key('$index'),
            child: ExerciseListTile(
                icon: _workoutSets[index].exercise.exerciseType!.icon,
                title: _workoutSets[index].exercise.name,
                subtitle: _workoutSets[index].displayString())));
  }
}
