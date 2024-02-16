import 'package:flutter/material.dart';
import 'package:workout_tracker/components/card_title_divider.dart';
import 'package:workout_tracker/components/relative_date.dart';
import 'package:workout_tracker/components/rounded_button.dart';
import 'package:workout_tracker/domain/workout_record.dart';

class WorkoutSummaryCard extends StatelessWidget {
  final WorkoutRecord workoutRecord;

  const WorkoutSummaryCard(
    this.workoutRecord, {
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    var finishedAt = workoutRecord.finishedAt();
    return Padding(
        padding: const EdgeInsets.all(5.0),
        child: Card(
            elevation: 5.0,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(children: <Widget>[
                Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        workoutRecord.fromWorkoutDefinition.name,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      if (!workoutRecord.isComplete())
                        RoundedButton(
                            onPressed: () => null,
                            text: "Continue Current",
                            icon: Icons.play_arrow),
                    ]),
                CardTitleDivider(child: RelativeDate(finishedAt)),
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Text('${workoutRecord.totalExercises()} exercises'),
                      Text('${workoutRecord.totalReps()} reps'),
                      Text(
                          '${workoutRecord.totalWeight()} ${workoutRecord.units()}'),
                    ],
                  ),
                ),
              ]),
            )));
  }
}
