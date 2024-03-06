import 'package:workout_tracker/domain/exercise_sets.dart';

extension SetsDisplayString on ExerciseSets? {
  String displayString() {
    return this?.sets
        .map((element) => '${element.reps}⨉${element.weight} ${element.units}')
        .join(', ') ?? 'No sets recorded';
  }
}
