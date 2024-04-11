import 'package:workout_tracker/domain/set_entry.dart';

class SetEntryUtils {
  static double oneRMEpley(SetEntry se) => se.weight * (1.0 + se.reps / 30.0);
  static double totalWeightPerSet(SetEntry se) =>
      (se.weight * se.reps).toDouble();

}
