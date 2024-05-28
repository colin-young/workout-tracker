import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:workout_tracker/components/common/ui/wheel_picker/multi_digit_wheel.dart';
import 'package:workout_tracker/data/repositories/exercise_sets_repository.dart';
import 'package:workout_tracker/data/user_preferences_state.dart';
import 'package:workout_tracker/domain/exercise_sets.dart';
import 'package:workout_tracker/domain/set_entry.dart';
import 'package:workout_tracker/utility/constants.dart';
import 'package:workout_tracker/utility/exercise_sets_extensions.dart';
import 'package:workout_tracker/utility/int_digits.dart';

class ExerciseSetsDisplay extends ConsumerWidget {
  const ExerciseSetsDisplay(
      {required this.workoutRecordId, required this.exerciseId, super.key});

  final int workoutRecordId;
  final int exerciseId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var textStyle = Theme.of(context).textTheme;
    final workoutSetsResult = ref.watch(getWorkoutExerciseSetsStreamProvider(
        workoutId: workoutRecordId, exerciseId: exerciseId));

    return switch (workoutSetsResult) {
      AsyncValue(:final value?) => GestureDetector(
          onLongPress: () {
            showDialog(
              context: context,
              builder: (context) {
                return SetEditorDialog(
                  setEntries: value,
                  saveEntries: (sets) {
                    ref.read(updateExerciseSetsProvider(exerciseSets: sets));
                  },
                );
              },
            );
          },
          child: Center(
            child: Text(
              textAlign: TextAlign.center,
              value.displayString(),
              style: textStyle.bodyMedium,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      _ => const SizedBox()
    };
  }
}

class SetEditorDialog extends StatefulWidget {
  const SetEditorDialog({
    super.key,
    required this.setEntries,
    required this.saveEntries,
  });

  final ExerciseSets setEntries;
  final void Function(ExerciseSets) saveEntries;

  @override
  State<SetEditorDialog> createState() => _SetEditorDialogState();
}

class _SetEditorDialogState extends State<SetEditorDialog> {
  late int currentSetIndex;
  late ExerciseSets _exerciseSets;

  @override
  void initState() {
    currentSetIndex = 0;
    _exerciseSets = widget.setEntries;
    super.initState();
  }

  updateCurrentSetIndex(int newIndex) {
    setState(() {
      currentSetIndex = newIndex;
    });
  }

  updateWorkoutSet(SetEntry newSet, int index) {
    setState(() {
      _exerciseSets = _exerciseSets.copyWith(
          sets: _exerciseSets.sets
              .asMap()
              .map((i, s) => i ==index ? MapEntry(i, newSet) : MapEntry(i, s))
              .values
              .toList());
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit sets'),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * Constants.dialogWidth,
        height: MediaQuery.of(context).size.width * Constants.dialogHeight,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          mainAxisSize: MainAxisSize.max,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton.icon(
                    onPressed: currentSetIndex > 0
                        ? () => updateCurrentSetIndex(currentSetIndex - 1)
                        : null,
                    label: const Icon(Icons.arrow_back_ios)),
                Text(
                  'Set ${currentSetIndex + 1} of ${_exerciseSets.sets.length}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                TextButton.icon(
                    onPressed: currentSetIndex < (_exerciseSets.sets.length - 1)
                        ? () => updateCurrentSetIndex(currentSetIndex + 1)
                        : null,
                    label: const Icon(Icons.arrow_forward_ios)),
              ],
            ),
            SetEditorWidget(
              setEntry: _exerciseSets.sets[currentSetIndex],
              key: ValueKey(currentSetIndex),
              updateWorkoutSet: (newSet) =>
                  updateWorkoutSet(newSet, currentSetIndex),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
            onPressed: () {
              context.pop();
            },
            child: const Text('Cancel')),
        TextButton(
            onPressed: () {
              widget.saveEntries(_exerciseSets);
              context.pop();
            },
            child: const Text('Save'))
      ],
    );
  }
}

class SetEditorWidget extends ConsumerStatefulWidget {
  final SetEntry setEntry;
  final void Function(SetEntry) updateWorkoutSet;

  const SetEditorWidget({
    super.key,
    required this.setEntry,
    required this.updateWorkoutSet,
  });

  @override
  ConsumerState<SetEditorWidget> createState() => _SetEditorWidgetState();
}

class _SetEditorWidgetState extends ConsumerState<SetEditorWidget>
    with UserPreferencesState {
  late SetEntry _setEntry;

  @override
  void initState() {
    _setEntry = widget.setEntry;
    super.initState();
  }

  void updateWorkoutSet(SetEntry entry) {
    var prefs = userPreferences(ref);
    setState(() {
      _setEntry =
          entry.copyWith(units: prefs.weightUnits, finishedAt: DateTime.now());
    });

    widget.updateWorkoutSet(_setEntry);
  }

  void updateWeight(int newWeight) {
    updateWorkoutSet(
        _setEntry.copyWith(weight: newWeight, finishedAt: DateTime.now()));
  }

  void updateReps(int newReps) {
    updateWorkoutSet(
        _setEntry.copyWith(reps: newReps, finishedAt: DateTime.now()));
  }

  void updateWeightOnes(int newOnes) {
    updateWeight(_setEntry.weight.hundreds() * 100 +
        _setEntry.weight.tens() * 10 +
        newOnes);
  }

  void updateWeightTens(int newTens) {
    updateWeight(_setEntry.weight.hundreds() * 100 +
        newTens * 10 +
        _setEntry.weight.ones());
  }

  void updateWeightHundreds(int newHundreds) {
    updateWeight(newHundreds * 100 +
        _setEntry.weight.tens() * 10 +
        _setEntry.weight.ones());
  }

  void updateRepsOnes(int newOnes) {
    updateReps(_setEntry.reps.tens() * 10 + newOnes);
  }

  void updateRepsTens(int newTens) {
    updateReps(newTens * 10 + _setEntry.reps.ones());
  }

  @override
  Widget build(BuildContext context) {
    final prefs = userPreferences(ref);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          height: Constants.digitWheelHeight,
          child: MultiDigitWheel(
            key: ValueKey('${_setEntry.reps}reps'),
            suffix: 'reps',
            value: _setEntry.reps,
            updateTens: updateRepsTens,
            updateOnes: updateRepsOnes,
          ),
        ),
        SizedBox(
          height: Constants.digitWheelHeight,
          child: MultiDigitWheel(
            key: ValueKey('${_setEntry.weight}weight'),
            suffix: prefs.weightUnits,
            value: _setEntry.weight,
            updateHundreds: updateWeightHundreds,
            updateTens: updateWeightTens,
            updateOnes: updateWeightOnes,
          ),
        ),
      ],
    );
  }
}
