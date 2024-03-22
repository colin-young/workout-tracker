import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workout_tracker/components/common/multi_digit_wheel.dart';
import 'package:workout_tracker/components/exercise_sets/exercise_settings_display.dart';
import 'package:workout_tracker/components/workouts/exercise_sets_display.dart';
import 'package:workout_tracker/components/workouts/record_set_button.dart';
import 'package:workout_tracker/controller/user_preferences_state.dart';
import 'package:workout_tracker/data/repositories/exercise_sets_repository.dart';
import 'package:workout_tracker/domain/set_entry.dart';
import 'package:workout_tracker/utility/int_digits.dart';

class SetRecorder extends ConsumerStatefulWidget {
  const SetRecorder({
    super.key,
    required this.workoutRecordId,
  });

  final int workoutRecordId;

  @override
  ConsumerState<SetRecorder> createState() => _SetRecorderState();
}

class _SetRecorderState extends ConsumerState<SetRecorder>
    with UserPreferencesState {
  SetEntry setEntry =
      SetEntry(reps: 0, weight: 0, units: '', finishedAt: DateTime.now());
  late final workoutRecordId = widget.workoutRecordId;
  bool isInitialized = false;

  void updateWorkoutSet(SetEntry entry) {
    var prefs = userPreferences(ref);
    setState(() {
      setEntry =
          entry.copyWith(units: prefs.weightUnits, finishedAt: DateTime.now());
    });
  }

  void updateWeight(int newWeight) {
    updateWorkoutSet(
        setEntry.copyWith(weight: newWeight, finishedAt: DateTime.now()));
  }

  void updateReps(int newReps) {
    updateWorkoutSet(
        setEntry.copyWith(reps: newReps, finishedAt: DateTime.now()));
  }

  void updateWeightHundreds(int newHundreds) {
    updateWeight(newHundreds * 100 +
        setEntry.weight.tens() * 10 +
        setEntry.weight.ones());
  }

  void updateWeightTens(int newTens) {
    updateWeight(setEntry.weight.hundreds() * 100 +
        newTens * 10 +
        setEntry.weight.ones());
  }

  void updateWeightOnes(int newOnes) {
    updateWeight(setEntry.weight.hundreds() * 100 +
        setEntry.weight.tens() * 10 +
        newOnes);
  }

  void updateRepsTens(int newTens) {
    updateReps(newTens * 10 + setEntry.reps.ones());
  }

  void updateRepsOnes(int newOnes) {
    updateReps(setEntry.reps.tens() * 10 + newOnes);
  }

  @override
  Widget build(BuildContext context) {
    var prefs = userPreferences(ref);
    var textStyle = Theme.of(context).textTheme;
    var textTitle = textStyle.titleLarge;
    final currentExerciseResult = ref.watch(workoutCurrentExerciseProvider(
        workoutRecordId: widget.workoutRecordId));

    switch (currentExerciseResult) {
      case AsyncData(:final value):
        if (!isInitialized) {
          if (value!.sets.isNotEmpty) {
            updateWorkoutSet(setEntry.copyWith(
              reps: value.sets.last.reps, weight: value.sets.last.weight));
          }
          isInitialized = true;
        }
    }

    return SizedBox(
      height: 390,
      child: Card(
          child: Padding(
              padding: const EdgeInsets.all(8),
              child: Stack(children: [
                switch (currentExerciseResult) {
                  AsyncData(:final value) => Flex(
                      direction: Axis.horizontal,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              SizedBox(
                                  width: 100,
                                  child: ExerciseSettingsDisplay(
                                      entry: value!.exercise)),
                            ],
                          ),
                        )
                      ],
                    ),
                  AsyncError(:final error) => Text(error.toString()),
                  _ => const Center(
                      child: CircularProgressIndicator(),
                    ),
                },
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 140,
                      child: switch (currentExerciseResult) {
                        AsyncData(:final value) => MultiDigitWheel(
                            suffix: 'reps',
                            value: value!.sets.isNotEmpty ? value.sets.last.reps : 0,
                            updateTens: updateRepsTens,
                            updateOnes: updateRepsOnes,
                          ),
                        _ => Container(),
                      },
                    ),
                    SizedBox(
                      height: 140,
                      child: switch (currentExerciseResult) {
                        AsyncData(:final value) => MultiDigitWheel(
                            suffix: prefs.weightUnits,
                            value: value!.sets.isNotEmpty ? value.sets.last.weight : 0,
                            updateHundreds: updateWeightHundreds,
                            updateTens: updateWeightTens,
                            updateOnes: updateWeightOnes,
                          ),
                        _ => Container(),
                      },
                    ),
                    RecordSetButton(
                      workoutSet: setEntry,
                      textStyle: textTitle,
                      workoutRecordId: widget.workoutRecordId,
                    ),
                    SizedBox(
                      height: 22,
                      child: switch (currentExerciseResult) {
                        AsyncData(:final value) => value!.exercise.id < 0
                            ? SizedBox(
                              height: 22,
                              child: Center(
                                  child: Text(
                                  'Error: ${value.exercise.id}',
                                  style: textStyle.bodyMedium,
                                )),
                            )
                            : ExerciseSetsDisplay(
                                workoutRecordId: widget.workoutRecordId,
                                exerciseId: value.exercise.id),
                        AsyncError(:final error) => Text(error.toString()),
                        _ => Container(),
                      },
                    ),
                  ],
                ),
              ]))),
    );
  }
}
