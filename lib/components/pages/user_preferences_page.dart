import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workout_tracker/components/common/custom_scaffold.dart';
import 'package:workout_tracker/components/pages/user_preferences/user_preferences_editor.dart';
import 'package:workout_tracker/data/repositories/user_preferences_repository.dart';

class UserPreferencesPage extends ConsumerWidget {
  const UserPreferencesPage({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userPreferencesResult = ref.watch(getUserPreferencesProvider);

    return switch (userPreferencesResult) {
      AsyncValue(:final value?) => CustomScaffold(
          title: const Text('User preferences'),
          body: UserPreferencesEditor(preferences: value),
        ),
      _ => const CircularProgressIndicator(),
    };
  }
}
