import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:workout_tracker/data/providers/workout_record_provider.dart';
import 'package:workout_tracker/data/repositories/mock_data.dart';
import 'package:workout_tracker/domain/workout_record.dart';

part 'workout_record_repository.g.dart';

class WorkoutRecordRepository {
  final WorkoutRecord client;
  WorkoutRecordRepository({required this.client});

  Future<WorkoutRecord> getLastWorkoutRecord() {
    return Future.value(MockData.factory().workoutRecord);
  }
}

@riverpod
WorkoutRecordRepository workoutRecordRepository(
        WorkoutRecordRepositoryRef ref) => WorkoutRecordRepository(
  client: ref.watch(workoutRecordDataProvider)
);

@riverpod
Future<WorkoutRecord> getLastWorkoutRecord(
  GetLastWorkoutRecordRef ref) {
  return ref.watch(workoutRecordRepositoryProvider).getLastWorkoutRecord();
}
