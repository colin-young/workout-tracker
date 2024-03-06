import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:workout_tracker/data/repositories/workout_record_repository.dart';
import 'package:workout_tracker/domain/workout_record.dart';

part 'workout_record_controller.g.dart';

@riverpod
class WorkoutRecordController extends _$WorkoutRecordController {
  @override
  FutureOr<WorkoutRecord> build({required int workoutRecordId}) async {
    final workoutRecordRepository = ref.watch(workoutRecordRepositoryProvider);

    state = const AsyncLoading();
    final workoutRecord = workoutRecordRepository.getEntity(workoutRecordId);
    state = await AsyncValue.guard(() => workoutRecord);
    return workoutRecord;
  }

}
