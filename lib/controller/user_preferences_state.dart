import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workout_tracker/data/repositories/user_preferences_repository.dart';
import 'package:workout_tracker/domain/user_preferences.dart';

mixin UserPreferencesState {
  UserPreferences userPreferences(WidgetRef ref) =>
      ref.watch(getUserPreferencesProvider).value ??
      const UserPreferences(
          weightUnits: "unknown",
          autoCloseWorkout: UserPreferencesAutoCloseWorkout(
              autoClose: true, autoCloseWorkoutAfter: Duration()),
          showcase: UserPreferencesShowcase(summaryPage: false));
}
