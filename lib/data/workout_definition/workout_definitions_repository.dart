import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sembast/sembast.dart';
import 'package:workout_tracker/data/providers/global_providers.dart';
import 'package:workout_tracker/data/repositories/sembast_repository.dart';
import 'package:workout_tracker/domain/workout_definition.dart';
import 'dart:developer' as developer;

part 'workout_definitions_repository.g.dart';

@riverpod
WorkoutDefinitionsRepository workoutDefinitionsRepository(
        WorkoutDefinitionsRepositoryRef ref) =>
    WorkoutDefinitionsRepository(database: ref.watch(databaseProvider));

class WorkoutDefinitionsRepository implements Repository<WorkoutDefinition> {
  final Database database;
  late final StoreRef<int, Map<String, dynamic>> _store;

  WorkoutDefinitionsRepository({required this.database}) {
    _store = intMapStoreFactory.store('workout_definition_store');
  }

  @override
  Future delete(int workoutDefinitionId) =>
      _store.record(workoutDefinitionId).delete(database);

  @override
  Stream<List<WorkoutDefinition>> getAllEntitiesStream() {
    developer.log('getAllEntitiesStream',
        name: 'WorkoutDefinitionsRepository');
    return _store.query().onSnapshots(database).map(
          (snapshot) => snapshot
              .map((definition) => WorkoutDefinition.fromJson(definition.value)
                  .copyWith(id: definition.key))
              .toList(growable: false),
        );
  }
  
  @override
  Future<List<WorkoutDefinition>> getAllEntities() async {
    final records = await _store.find(database);
    return records.map((e) => WorkoutDefinition.fromJson(e.value)).toList();
  }

  @override
  Future<int> insert(WorkoutDefinition workoutDefinition) {
    developer.log('insert', name: 'WorkoutDefinitionsRepository');
    return _store.add(database, workoutDefinition.toJson());
  }

  @override
  Future update(WorkoutDefinition workoutDefinition) {
    developer.log('update', name: 'WorkoutDefinitionsRepository');
    return _store
      .record(workoutDefinition.id)
      .update(database, workoutDefinition.toJson());
  }
  
  @override
  Future<WorkoutDefinition> getEntity(int entityId) {
    // TODO: implement getEntity
    throw UnimplementedError();
  }
}

@riverpod
Stream<List<WorkoutDefinition>> getAllEntitiesStream(
    GetAllEntitiesStreamRef ref) {
      developer.log('getAllEntitiesStream', name: 'WorkoutDefinitionsRepository@riverpod');
  return ref.watch(workoutDefinitionsRepositoryProvider).getAllEntitiesStream();
}

// @riverpod
// Stream<List<WorkoutDefinition>> getAllEntitiesWithDateStream(
//     GetAllEntitiesStreamRef ref) async* {
//   developer.log('getAllEntitiesStream',
//       name: 'WorkoutDefinitionsRepository@riverpod');
//   final definitions = ref.watch(workoutDefinitionsRepositoryProvider).getAllEntitiesStream();

//   await for (final definitionList in definitions) {
//     for (final definition in definitionList) {
//       yield ref.watch(getLastWorkoutDateProvider(workoutDefinitionId: definition.id));
//     }
//   }
// }

@riverpod
Future<int> insert(InsertRef ref,
    {required WorkoutDefinition workoutDefinition}) {
  return ref
      .watch(workoutDefinitionsRepositoryProvider)
      .insert(workoutDefinition);
}

@riverpod
Future delete(DeleteRef ref,
    {required int workoutDefinitionId}) {
  return ref
      .watch(workoutDefinitionsRepositoryProvider)
      .delete(workoutDefinitionId);
}

@riverpod
Future update(UpdateRef ref,
    {required WorkoutDefinition workoutDefinition}) {
  return ref
      .watch(workoutDefinitionsRepositoryProvider)
      .update(workoutDefinition);
}
