import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workout_tracker/components/exercises/exercise_edit_form.dart';
import 'package:workout_tracker/components/exercises/exercise_list_with_tile.dart';
import 'package:workout_tracker/data/repositories/exercise_repository.dart';
import 'package:workout_tracker/domain/exercise.dart';
import 'package:workout_tracker/domain/workout_exercise.dart';

class AddExerciseDialog extends ConsumerStatefulWidget {
  const AddExerciseDialog({
    super.key,
    required this.exercises,
    required this.updateExercises,
  });

  final void Function(List<WorkoutExercise>) updateExercises;
  final List<WorkoutExercise> exercises;

  @override
  ConsumerState<AddExerciseDialog> createState() => _AddExerciseDialogState();
}

class _AddExerciseDialogState extends ConsumerState<AddExerciseDialog> {
  late final List<WorkoutExercise> _currentExercises;
  late List<Exercise> _selected;
  bool isAdding = false;

  @override
  void initState() {
    _currentExercises = widget.exercises;
    _selected = _currentExercises.map((e) => e.exercise).toList();
    super.initState();
  }

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
    final exercisesResult = ref.watch(getExercisesProvider);
    
    return AlertDialog(
      title: const Text('Select Exercises'),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.width * 0.85,
        child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: isAdding
                ? ExerciseEditForm(
                    exercise: const Exercise(name: '', settings: []),
                    cancelLabel: 'Discard',
                    onCancel: () {
                      setState(() {
                        isAdding = false;
                      });
                    },
                    saveLabel: 'Add Exercise',
                    afterSave: () {
                      setState(() {
                        isAdding = false;
                      });
                    },
                  )
                : switch (exercisesResult) {
                    AsyncValue(:final value?) => ExerciseListWithTile(
                        onTap: selectItem,
                        isItemSelected: isItemSelected,
                        exercises: value,
                      ),
                    _ => const CircularProgressIndicator()
                  }),
      ),
      actions: [
        if (!isAdding)
          TextButton(
              onPressed: () {
                setState(() {
                  isAdding = !isAdding;
                });
              },
              child: const Text('Add Exercise')),
        TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Cancel')),
        TextButton(
            onPressed: () {
              int lastIndex = _currentExercises.length;

              final newExercises = _selected
                  .map((e) =>
                      _currentExercises
                          .where((element) => element.exercise.id == e.id)
                          .firstOrNull ??
                      WorkoutExercise(order: lastIndex++, exercise: e))
                  .toList();

              widget.updateExercises(newExercises);
              Navigator.of(context).pop();
            },
            child: const Text('Save')),
      ],
    );
  }
}
