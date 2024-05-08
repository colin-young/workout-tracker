import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sembast/sembast.dart';
import 'package:workout_tracker/data/providers/global_providers.dart';
import 'package:workout_tracker/domain/user_preferences.dart';

part 'user_preferences_repository.g.dart';

@riverpod
UserPreferencesRepository userPreferencesRepository(
        UserPreferencesRepositoryRef ref) =>
    UserPreferencesRepository(database: ref.watch(databaseProvider));

class UserPreferencesRepository {
  final Database database;
  late final StoreRef<String, Map<String, dynamic>> _store;

  UserPreferencesRepository({required this.database}) {
    _store = StoreRef.main();
  }
  
  Future<UserPreferences> getUserPreferences() async {
    var exerciseRecord = await _store.record(UserPreferences.storeName).get(database);
    var exercise = UserPreferences.fromJson(exerciseRecord!);
    return exercise;
  }
  
  Future update(UserPreferences entity) {
    return _store.record(UserPreferences.storeName).update(database, entity.toJson());
  }
}

@riverpod
Future<UserPreferences> getUserPreferences(GetUserPreferencesRef ref) async {
      return ref.watch(userPreferencesRepositoryProvider).getUserPreferences();
}

@riverpod
Future updateUserPreferences(UpdateUserPreferencesRef ref, {required UserPreferences userPreferences}) async {
  ref.read(userPreferencesRepositoryProvider).update(userPreferences);
  
  ref.invalidate(userPreferencesRepositoryProvider);
  ref.invalidate(getUserPreferencesProvider);
}