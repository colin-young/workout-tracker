import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sembast/sembast.dart';
import 'package:workout_tracker/data/providers/global_providers.dart';
import 'package:workout_tracker/data/repositories/sembast_repository.dart';
import 'dart:developer' as developer;

import 'package:workout_tracker/domain/exercise_sets.dart';

part 'exercise_sets_repository.g.dart';

@riverpod
ExerciseSetsRepository exerciseSetsRepository(ExerciseSetsRepositoryRef ref) {
  developer.log('entering',
      name: 'ExerciseSetsRepository.exerciseSetsRepository');

  ref.onDispose(() {
    developer.log('disposing',
        name: 'ExerciseSetsRepository.exerciseSetsRepository');
  });

  return ExerciseSetsRepository(database: ref.watch(databaseProvider));
}

class ExerciseSetsRepository implements Repository<ExerciseSets> {
  final Database database;
  late final StoreRef<int, Map<String, dynamic>> _store;

  final _setsController = StreamController<ExerciseSets>.broadcast();
  Stream<ExerciseSets> get streamExerciseSets => _setsController.stream;

  ExerciseSetsRepository({required this.database}) {
    _store = intMapStoreFactory.store('exercise_sets_store');
  }

  Future<void> close() async {
    await Future.wait([
      _setsController.close(),
    ]);
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

  Stream<List<ExerciseSets>> getWorkoutSetsStream({required int workoutId}) {
    return _store
        .query(
            finder: Finder(
                filter: Filter.equals('workoutId', workoutId),
                sortOrders: [SortOrder('workoutId'), SortOrder('order')]))
        .onSnapshots(database)
        .map(
          (snapshot) => snapshot
              .map((definition) => ExerciseSets.fromJson(definition.value)
                  .copyWith(id: definition.key))
              .toList(),
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
  Future<int> insert(ExerciseSets exercise) async {
    var add = await _store.add(database, exercise.toJson());
    _setsController.add(exercise.copyWith(id: add));
    return add;
  }

  @override
  Future update(ExerciseSets exercise) async {
    developer.log('', name: 'exerciseSetsRepositoryProvider.update');
    var update =
        await _store.record(exercise.id).update(database, exercise.toJson());
    _setsController.add(exercise);
    return update;
  }

  @override
  Future<ExerciseSets> getEntity(int entityId) async {
    var exerciseRecord = await _store.record(entityId).get(database);
    var exercise =
        ExerciseSets.fromJson(exerciseRecord!).copyWith(id: entityId);
    return exercise;
  }
}

// @riverpod
// Future<ExerciseSets> getExerciseSets(GetExerciseSetsRef ref,
//     {required int entityId}) async {
//   // developer.log('entering', name: 'ExerciseSetsRepository.getExerciseSets');

//   // ref.onDispose(() {
//   //   developer.log('disposing', name: 'ExerciseSetsRepository.getExerciseSets');
//   // });

//   return await ref.watch(exerciseSetsRepositoryProvider).getEntity(entityId);
// }

@riverpod
Future<List<ExerciseSets>> getAllWorkoutExerciseSets(
    GetAllWorkoutExerciseSetsRef ref,
    {required int workoutRecordId}) async {
  // developer.log('entering',
  //     name: 'ExerciseSetsRepository.getAllWorkoutExerciseSets');

  // ref.onDispose(() {
  //   developer.log('disposing',
  //       name: 'ExerciseSetsRepository.getAllWorkoutExerciseSets');
  // });

  final allSets = await ref.watch(getAllExerciseSetsStreamProvider.selectAsync(
      (data) => data
          .where((element) => element.workoutId == workoutRecordId)
          .toList()));

  return allSets;
}

@riverpod
Future<List<ExerciseSets>> getAllWorkoutExerciseSetsInProgress(
    GetAllWorkoutExerciseSetsInProgressRef ref,
    {required int workoutRecordId}) async {
  // developer.log('entering',
  //     name: 'ExerciseSetsRepository.getAllWorkoutExerciseSetsInProgress');

  // ref.onDispose(() {
  //   developer.log('disposing',
  //       name: 'ExerciseSetsRepository.getAllWorkoutExerciseSetsInProgress');
  // });

  final allSets = await ref.watch(getAllExerciseSetsStreamProvider.selectAsync(
      (value) => value
          .where((element) =>
              element.workoutId == workoutRecordId && element.sets.isNotEmpty)
          .toList()));

  return allSets;
}

@riverpod
Stream<List<ExerciseSets>> getAllExerciseSetsStream(
    GetAllExerciseSetsStreamRef ref) {
  // developer.log('entering',
  //     name: 'ExerciseSetsRepository.getAllExerciseSetsStream');

  // ref.onDispose(() {
  //   developer.log('disposing',
  //       name: 'ExerciseSetsRepository.getAllExerciseSetsStream');
  // });

  return ref.watch(exerciseSetsRepositoryProvider).getAllEntitiesStream();
}

@riverpod
Stream<List<ExerciseSets>> getAllExerciseSetsByExerciseStream(
    GetAllExerciseSetsByExerciseStreamRef ref,
    {required int exerciseId}) async* {
  final allSets =
      await ref.watch(exerciseSetsRepositoryProvider).getAllEntities();
  final exerciseSets =
      allSets.where((element) => element.exercise.id == exerciseId).toList();

  yield exerciseSets;
}

@riverpod
Future<bool> canCompleteSets(CanCompleteSetsRef ref,
    {required workoutRecordId}) async {
  final currentWorkoutExercise = await ref.watch(
      workoutCurrentExerciseStreamProvider(workoutRecordId: workoutRecordId)
          .future);

  return currentWorkoutExercise?.sets.isNotEmpty ?? false;
}

@riverpod
Stream<ExerciseSets?> getWorkoutExerciseSetsStream(
    GetWorkoutExerciseSetsStreamRef ref,
    {required int workoutId,
    required int exerciseId}) async* {
  // developer.log('entering',
  //     name: 'ExerciseSetsRepository.getWorkoutExerciseSetsStream');

  // ref.onDispose(() {
  //   developer.log('disposing',
  //       name: 'ExerciseSetsRepository.getWorkoutExerciseSetsStream');
  // });

  final sets = ref
      .watch(exerciseSetsRepositoryProvider)
      .getWorkoutSetsStream(workoutId: workoutId);

  await for (final set in sets) {
    if (set.isNotEmpty) {
      var filteredSets = set.where((s) => s.exercise.id == exerciseId);
      if (filteredSets.isNotEmpty) {
        yield filteredSets.first;
      }
    }
  }
}

/// Get all the sets (exercises) for a given workout. Includes complete,
/// incomplete and not started sets.
@riverpod
Stream<List<ExerciseSets>> getWorkoutSetsStream(GetWorkoutSetsStreamRef ref,
    {required int workoutId}) async* {
  // developer.log('entering',
  //     name: 'ExerciseSetsRepository.getCompletedExerciseSetsStream');

  // ref.onDispose(() {
  //   developer.log('disposing',
  //       name: 'ExerciseSetsRepository.getCompletedExerciseSetsStream');
  // });

  final sets = ref
      .watch(exerciseSetsRepositoryProvider)
      .getWorkoutSetsStream(workoutId: workoutId);

  await for (final set in sets) {
    if (set.isNotEmpty) {
      yield set;
    } else {
      yield [];
    }
  }
}

@riverpod
Stream<List<ExerciseSets>> getCompletedExerciseSetsStream(
    GetCompletedExerciseSetsStreamRef ref,
    {required int workoutId}) async* {
  // developer.log('entering',
  //     name: 'ExerciseSetsRepository.getCompletedExerciseSetsStream');

  // ref.onDispose(() {
  //   developer.log('disposing',
  //       name: 'ExerciseSetsRepository.getCompletedExerciseSetsStream');
  // });

  final sets = ref
      .watch(exerciseSetsRepositoryProvider)
      .getWorkoutSetsStream(workoutId: workoutId);

  await for (final set in sets) {
    if (set.isNotEmpty) {
      yield set.where((s) => s.isComplete).toList();
    }
  }
}

@riverpod
Stream<List<ExerciseSets>> getIncompleteExerciseSetsStream(
    GetIncompleteExerciseSetsStreamRef ref,
    {required int workoutId}) async* {
  developer.log('entering',
      name: 'ExerciseSetsRepository.getIncompleteExerciseSetsStream');

  ref.onDispose(() {
    developer.log('disposing',
        name: 'ExerciseSetsRepository.getIncompleteExerciseSetsStream');
  });

  final sets = ref
      .watch(exerciseSetsRepositoryProvider)
      .getWorkoutSetsStream(workoutId: workoutId);

  await for (final set in sets) {
    if (set.isNotEmpty) {
      yield set.where((set) => !set.isComplete).toList();
    }
  }
}

@riverpod
Stream<List<ExerciseSets>> getUpcomingExerciseSetsStream(
    GetUpcomingExerciseSetsStreamRef ref,
    {required int workoutId,
    required int exerciseId}) async* {
  // developer.log('entering',
  //     name: 'ExerciseSetsRepository.getUpcomingExerciseSetsStream');

  // ref.onDispose(() {
  //   developer.log('disposing',
  //       name: 'ExerciseSetsRepository.getUpcomingExerciseSetsStream');
  // });

  final sets = ref
      .watch(exerciseSetsRepositoryProvider)
      .getWorkoutSetsStream(workoutId: workoutId);

  await for (final set in sets) {
    if (set.isNotEmpty) {
      yield set
          .where((s) => !s.isComplete && s.exercise.id != exerciseId)
          .toList();
    }
  }
}

@riverpod
Future deleteExerciseSets(DeleteExerciseSetsRef ref,
    {required int exerciseId}) async {
  // developer.log('entering', name: 'ExerciseSetsRepository.deleteExerciseSets');

  // ref.onDispose(() {
  //   developer.log('disposing',
  //       name: 'ExerciseSetsRepository.deleteExerciseSets');
  // });

  var delete = await ref.read(exerciseSetsRepositoryProvider).delete(exerciseId);

  ref.invalidate(exerciseSetsRepositoryProvider);

  return delete;
}

@riverpod
Future updateExerciseSets(UpdateExerciseSetsRef ref,
    {required ExerciseSets exercise}) {
  // developer.log('entering', name: 'ExerciseSetsRepository.updateExerciseSets');

  // ref.onDispose(() {
  //   developer.log('disposing',
  //       name: 'ExerciseSetsRepository.updateExerciseSets');
  // });

  return ref.read(exerciseSetsRepositoryProvider).update(exercise);
}

@riverpod
Stream<ExerciseSets?> workoutCurrentExerciseStream(
    WorkoutCurrentExerciseStreamRef ref,
    {required int workoutRecordId}) async* {
  developer.log('entering',
      name: 'WorkoutRecordRepository.workoutCurrentExerciseStream');

  ref.onDispose(() {
    developer.log('disposing',
        name: 'WorkoutRecordRepository.workoutCurrentExerciseStream');
  });
  final workout = await ref.watch(
      getIncompleteExerciseSetsStreamProvider(workoutId: workoutRecordId)
          .future);

  if (workout.isNotEmpty) {
    developer.log('first item: ${workout.first.id}, ${workout.first.exercise.name}',
        name: 'WorkoutRecordRepository.workoutCurrentExerciseStream');
    yield workout.first;
  }
}
