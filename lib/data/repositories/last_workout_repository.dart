import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sembast/sembast.dart';
import 'package:workout_tracker/data/providers/global_providers.dart';
import 'package:workout_tracker/data/repositories/exercise_sets_repository.dart';
import 'package:workout_tracker/data/repositories/sembast_repository.dart';
import 'package:workout_tracker/data/repositories/workout_record_repository.dart';
import 'dart:developer' as developer;

import 'package:workout_tracker/domain/workout_record.dart';
import 'package:workout_tracker/utility/exercise_sets_extensions.dart';

part 'last_workout_repository.g.dart';

@riverpod
LastWorkoutRepository lastWorkoutRepository(LastWorkoutRepositoryRef ref) =>
    LastWorkoutRepository(database: ref.watch(databaseProvider));

class LastWorkoutRepository implements ReadOnlyRepository<WorkoutRecord> {
  final Database database;
  late final StoreRef<int, Map<String, dynamic>> _store;

  LastWorkoutRepository({required this.database}) {
    _store = intMapStoreFactory.store('workout_record_store');
  }

  @override
  Stream<List<WorkoutRecord>> getAllEntitiesStream() {
    developer.log('getAllEntitiesStream', name: 'LastWorkoutRepository');
    return _store.query().onSnapshots(database).map(
          (snapshot) => snapshot
              .map((definition) => WorkoutRecord.fromJson(definition.value)
                  .copyWith(id: definition.key))
              .toList(growable: false),
        );
  }

  @override
  Future<List<WorkoutRecord>> getAllEntities() async {
    final records = await _store.find(database);
    return records
        .map((e) => WorkoutRecord.fromJson(e.value).copyWith(id: e.key))
        .toList();
  }

  @override
  Future<WorkoutRecord> getEntity(int entityId) async {
    var workoutRecordRecord = await _store.record(entityId).get(database);
    var workoutRecord =
        WorkoutRecord.fromJson(workoutRecordRecord!).copyWith(id: entityId);
    return workoutRecord;
  }
}

@riverpod
Stream<WorkoutRecord> getLastworkoutRecord(GetLastworkoutRecordRef ref) async* {
  // developer.log('entering', name: 'LastWorkoutRepository.getLastworkoutRecord');

  // ref.onDispose(() {
  //   developer.log('disposing', name: 'LastWorkoutRepository.getLastworkoutRecord');
  // });

  var allrecords = await ref
      .watch(getAllExerciseSetsStreamProvider.selectAsync((value) async {
    // for (final val in value) {
      value.sort((a, b) => a.latestDateTime().compareTo(b.latestDateTime()));
      return value;
    // }
  }));

  if ((await allrecords).isNotEmpty) {
    final lastRecord = await allrecords;
    final workoutRecord = await ref.watch(
        getWorkoutRecordProvider(workoutRecordId: lastRecord.first.workoutId)
            .future);
    yield workoutRecord;
  }
}
