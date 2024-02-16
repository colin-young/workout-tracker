import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sembast/sembast.dart';
import 'package:workout_tracker/data/providers/global_providers.dart';
import 'package:workout_tracker/data/repositories/sembast_repository.dart';
import 'dart:developer' as developer;

import 'package:workout_tracker/domain/exercise.dart';

part 'exercise_repository.g.dart';

@riverpod
ExerciseRepository exerciseRepository(
        ExerciseRepositoryRef ref) =>
    ExerciseRepository(database: ref.watch(databaseProvider));

class ExerciseRepository implements Repository<Exercise> {
  final Database database;
  late final StoreRef<int, Map<String, dynamic>> _store;

  ExerciseRepository({required this.database}) {
    _store = intMapStoreFactory.store('exercise_store');
  }

  @override
  Future delete(int exerciseId) =>
      _store.record(exerciseId).delete(database);

  @override
  Stream<List<Exercise>> getAllEntitiesStream() {
    developer.log('getAllEntitiesStream', name: 'ExerciseRepository');
    return _store.query().onSnapshots(database).map(
          (snapshot) => snapshot
              .map((definition) => Exercise.fromJson(definition.value)
                  .copyWith(id: definition.key))
              .toList(growable: false),
        );
  }

  @override
  Future<int> insert(Exercise exercise) {
    developer.log('insert', name: 'ExerciseRepository');
    return _store.add(database, exercise.toJson());
  }

  @override
  Future update(Exercise exercise) {
    developer.log('update', name: 'ExerciseRepository');
    return _store
        .record(exercise.id)
        .update(database, exercise.toJson());
  }
}

@riverpod
Stream<List<Exercise>> getAllEntitiesStream(
    GetAllEntitiesStreamRef ref) {
  developer.log('getAllEntitiesStream',
      name: 'ExerciseRepository@riverpod');
  return ref.watch(exerciseRepositoryProvider).getAllEntitiesStream();
}

@riverpod
Future<int> insert(InsertRef ref,
    {required Exercise exercise}) {
  return ref
      .watch(exerciseRepositoryProvider)
      .insert(exercise);
}

@riverpod
Future delete(DeleteRef ref, {required int exerciseId}) {
  return ref
      .watch(exerciseRepositoryProvider)
      .delete(exerciseId);
}

@riverpod
Future update(UpdateRef ref, {required Exercise exercise}) {
  return ref
      .watch(exerciseRepositoryProvider)
      .update(exercise);
}
