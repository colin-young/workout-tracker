import 'package:flutter/material.dart';
import 'package:flutter_application_1/components/relative_date.dart';
import 'package:flutter_application_1/components/rounded_button.dart';
import 'package:flutter_application_1/domain/workout_record.dart';

class WorkoutSummaryCard extends StatelessWidget {
  final WorkoutRecord workoutRecord;

  const WorkoutSummaryCard(
    this.workoutRecord, {
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.all(5.0),
        child: Card(
            elevation: 5.0,
            // color: Theme.of(context).colorScheme.secondaryContainer,
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
                        const RoundedButton(
                            "Continue Current", Icons.play_arrow),
                    ]),
                Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(
                        width: 10,
                        child:
                            Column(mainAxisSize: MainAxisSize.min, children: [
                          Divider(
                            thickness: 1,
                            indent: 0,
                            endIndent: 5,
                            color: Theme.of(context).colorScheme.primary,
                          )
                        ])),
                    RelativeDate(workoutRecord.finishedAt()),
                    Expanded(
                        child:
                            Column(mainAxisSize: MainAxisSize.max, children: [
                      Divider(
                        thickness: 1,
                        indent: 5,
                        endIndent: 0,
                        color: Theme.of(context).colorScheme.primary,
                      )
                    ])),
                  ],
                ),
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
