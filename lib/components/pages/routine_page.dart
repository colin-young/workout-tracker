import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workout_tracker/components/common/custom_scaffold.dart';
import 'package:workout_tracker/components/pages/routine/routine_manager.dart';

class RoutinePage extends ConsumerWidget {
  const RoutinePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CustomScaffold(
      title: const Text('Routines'),
      body: const RoutineManager(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // TODO create new, empty routine
          // context.go('/routines/routine/-1/edit');
        },
        label: const Text('New routine'),
        icon: const Icon(Icons.add),
      ),
    );
  }
}
