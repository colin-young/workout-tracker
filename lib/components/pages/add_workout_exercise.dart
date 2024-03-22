import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:workout_tracker/components/exercises/exercise_list_with_tile.dart';
import 'package:workout_tracker/controller/exercise_controller.dart';
import 'package:workout_tracker/data/repositories/exercise_sets_repository.dart';
import 'package:workout_tracker/domain/exercise.dart';
import 'package:workout_tracker/domain/exercise_sets.dart';

class AddWorkoutExercise extends ConsumerStatefulWidget {
  const AddWorkoutExercise(
      {required this.title, required this.workoutId, super.key});

  final String title;
  final String workoutId;

  @override
  ConsumerState<AddWorkoutExercise> createState() => _AddWorkoutExercise();
}

class _AddWorkoutExercise extends ConsumerState<AddWorkoutExercise> {
  late List<Exercise> _selected = [];

  void selectItem(List<Exercise> exercises, int index) {
    setState(() {
      if (_selected.any((element) => element.id == exercises[index].id)) {
        _selected = _selected
            .where((element) => element.id != exercises[index].id)
            .toList();
      } else {
        _selected = [..._selected, exercises[index]];
      }
    });
  }

  bool isItemSelected(List<Exercise> exercises, int index) =>
      _selected.any((element) => element.id == exercises[index].id);

  @override
  Widget build(BuildContext context) {
    final int workoutRecordId = int.parse(widget.workoutId);
    final workoutResult = ref.watch(
        workoutCurrentExerciseProvider(workoutRecordId: workoutRecordId));
    final exercises =
        ref.watch(getExerciseAddListProvider(workoutRecordId: workoutRecordId));

    return Scaffold(
        appBar: AppBar(
          title: switch (workoutResult) {
            AsyncData() => const Text('Add Exercise'),
            AsyncError(:final error) => Text(error.toString()),
            _ => Container()
          },
          actions: [
            switch (exercises) {
              AsyncData(:final value) => _selected.length < value.length
                  ? IconButton(
                      icon: const Icon(Icons.playlist_add_check),
                      onPressed: () {
                        setState(() {
                          _selected = [...value];
                        });
                      })
                  : IconButton(
                      icon: const Icon(Icons.playlist_remove),
                      onPressed: () {
                        setState(() {
                          _selected = [];
                        });
                      }),
              _ => Container()
            },
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Consumer(
            builder: (context, ref, child) {
              return switch (exercises) {
                AsyncData(:final value) => ExerciseListWithTile(
                    onTap: selectItem,
                    isItemSelected: isItemSelected,
                    workoutRecordId: workoutRecordId,
                    exercises: value,
                  ),
                _ => Container()
              };
            },
          ),
        ),
        floatingActionButton: _selected.isNotEmpty
            ? AddSelectedExercises(
                workoutRecordId: workoutRecordId,
                selected: _selected,
              )
            : Container());
  }
}

class AddSelectedExercises extends ConsumerWidget {
  const AddSelectedExercises({
    super.key,
    required this.workoutRecordId,
    required this.selected,
  });

  final int workoutRecordId;
  final List<Exercise> selected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FloatingActionButton(
      onPressed: () {
        ref
            .read(
                getWorkoutSetsStreamProvider(workoutId: workoutRecordId).future)
            .then((value) {
          var lastSortOrder = value.last.order;
          for (final exercise in selected) {
            lastSortOrder++;
            ref.read(exerciseSetsRepositoryProvider).insert(ExerciseSets(
                workoutId: workoutRecordId,
                order: lastSortOrder,
                exercise: exercise,
                sets: [],
                isComplete: false));
          }
        });

        context.pop();
      },
      child: const Icon(Icons.playlist_add_check),
    );
  }
}
