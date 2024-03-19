import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wheel_picker/wheel_picker.dart';
import 'package:workout_tracker/components/common/digit_wheel.dart';
import 'package:workout_tracker/components/workouts/exercise_sets_display.dart';
import 'package:workout_tracker/components/workouts/record_set_button.dart';
import 'package:workout_tracker/controller/user_preferences_state.dart';
import 'package:workout_tracker/data/repositories/exercise_sets_repository.dart';
import 'package:workout_tracker/data/repositories/workout_record_repository.dart';
import 'package:workout_tracker/domain/set_entry.dart';
import 'package:workout_tracker/utility/int_digits.dart';

class SetRecorder extends ConsumerStatefulWidget {
  const SetRecorder({
    super.key,
    required this.weightUnits,
    required this.workoutRecordId,
  });

  final String weightUnits;
  final int workoutRecordId;

  @override
  ConsumerState<SetRecorder> createState() => _SetRecorderState();
}

class _SetRecorderState extends ConsumerState<SetRecorder>
    with UserPreferencesState {
  SetEntry setEntry =
      SetEntry(reps: 0, weight: 0, units: '', finishedAt: DateTime.now());
  String lastRepsDisplay = '';
  var isInitialized = false;
  late final workoutRecordId = widget.workoutRecordId;

  late final repsTensWheel = WheelPickerController(itemCount: 10);
  late final repsOnesWheel =
      WheelPickerController(itemCount: 10, mounts: [repsTensWheel]);

  late final weightHundredsWheel = WheelPickerController(itemCount: 10);
  late final weightTensWheel =
      WheelPickerController(itemCount: 10, mounts: [weightHundredsWheel]);
  late final weightOnesWheel =
      WheelPickerController(itemCount: 10, mounts: [weightTensWheel]);

  void initStateAsync() async {
    await ref
        .watch(getLastExerciseSetsByWorkoutCurrentExerciseProvider(
                workoutRecordId: widget.workoutRecordId)
            .future)
        .then((value) {
      var sets = [...value.sets];
      sets.sort((a, b) => a.finishedAt.compareTo(b.finishedAt));

      if (sets.isNotEmpty) {
        SetEntry entry = SetEntry(
            reps: sets.last.reps,
            weight: sets.last.weight,
            units: widget.weightUnits,
            finishedAt: DateTime.now());

        setState(() {
          setEntry = entry;
          isInitialized = true;
        });

        repsTensWheel.shiftBy(steps: setEntry.reps.tens());
        repsOnesWheel.shiftBy(steps: setEntry.reps.ones());
        weightHundredsWheel.shiftBy(steps: setEntry.weight.hundreds());
        weightTensWheel.shiftBy(steps: setEntry.weight.tens());
        weightOnesWheel.shiftBy(steps: setEntry.weight.ones());
      }
    });
  }

  @override
  void initState() {
    repsTensWheel.shiftBy(steps: setEntry.reps.tens());
    repsOnesWheel.shiftBy(steps: setEntry.reps.ones());
    weightHundredsWheel.shiftBy(steps: setEntry.weight.hundreds());
    weightTensWheel.shiftBy(steps: setEntry.weight.tens());
    weightOnesWheel.shiftBy(steps: setEntry.weight.ones());

    super.initState();
  }

  @override
  void dispose() {
    repsOnesWheel.dispose();
    repsTensWheel.dispose();
    weightHundredsWheel.dispose();
    weightTensWheel.dispose();
    weightOnesWheel.dispose();
    super.dispose();
  }

  void updateLastRepsDisplay(String newDisplay) {
    setState(() {
      lastRepsDisplay = newDisplay;
    });
  }

  void updateWorkoutSet(SetEntry entry) {
    var prefs = userPreferences(ref);
    setState(() {
      setEntry = entry.copyWith(units: prefs.weightUnits);
    });
  }

  void updateRepsTens(int newRepsTens) {
    final currentReps = setEntry.reps;
    updateWorkoutSet(
        setEntry.copyWith(reps: currentReps.ones() + newRepsTens * 10));
  }

  void updateRepsOnes(int newRepsOnes) {
    final currentReps = setEntry.reps;
    updateWorkoutSet(
        setEntry.copyWith(reps: currentReps.tens() * 10 + newRepsOnes));
  }

  void updateWeightHundreds(int newWeightHundreds) {
    final currentReps = setEntry.weight;
    updateWorkoutSet(setEntry.copyWith(
        weight: newWeightHundreds * 100 +
            currentReps.tens() * 10 +
            currentReps.ones()));
  }

  void updateWeightTens(int newWeightTens) {
    final currentReps = setEntry.weight;
    updateWorkoutSet(setEntry.copyWith(
        weight: currentReps.hundreds() * 100 +
            newWeightTens * 10 +
            currentReps.ones()));
  }

  void updateWeightOnes(int newWeightOnes) {
    final currentReps = setEntry.weight;
    updateWorkoutSet(setEntry.copyWith(
        weight: currentReps.hundreds() * 100 +
            currentReps.tens() * 10 +
            newWeightOnes));
  }

  @override
  Widget build(BuildContext context) {
    if (!isInitialized) initStateAsync();

    var prefs = userPreferences(ref);
    var textStyle = Theme.of(context).textTheme;
    var textTitle = textStyle.titleLarge;
    final currentExerciseResult = ref.watch(workoutCurrentExerciseProvider(
        workoutRecordId: widget.workoutRecordId));

    return Card(
        child: Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Flexible(
                      flex: 1,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          DigitWheel(
                            textStyle: textTitle,
                            wheelController: repsTensWheel,
                            updateReps: updateRepsTens,
                          ),
                          const SizedBox(
                            width: 16,
                          ),
                          DigitWheel(
                            textStyle: textTitle,
                            wheelController: repsOnesWheel,
                            updateReps: updateRepsOnes,
                          ),
                        ],
                      ),
                    ),
                    Flexible(
                      flex: 1,
                      child: Text('reps', style: textTitle),
                    ),
                  ],
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 1,
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            DigitWheel(
                              textStyle: textTitle,
                              wheelController: weightHundredsWheel,
                              updateReps: updateWeightHundreds,
                            ),
                            const SizedBox(
                              width: 16,
                            ),
                            DigitWheel(
                              textStyle: textTitle,
                              wheelController: weightTensWheel,
                              updateReps: updateWeightTens,
                            ),
                            const SizedBox(
                              width: 16,
                            ),
                            DigitWheel(
                              textStyle: textTitle,
                              wheelController: weightOnesWheel,
                              updateReps: updateWeightOnes,
                            ),
                          ]),
                    ),
                    Expanded(
                      flex: 1,
                      child: Text(
                        prefs.weightUnits,
                        style: textTitle,
                      ),
                    )
                  ],
                ),
                RecordSetButton(
                  workoutSet: setEntry,
                  textStyle: textTitle,
                  workoutRecordId: widget.workoutRecordId,
                ),
                switch (currentExerciseResult) {
                  AsyncData(:final value) => value!.exercise.id < 0
                      ? Center(
                          child: Text(
                          'Error: ${value.exercise.id}',
                          style: textStyle.bodyMedium,
                        ))
                      : ExerciseSetsDisplay(
                          workoutRecordId: widget.workoutRecordId,
                          exerciseId: value!.exercise.id),
                  AsyncError(:final error) => Text(error.toString()),
                  _ => const Center(
                      child: CircularProgressIndicator(),
                    ),
                },
              ],
            )));
  }
}
