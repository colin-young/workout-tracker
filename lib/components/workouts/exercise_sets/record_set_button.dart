import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workout_tracker/components/common/rounded_display.dart';
import 'package:workout_tracker/controller/exercise_sets_controller.dart';
import 'package:workout_tracker/controller/timer_controller.dart';
import 'package:workout_tracker/domain/set_entry.dart';
import 'package:workout_tracker/timer/timer_context.dart';
import 'package:workout_tracker/timer/timer_event.dart';

class RecordSetButton extends ConsumerWidget {
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
    var displayTextColor = Theme.of(context).colorScheme.onSurface;
    var displayBackgroundColor = Theme.of(context).colorScheme.surface;

    var largeTitleText = Theme.of(context).textTheme.titleMedium;
    var mediumTitleText = Theme.of(context).textTheme.bodySmall;
    var smallTitleText = Theme.of(context).textTheme.bodySmall;

    return RoundedDisplay(
      background: displayBackgroundColor,
      height: mediumTitleText!.height! + smallTitleText!.height! + 24,
      child: Expanded(
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
                          style:
                              largeTitleText!.copyWith(color: displayTextColor),
                        ),
                        const SizedBox(
                          width: 4,
                        ),
                        Text(
                          'reps',
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall!
                              .copyWith(color: displayTextColor),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        const SizedBox(
                          width: 8,
                        ),
                        Text(
                          workoutSet.weight.toString(),
                          style:
                              mediumTitleText.copyWith(color: displayTextColor),
                        ),
                        const SizedBox(
                          width: 4,
                        ),
                        Text(
                          workoutSet.units,
                          style:
                              smallTitleText.copyWith(color: displayTextColor),
                        ),
                      ],
                    ),
                  ]),
              FilledButton(
                onPressed: () async {
                  await ref
                      .read(exerciseSetsControllerProvider.notifier)
                      .addWorkoutSet(
                          workoutRecordId: workoutRecordId, newSet: workoutSet);
                  ref.read(getAllowedEventsProvider.future).then((value) {
                    if (value
                        .any((element) => element.name == Running().name)) {
                      ref
                          .read(timerControllerProvider.notifier)
                          .handleEvent(Reset());
                    } else {
                      ref
                          .read(timerControllerProvider.notifier)
                          .handleEvent(Start());
                    }
                  });
                },
                child: const Row(
                  children: [
                    Icon(Icons.check),
                    SizedBox(
                      width: 8,
                    ),
                    Text('Record Set'),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
