import 'package:flutter/material.dart';
import 'package:workout_tracker/components/common/ui/card/action_card_header.dart';
import 'package:workout_tracker/components/workouts/exercise_sets/exercise_sets_list_with_sets_tile.dart';

class WorkoutTrackerCard extends StatelessWidget {
  const WorkoutTrackerCard({
    super.key,
    required this.header,
    required this.body,
  });

  final ActionCardHeader header;
  final ExerciseSetsListWithSetsTile body;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 1,
      shadowColor: Colors.transparent,
      child: Column(mainAxisSize: MainAxisSize.min, children: [header, body]),
    );
  }
}
