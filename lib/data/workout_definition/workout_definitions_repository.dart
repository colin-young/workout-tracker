import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sembast/sembast.dart';
import 'package:workout_tracker/data/providers/global_providers.dart';
import 'package:workout_tracker/data/repositories/sembast_repository.dart';
import 'package:workout_tracker/domain/workout_definition.dart';

part 'workout_definitions_repository.g.dart';

@riverpod
WorkoutDefinitionsRepository workoutDefinitionsRepository(
        WorkoutDefinitionsRepositoryRef ref) =>
    WorkoutDefinitionsRepository(database: ref.watch(databaseProvider));

class WorkoutDefinitionsRepository implements Repository<WorkoutDefinition> {
  final Database database;
  late final StoreRef<int, Map<String, dynamic>> _store;

  WorkoutDefinitionsRepository({required this.database}) {
    _store = intMapStoreFactory.store('workout_definition_store'); // NON-NLS
  }

  @override
  Future delete(int workoutDefinitionId) =>
      _store.record(workoutDefinitionId).delete(database);

  @override
  Stream<List<WorkoutDefinition>> getAllEntitiesStream() {
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
    return records
        .map((e) => WorkoutDefinition.fromJson(e.value).copyWith(id: e.key))
        .toList();
  }

  @override
  Future<int> insert(WorkoutDefinition workoutDefinition) {
    return _store.add(database, workoutDefinition.toJson());
  }

  @override
  Future update(WorkoutDefinition workoutDefinition) {
    return _store
        .record(workoutDefinition.id)
        .update(database, workoutDefinition.toJson());
  }

  @override
  Future<WorkoutDefinition> getEntity(int entityId) async {
    var definitionRecord = await _store.record(entityId).get(database);
    var definition =
        WorkoutDefinition.fromJson(definitionRecord!).copyWith(id: entityId);
    return definition;
  }
}

@riverpod
Future<WorkoutDefinition> getWorkoutDefinition(GetWorkoutDefinitionRef ref,
    {required int entityId}) async {
  return entityId > 0
      ? ref.watch(workoutDefinitionsRepositoryProvider).getEntity(entityId)
      : Future.value(const WorkoutDefinition(name: '', exercises: [])); // NON-NLS
}
