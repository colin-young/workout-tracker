import 'package:intl/intl.dart';
import 'package:workout_tracker/domain/workout_record.dart';

extension WorkoutUtilities on WorkoutRecord {
  String name() {
    return fromWorkoutDefinition?.name ?? DateFormat('EEEE').format(startedAt); // NON-NLS
  }
}
