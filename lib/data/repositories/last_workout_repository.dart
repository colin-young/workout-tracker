import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sembast/sembast.dart';
import 'package:workout_tracker/data/providers/global_providers.dart';
import 'package:workout_tracker/data/repositories/sembast_repository.dart';
import 'package:workout_tracker/domain/workout_definition.dart';
import 'dart:developer' as developer;

import 'package:workout_tracker/domain/workout_record.dart';

part 'last_workout_repository.g.dart';

@riverpod
LastWorkoutRepository lastWorkoutRepository(LastWorkoutRepositoryRef ref) =>
    LastWorkoutRepository(database: ref.watch(databaseProvider));

class LastWorkoutRepository implements Repository<WorkoutRecord> {
  final Database database;
  late final StoreRef<int, Map<String, dynamic>> _store;

  LastWorkoutRepository({required this.database}) {
    _store = intMapStoreFactory.store('workout_record_store');
  }

  @override
  Future delete(int workoutRecordId) =>
      _store.record(workoutRecordId).delete(database);

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
  Future<int> insert(WorkoutRecord workoutRecord) {
    developer.log('insert', name: 'LastWorkoutRepository');
    return _store.add(database, workoutRecord.toJson());
  }

  @override
  Future update(WorkoutRecord workoutRecord) {
    developer.log('update', name: 'LastWorkoutRepository');
    return _store
        .record(workoutRecord.id)
        .update(database, workoutRecord.toJson());
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
Future<WorkoutRecord> getLastworkoutRecord(GetLastworkoutRecordRef ref) async {
  final allrecords =
      await ref.watch(lastWorkoutRepositoryProvider).getAllEntities();
  final lastRecordId = allrecords.fold<int>(
      0,
      (previousValue, element) =>
          element.id > previousValue ? element.id : previousValue);

  return lastRecordId > 0
      ? ref.watch(lastWorkoutRepositoryProvider).getEntity(lastRecordId)
      : Future.value(WorkoutRecord(
          startedAt: DateTime.now(),
          fromWorkoutDefinition:
              const WorkoutDefinition(name: "", exercises: []),
        ));
}
