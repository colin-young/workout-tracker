import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workout_tracker/components/common/custom_scaffold.dart';
import 'package:workout_tracker/components/pages/user_preferences/user_preferences_editor.dart';
import 'package:workout_tracker/data/user_preferences_state.dart';

class UserPreferencesPage extends ConsumerWidget with UserPreferencesState {
  const UserPreferencesPage({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CustomScaffold(
      title: const Text('User preferences'),
      body: UserPreferencesEditor(preferences: userPreferences(ref)),
    );
  }
}
