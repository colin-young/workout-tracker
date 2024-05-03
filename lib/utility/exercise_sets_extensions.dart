import 'package:workout_tracker/domain/exercise_sets.dart';

extension SetsDisplayString on ExerciseSets? {
  String displayString() {
    return this
            ?.sets
            .map((element) =>
                '${element.reps}⨉${element.weight} ${element.units}') // NON-NLS
            .join(', ') ??
        'No sets recorded';
  }
}

extension LatestDateTime on ExerciseSets? {
  DateTime latestDateTime() {
    return this!.sets.fold<DateTime>(
        DateTime.fromMicrosecondsSinceEpoch(0),
        (prevDate, curr) =>
            (curr.finishedAt.compareTo(prevDate) > 0) ? curr.finishedAt : prevDate);
  }
}
