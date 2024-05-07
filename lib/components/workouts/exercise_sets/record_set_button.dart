import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workout_tracker/controller/exercise_sets_controller.dart';
import 'package:workout_tracker/controller/timer_controller.dart';
import 'package:workout_tracker/controller/user_preferences_state.dart';
import 'package:workout_tracker/domain/set_entry.dart';
import 'package:workout_tracker/timer/timer_event.dart';

class RecordSetButton extends ConsumerWidget with UserPreferencesState {
  const RecordSetButton({
    super.key,
    required this.workoutSet,
    required this.textStyle,
    required this.workoutRecordId,
  });

  final SetEntry workoutSet;
  final TextStyle? textStyle;
  final int workoutRecordId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var largeTitleText = Theme.of(context).textTheme.titleMedium;
    var mediumTitleText = Theme.of(context).textTheme.bodySmall;
    var smallTitleText = Theme.of(context).textTheme.bodySmall;

    return Card.outlined(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        workoutSet.reps.toString(),
                        style: largeTitleText!,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'reps',
                        style: Theme.of(context).textTheme.bodySmall!,
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      const SizedBox(width: 8),
                      Text(
                        workoutSet.weight.toString(),
                        style: mediumTitleText,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        workoutSet.units,
                        style: smallTitleText,
                      ),
                    ],
                  ),
                ]),
            FilledButton.tonal(
              onPressed: () async {
                await ref
                    .read(exerciseSetsControllerProvider.notifier)
                    .addWorkoutSet(
                        workoutRecordId: workoutRecordId, newSet: workoutSet);
                ref.read(getAllowedEventsProvider.future).then((value) {
                  ref.read(timerControllerProvider.notifier).handleEvent(
                      Reset(duration: userPreferences(ref).timerLength));
                  ref
                      .read(timerControllerProvider.notifier)
                      .handleEvent(Start());
                });
              },
              child: const Row(
                children: [
                  Icon(Icons.check),
                  SizedBox(width: 8),
                  Text('Record set'),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
