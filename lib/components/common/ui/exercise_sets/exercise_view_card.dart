import 'package:flutter/material.dart';
import 'package:workout_tracker/components/common/ui/exercise_sets/exercise_settings_display.dart';
import 'package:workout_tracker/domain/exercise.dart';

class ExerciseViewCard extends StatelessWidget {
  const ExerciseViewCard({
    super.key,
    required this.entry,
  });

  final Exercise entry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 1,
                child: Stack(
                  children: [
                    Text(
                      entry.name,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Opacity(
                        opacity: .2,
                        child: Icon(
                          entry.exerciseType?.deserialize.icon,
                          size: 60,
                        )),
                  ],
                ),
              ),
              Expanded(
                flex: 2,
                child: ExerciseSettingsDisplay(entry: entry),
              ),
            ],
          ),
          entry.note != null
              ? Padding(
                  padding: const EdgeInsets.fromLTRB(10, 0, 10, 4),
                  child: Text(
                    entry.note!,
                    softWrap: true,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                )
              : const SizedBox(),
        ],
      ),
    );
  }
}
