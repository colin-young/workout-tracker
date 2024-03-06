import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sembast/sembast.dart';
import 'package:workout_tracker/data/providers/global_providers.dart';
import 'package:workout_tracker/data/repositories/exercise_repository.dart';
import 'package:workout_tracker/data/repositories/sembast_repository.dart';
import 'dart:developer' as developer;

import 'package:workout_tracker/domain/exercise_sets.dart';

part 'exercise_sets_repository.g.dart';

@riverpod
ExerciseSetsRepository exerciseSetsRepository(ExerciseSetsRepositoryRef ref) =>
    ExerciseSetsRepository(database: ref.watch(databaseProvider));

class ExerciseSetsRepository implements Repository<ExerciseSets> {
  final Database database;
  late final StoreRef<int, Map<String, dynamic>> _store;

  ExerciseSetsRepository({required this.database}) {
    _store = intMapStoreFactory.store('exercise_sets_store');
  }

  @override
  Future delete(int exerciseId) => _store.record(exerciseId).delete(database);

  @override
  Stream<List<ExerciseSets>> getAllEntitiesStream() {
    return _store.query().onSnapshots(database).map(
          (snapshot) => snapshot
              .map((definition) => ExerciseSets.fromJson(definition.value)
                  .copyWith(id: definition.key))
              .toList(growable: false),
        );
  }

  @override
  Future<List<ExerciseSets>> getAllEntities() async {
    final records = await _store.find(database);
    return records
        .map((e) => ExerciseSets.fromJson(e.value).copyWith(id: e.key))
        .toList();
  }

  @override
  Future<int> insert(ExerciseSets exercise) {
    return _store.add(database, exercise.toJson());
  }

  @override
  Future update(ExerciseSets exercise) {
    return _store.record(exercise.id).update(database, exercise.toJson());
  }

  @override
  Future<ExerciseSets> getEntity(int entityId) async {
    var exerciseRecord = await _store.record(entityId).get(database);
    var exercise =
        ExerciseSets.fromJson(exerciseRecord!).copyWith(id: entityId);
    return exercise;
  }
}

@riverpod
Future<ExerciseSets> getExerciseSets(GetExerciseSetsRef ref,
    {required int entityId}) async {
  developer.log('init', name: 'getExerciseSets');

  ref.onDispose(() {
    developer.log('ref.dispose', name: 'getExerciseSets');
  });
  return await ref.watch(exerciseSetsRepositoryProvider).getEntity(entityId);
}

@riverpod
Future<List<ExerciseSets>> getAllWorkoutExerciseSets(
    GetAllWorkoutExerciseSetsRef ref,
    {required int workoutRecordId}) async {
  developer.log('init', name: 'getAllWorkoutExerciseSets');

  final allSets = await ref.watch(getAllExerciseSetsProvider.future);

  ref.onDispose(() {
    developer.log('ref.dispose', name: 'getAllWorkoutExerciseSets');
  });

  return Future(() => allSets
      .where((element) => element.workoutId == workoutRecordId)
      .toList());
}

@riverpod
Future<ExerciseSets> getWorkoutExerciseSetsByExercise(
    GetWorkoutExerciseSetsByExerciseRef ref,
    {required int workoutRecordId,
    required int exerciseId}) async {
  developer.log('init', name: 'getWorkoutExerciseSetsByExercise');

  final workoutSets = await ref.watch(
      getAllWorkoutExerciseSetsProvider(workoutRecordId: workoutRecordId)
          .future);

  ref.onDispose(() {
    developer.log('ref.dispose', name: 'getWorkoutExerciseSetsByExercise');
  });

  return Future(() async {
    var sets = workoutSets.where((e) {
      return e.exercise.id == exerciseId;
    });
    if (sets.isNotEmpty) {
      return sets.first;
    } else {
      final exerciseResult =
          await ref.watch(getExerciseProvider(entityId: exerciseId).future);
      return Future(() => ExerciseSets(
          workoutId: workoutRecordId,
          exercise: exerciseResult,
          sets: [],
          isComplete: false));
    }
  });
}

@riverpod
Future<Stream<List<ExerciseSets>>> getAllExerciseSetsStream(
    GetAllExerciseSetsStreamRef ref) async {
  developer.log('init', name: 'getAllExerciseSetsStream');

  ref.onDispose(() {
    developer.log('ref.dispose', name: 'getAllExerciseSetsStream');
  });
  return ref.watch(exerciseSetsRepositoryProvider).getAllEntitiesStream();
}

@riverpod
Future<List<ExerciseSets>> getAllExerciseSets(GetAllExerciseSetsRef ref) async {
  developer.log('init', name: 'getAllExerciseSets');

  ref.onDispose(() {
    developer.log('ref.dispose', name: 'getAllExerciseSets');
  });
  return await ref.watch(exerciseSetsRepositoryProvider).getAllEntities();
}

@riverpod
Future<int> insertExerciseSets(InsertExerciseSetsRef ref,
    {required ExerciseSets exercise}) {
  return ref.read(exerciseSetsRepositoryProvider).insert(exercise);
}

@riverpod
Future deleteExerciseSets(DeleteExerciseSetsRef ref,
    {required int exerciseId}) {
  return ref.read(exerciseSetsRepositoryProvider).delete(exerciseId);
}

@riverpod
Future updateExerciseSets(UpdateExerciseSetsRef ref,
    {required ExerciseSets exercise}) {
  return ref.read(exerciseSetsRepositoryProvider).update(exercise);
}
