import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workout_tracker/data/repositories/user_preferences_repository.dart';
import 'package:workout_tracker/domain/user_preferences.dart';

mixin UserPreferencesEvent {
  void updatePreferences(WidgetRef ref, {required UserPreferences userPreferences}) {
    ref.watch(userPreferencesRepositoryProvider).update(userPreferences);
  }
}
