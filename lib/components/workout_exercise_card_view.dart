import 'package:flutter/material.dart';
import 'package:workout_tracker/components/sets_list_view.dart';
import 'package:workout_tracker/domain/workout_sets.dart';

class WorkoutExerciseCardView extends StatelessWidget {
  const WorkoutExerciseCardView({
    super.key,
    required this.workoutExercise,
  });

  final WorkoutSets workoutExercise;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
          elevation: 5,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(workoutExercise.exercise.name,
                      style: Theme.of(context).textTheme.headlineSmall,
                      softWrap: true,),
                      Builder(builder: (context) {
                        if (workoutExercise.isComplete) {
                          return const Icon(Icons.check);
                        }
                      
                        return const Text("active");
                      })
                    ],
                  ),
                ),
                Expanded(child: SetsListView(workoutExercise.sets)),
              ],
            ),
          )),
    );
  }
}
