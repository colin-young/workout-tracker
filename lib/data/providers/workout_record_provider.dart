import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:workout_tracker/data/repositories/mock_data.dart';
import 'package:workout_tracker/domain/workout_record.dart';

part 'workout_record_provider.g.dart';

@riverpod
WorkoutRecord workoutRecordData(WorkoutRecordDataRef ref) {
  return MockData.factory().workoutRecord;
}
