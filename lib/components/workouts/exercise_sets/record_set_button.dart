import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workout_tracker/components/common/rounded_button.dart';
import 'package:workout_tracker/components/common/rounded_display.dart';
import 'package:workout_tracker/controller/exercise_sets_controller.dart';
import 'package:workout_tracker/domain/set_entry.dart';

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
    var displayTextColor = Theme.of(context).colorScheme.onSecondaryContainer;
    var displayBackgroundColor =
        Theme.of(context).colorScheme.secondaryContainer;

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
              RoundedButton(
                text: const Text("Record Set"),
                icon: Icons.check,
                onPressed: () async {
                  await ref
                      .read(exerciseSetsControllerProvider.notifier)
                      .addWorkoutSet(
                          workoutRecordId: workoutRecordId, newSet: workoutSet);
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
