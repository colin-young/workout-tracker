import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sembast/sembast.dart';
import 'package:workout_tracker/data/providers/global_providers.dart';
import 'package:workout_tracker/data/repositories/exercise_sets_repository.dart';
import 'package:workout_tracker/data/repositories/sembast_repository.dart';
import 'package:workout_tracker/data/workout_definition/workout_definitions_repository.dart';
import 'package:workout_tracker/domain/workout_definition.dart';
import 'dart:developer' as developer;

import 'package:workout_tracker/domain/workout_record.dart';
import 'package:workout_tracker/utility/exercise_sets_extensions.dart';

part 'workout_record_repository.g.dart';

@riverpod
WorkoutRecordRepository workoutRecordRepository(
        WorkoutRecordRepositoryRef ref) =>
    WorkoutRecordRepository(database: ref.watch(databaseProvider));

class WorkoutRecordRepository implements Repository<WorkoutRecord> {
  final Database database;
  late final StoreRef<int, Map<String, dynamic>> _store;

  WorkoutRecordRepository({required this.database}) {
    _store = intMapStoreFactory.store('workout_record_store');
  }

  @override
  Future delete(int workoutRecordId) =>
      _store.record(workoutRecordId).delete(database);

  @override
  Stream<List<WorkoutRecord>> getAllEntitiesStream() {
    developer.log('getAllEntitiesStream', name: 'WorkoutRecordRepository');
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
    developer.log('insert', name: 'WorkoutRecordRepository');
    return _store.add(database, workoutRecord.toJson());
  }

