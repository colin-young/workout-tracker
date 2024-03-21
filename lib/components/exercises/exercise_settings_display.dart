import 'package:flutter/material.dart';
import 'package:workout_tracker/components/common/rounded_display.dart';
import 'package:workout_tracker/domain/exercise.dart';

class ExerciseSettingsDisplay extends StatelessWidget {
  const ExerciseSettingsDisplay({
    super.key,
    required this.entry,
  });

  final Exercise entry;

  @override
  Widget build(BuildContext context) {
    final onBackgroundColor = Theme.of(context).colorScheme.onSecondary;
    final backgroundColor = Theme.of(context).colorScheme.secondary;

    return Wrap(
      alignment: WrapAlignment.spaceAround,
      runAlignment: WrapAlignment.spaceAround,
      children: [
        for (var item in entry.settings)
          RoundedDisplay(
            width: 100,
            background: backgroundColor,
            child: Row(
              children: [
                Text(item.setting, style: Theme.of(context).textTheme.bodySmall
                    ?.copyWith(color: onBackgroundColor),
                    ),
                SizedBox(
                  height: 12,
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      VerticalDivider(
                        thickness: 1,
                        indent: 0,
                        endIndent: 0,
                        color: onBackgroundColor,
                      ),
                    ],
                  ),
                ),
                Text(
                  item.value,
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: onBackgroundColor),
                ),
              ],
            ),
          )
      ],
    );
  }
}
