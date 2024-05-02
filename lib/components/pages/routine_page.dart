import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:workout_tracker/components/common/custom_scaffold.dart';
import 'package:workout_tracker/components/workouts/routines/routine_manager.dart';

class RoutinePage extends ConsumerWidget {
  const RoutinePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CustomScaffold(
      appBar: AppBar(
        title: const Text("Routines"),
      ),
      body: const RoutineManager(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // TODO create new, empty routine
          // context.go('/routines/routine/-1/edit');
        },
        label: const Text('New Routine'),
        icon: const Icon(Icons.add),
      ),
    );
  }
}
