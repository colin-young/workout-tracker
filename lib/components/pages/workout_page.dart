import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workout_tracker/components/workouts/workout_manager.dart';
import 'package:workout_tracker/data/repositories/workout_record_repository.dart';

class WorkoutPage extends ConsumerWidget {
  const WorkoutPage({required this.title, required this.workoutId, super.key});

  final String title;
  final String workoutId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final int workoutRecordId = int.parse(workoutId);

    return Scaffold(
      appBar: AppBar(title: Consumer(builder: (_, WidgetRef ref, __) {
        final workoutResult = ref.watch(
            getWorkoutRecordProvider(workoutRecordId: workoutRecordId)
                .select((it) => it.value?.currentExercise?.name));

        return Text(workoutResult ?? '');
      })),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: WorkoutManager(
          workoutRecordId: workoutRecordId,
        ),
      ),
    );
  }
}
