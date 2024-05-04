import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workout_tracker/components/common/ui/wheel_picker/multi_digit_wheel.dart';
import 'package:workout_tracker/components/common/ui/chart.dart';
import 'package:workout_tracker/components/workouts/exercise_sets/exercise_settings_display.dart';
import 'package:workout_tracker/components/workouts/exercise_sets/exercise_sets_display.dart';
import 'package:workout_tracker/components/workouts/exercise_sets/record_set_button.dart';
import 'package:workout_tracker/controller/user_preferences_state.dart';
import 'package:workout_tracker/data/repositories/exercise_sets_repository.dart';
import 'package:workout_tracker/domain/set_entry.dart';
import 'package:workout_tracker/utility/int_digits.dart';
import 'package:workout_tracker/utility/set_entry_list_utils.dart';
import 'package:workout_tracker/utility/set_entry_utils.dart';
import 'package:workout_tracker/utility/text_ui_utilities.dart';

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
    with UserPreferencesState, TickerProviderStateMixin {
  SetEntry setEntry =
      SetEntry(reps: 0, weight: 0, units: '', finishedAt: DateTime.now());
  late final workoutRecordId = widget.workoutRecordId;
  bool isInitialized = false;
  int lastWorkoutSetsId = -1;
  int _exerciseId = -1;

  Duration animationDuration = const Duration(milliseconds: 800);

  final slideOutCurve =
      const Interval(0.75, 1.0, curve: Easing.emphasizedDecelerate);
  final slideInCurve =
      const Interval(0.375, 1.0, curve: Easing.emphasizedDecelerate);

  late final slideInTween =
      Tween(begin: const Offset(1.1, 0), end: const Offset(0, 0));
  late final slideOutTween =
      Tween(begin: const Offset(-1, 0), end: const Offset(0, 0));

  void updateExercise(int exerciseId) async {
    setState(() {
      _exerciseId = exerciseId;
    });
  }

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
    final currentExerciseResult = ref.watch(
        workoutCurrentExerciseStreamProvider(
            workoutRecordId: widget.workoutRecordId));

    switch (currentExerciseResult) {
      case AsyncValue(:final value?):
        updateExercise(value.exercise.id);
        if (!isInitialized || value.id != lastWorkoutSetsId) {
          if (value.sets.isNotEmpty) {
            updateWorkoutSet(setEntry.copyWith(
                reps: value.sets.last.reps, weight: value.sets.last.weight));
          } else {
            final setsResults = ref.watch(
                getAllExerciseSetsByExerciseStreamProvider(
                    exerciseId: value.exercise.id));

            switch (setsResults) {
              case AsyncValue(:final value?):
                final lastSet = value
                    .sorted((a, b) => a.sets.isNotEmpty
                        ? b.sets.isNotEmpty
                            ? -a.sets.first.finishedAt
                                .compareTo(b.sets.first.finishedAt)
                            : -1
                        : 1)
                    .first
                    .sets
                    .first;
                updateWorkoutSet(setEntry.copyWith(
                    reps: lastSet.reps, weight: lastSet.weight));
            }
          }

          lastWorkoutSetsId = value.id;
          isInitialized = true;
        }
    }

    final exerciseResultsHeight =
        TextUiUtilities.getTextSize('0', textStyle.bodyMedium!).height;
    const recorderButton = 68.0;
    const digitWheelHeight = 140.0;
    const cardPadding = 8.0;

    return SizedBox(
      height: digitWheelHeight * 2 +
          recorderButton +
          exerciseResultsHeight +
          cardPadding * 2,
      child: Card(
          margin: const EdgeInsets.all(0),
          clipBehavior: Clip.hardEdge,
          child:
              // Chart
              Padding(
                  padding: const EdgeInsets.all(cardPadding),
                  child: Stack(children: [
                    switch (currentExerciseResult) {
                      AsyncValue(:final value?) => Padding(
                          padding: EdgeInsets.fromLTRB(
                              0, 0, 0, recorderButton + exerciseResultsHeight),
                          child: Opacity(
                            opacity: 0.25,
                            child: AnimatedSwitcher(
                              transitionBuilder: (child, animation) =>
                                  SlideTransition(
                                position: (animation.value == 1
                                        ? slideOutTween
                                        : slideInTween)
                                    .animate(animation),
                                child: child,
                              ),
                              switchInCurve: slideInCurve,
                              switchOutCurve: slideOutCurve,
                              duration: animationDuration,
                              child: IgnorePointer(
                                key: ValueKey(
                                    'workoutChart${value.exercise.id}'),
                                child: ExerciseSummaryChart(
                                  key: ValueKey(
                                      'workoutChart${value.exercise.id}.chart'),
                                  exerciseId: value.exercise.id,
                                  showAxis: true,
                                  // TODO get from exercise props
                                  showRange: true,
                                  // TODO get from exercise props
                                  showTrend: true,
                                  showGridLines: false,
                                  setValueAccumulator:
                                      SetEntryListUtils.average,
                                  valueFunc: SetEntryUtils.oneRMEpley,
                                  minFunc: SetEntryListUtils.min,
                                  maxFunc: SetEntryListUtils.max,
                                  measure: SetEntryUtils.oneRMEpley(setEntry),
                                ),
                              ),
                            ),
                          ),
                        ),
                      _ => const SizedBox()
                    },
                    // Settings
                    switch (currentExerciseResult) {
                      AsyncValue(:final value?) => Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: SizedBox(
                            height: digitWheelHeight * 2,
                            child: Flex(
                              direction: Axis.horizontal,
                              mainAxisAlignment: MainAxisAlignment.end,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 24.0),
                                  child: SizedBox(
                                      width: 150,
                                      child: AnimatedSwitcher(
                                        duration: const Duration(milliseconds: 500),
                                        switchInCurve: slideInCurve,
                                        switchOutCurve: slideOutCurve,
                                        child: Align(
                                          alignment: Alignment.bottomRight,
                                          child: ExerciseSettingsDisplay(
                                              key: ValueKey(
                                                  'settings${value.exercise.id}'),
                                              entry: value.exercise),
                                        ),
                                      )),
                                )
                              ],
                            ),
                          ),
                      ),
                      _ => const SizedBox(),
                    },
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: digitWheelHeight,
                          child: MultiDigitWheel(
                            key: ValueKey('${_exerciseId}reps'),
                            suffix: 'reps',
                            value: setEntry.reps,
                            updateTens: updateRepsTens,
                            updateOnes: updateRepsOnes,
                          ),
                        ),
                        SizedBox(
                          height: digitWheelHeight,
                          child: MultiDigitWheel(
                            key: ValueKey('${_exerciseId}weight'),
                            suffix: prefs.weightUnits,
                            value: setEntry.weight,
                            updateHundreds: updateWeightHundreds,
                            updateTens: updateWeightTens,
                            updateOnes: updateWeightOnes,
                          ),
                        ),
                        RecordSetButton(
                          workoutSet: setEntry,
                          textStyle: textTitle,
                          workoutRecordId: widget.workoutRecordId,
                        ),
                        SizedBox(
                          height: exerciseResultsHeight,
                          child: switch (currentExerciseResult) {
                            AsyncValue(:final value?) => value.exercise.id < 0
                                ? SizedBox(
                                    height: exerciseResultsHeight,
                                    child: Center(
                                        child: Text(
                                      'Error: ${value.exercise.id}',
                                      style: textStyle.bodyMedium,
                                    )),
                                  )
                                : ExerciseSetsDisplay(
                                    workoutRecordId: widget.workoutRecordId,
                                    exerciseId: value.exercise.id),
                            AsyncValue(:final error) => Text(error.toString()),
                          },
                        ),
                      ],
                    ),
                  ]))),
    );
  }
}