  @override
  Future update(WorkoutRecord workoutRecord) {
    developer.log('update', name: 'WorkoutRecordRepository');
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

  Stream<WorkoutRecord> getWorkoutRecordStream({required int workoutId}) {
    return _store
        .query(finder: Finder(filter: Filter.equals(Field.key, workoutId)))
        .onSnapshots(database)
        .map(
          (snapshot) => snapshot
              .map((definition) => WorkoutRecord.fromJson(definition.value)
                  .copyWith(id: definition.key))
              .toList()
              .first,
        );
  }
}

@riverpod
Future<WorkoutRecord> getWorkoutRecord(GetWorkoutRecordRef ref,
    {required int workoutRecordId}) async {
  return workoutRecordId > 0
      ? ref.watch(workoutRecordRepositoryProvider).getEntity(workoutRecordId)
      : Future.value(WorkoutRecord(
          startedAt: DateTime.now(),
          fromWorkoutDefinition:
              const WorkoutDefinition(name: "", exercises: []),
        ));
}

@riverpod
Stream<WorkoutRecord> getWorkoutRecordStream(GetWorkoutRecordStreamRef ref,
    {required int workoutRecordId}) {
  return ref
      .watch(workoutRecordRepositoryProvider)
      .getWorkoutRecordStream(workoutId: workoutRecordId);
}

// @riverpod
// Stream<List<WorkoutRecord>> getAllEntitiesStream(GetAllEntitiesStreamRef ref) {
//   developer.log('getAllEntitiesStream', name: 'WorkoutRecordRepository@riverpod');
//   return ref.watch(workoutRecordRepositoryProvider).getAllEntitiesStream();
// }

// @riverpod
// Future<int> insertWorkoutRecord(InsertWorkoutRecordRef ref,
//     {required WorkoutRecord workoutRecord}) {
//   developer.log('insertWorkoutRecord', name: 'workoutRecordRepositoryProvider');
//   return ref.watch(workoutRecordRepositoryProvider).insert(workoutRecord);
// }

// @riverpod
// Future deleteWorkoutRecord(DeleteWorkoutRecordRef ref, {required int workoutRecordId}) {
//   developer.log('deleteWorkoutRecord', name: 'workoutRecordRepositoryProvider');
//   return ref.watch(workoutRecordRepositoryProvider).delete(workoutRecordId);
// }

// @riverpod
// Future updateWorkoutRecord(UpdateWorkoutRecordRef ref, {required WorkoutRecord workoutRecord}) {
//   developer.log('updateWorkoutRecord', name: 'workoutRecordRepositoryProvider');
//   return ref.watch(workoutRecordRepositoryProvider).update(workoutRecord);
// }

@riverpod
Future<DateTime> workoutFinishedAt(WorkoutFinishedAtRef ref,
    {required int workoutRecordId}) async {
  final currentTime = DateTime.now();
  final workoutSets = await ref.watch(
      getAllWorkoutExerciseSetsProvider(workoutRecordId: workoutRecordId)
          .future);

  var list = workoutSets.expand((e) => e.sets).toList();
  list.sort((a, b) => a.finishedAt.compareTo(b.finishedAt));
  return list.isEmpty ? currentTime : list.first.finishedAt;
}

@riverpod
Future<bool> isWorkoutComplete(IsWorkoutCompleteRef ref,
    {required int workoutRecordId}) async {
  final workoutSets = await ref.watch(
      getAllWorkoutExerciseSetsProvider(workoutRecordId: workoutRecordId)
          .future);
  var workoutSets2 = workoutSets.every((element) {
    return element.isComplete;
  });
  return workoutSets2;
}

@riverpod
Future<WorkoutRecord> completeAllWorkoutExercises(
    CompleteAllWorkoutExercisesRef ref,
    {required int workoutRecordId}) async {
  final workoutExercises = await ref.read(
      getAllWorkoutExerciseSetsProvider(workoutRecordId: workoutRecordId)
          .future);

  final List<Future<Object?>> updates = [];
  for (final exercise in workoutExercises) {
    if (!exercise.isComplete) {
      updates.add(ref.read(updateExerciseSetsProvider(
              exercise: exercise.copyWith(isComplete: true))
          .future));
    }
  }
  Future.wait(updates);

  return ref
      .watch(getWorkoutRecordProvider(workoutRecordId: workoutRecordId).future);
}

@riverpod
Future<String> workoutSetsUnits(WorkoutSetsUnitsRef ref,
    {required int workoutRecordId, required String defaultUnits}) async {
  final workoutSets = await ref.watch(
      getAllWorkoutExerciseSetsProvider(workoutRecordId: workoutRecordId)
          .future);
  if (workoutSets.isEmpty) {
    return '';
  }
  return workoutSets.fold(defaultUnits, (previousValue, element) {
    var nextValue = element.sets.fold(defaultUnits, (prev, curr) {
      return prev == '' || prev == curr.units ? curr.units : 'unknown';
    });

    return previousValue == '' || previousValue == nextValue
        ? nextValue
        : 'unknown';
  });
}

@riverpod
Future<int> workoutTotalWeight(WorkoutTotalWeightRef ref,
    {required int workoutRecordId}) async {
  final workoutSets = await ref.watch(
      getAllWorkoutExerciseSetsProvider(workoutRecordId: workoutRecordId)
          .future);
  // get sum of reps times weight properties
  // get the sum of reps times weight properties in Dart Language:
  if (workoutSets.isEmpty) {
    return 0;
  }
  // TODO convert to userPrefsWeightUnits
  return workoutSets.fold(
      0,
      (previousValue, element) async =>
          await previousValue +
          element.sets
              .fold(0, (prev, curr) => prev + (curr.reps * curr.weight)));
}

@riverpod
Future<int> workoutTotalExercises(WorkoutTotalExercisesRef ref,
    {required int workoutRecordId}) async {
  final workoutSets = await ref.watch(
      getAllWorkoutExerciseSetsProvider(workoutRecordId: workoutRecordId)
          .future);
  return {
    for (var e in workoutSets.where((element) => element.sets.isNotEmpty))
      e.exercise.id: e
  }.length;
}

@riverpod
Future<int> totalWorkoutReps(TotalWorkoutRepsRef ref,
    {required int workoutRecordId}) async {
  final workoutSets = await ref.watch(
      getAllWorkoutExerciseSetsProvider(workoutRecordId: workoutRecordId)
          .future);
  return await workoutSets.fold(
      0,
      (previousValue, element) async =>
          await previousValue +
          element.sets.fold(0, (prev, curr) => prev + curr.reps));
}

@riverpod
Stream<WorkoutRecord> getLastworkoutRecord(GetLastworkoutRecordRef ref) async* {
  var allrecords = await ref
      .watch(getAllExerciseSetsStreamProvider.selectAsync((value) async {
    value.sort((a, b) => a.latestDateTime().compareTo(b.latestDateTime()));
    return value;
  }));

  if ((await allrecords).isNotEmpty) {
    final lastRecord = await allrecords;
    final workoutRecord = await ref.watch(
        getWorkoutRecordProvider(workoutRecordId: lastRecord.first.workoutId)
            .future);
    yield workoutRecord;
  }
}

typedef WorkoutDefinitionDate = ({
  WorkoutDefinition definition,
  DateTime? date,
});

@riverpod
Stream<List<WorkoutDefinitionDate>> getLastWorkoutDate(
    GetLastWorkoutDateRef ref) async* {
  final allDefinitions =
      await ref.watch(workoutDefinitionsRepositoryProvider).getAllEntities();
  final allWorkouts =
      await ref.read(workoutRecordRepositoryProvider).getAllEntities();
  allWorkouts.sort((a, b) => -a.id.compareTo(b.id));

  final definitionDates = allDefinitions.map((definition) async {
    final lastWorkout = allWorkouts.where((workout) {
      return workout.fromWorkoutDefinition?.id == definition.id;
    }).firstOrNull;

    final DateTime? finishedAt;
    if (lastWorkout != null) {
      finishedAt = lastWorkout.lastActivityAt;
    } else {
      finishedAt = null;
    }

    return (definition: definition, date: finishedAt);
  }).toList();

  yield await Future.wait(definitionDates);
}
