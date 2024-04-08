import 'dart:math';

import 'package:path/path.dart';
import 'package:workout_tracker/domain/exercise.dart';
import 'package:workout_tracker/domain/exercise_setting.dart';
import 'package:workout_tracker/domain/exercise_type.dart';
import 'package:workout_tracker/domain/set_entry.dart';
import 'package:workout_tracker/domain/workout_definition.dart';
import 'package:workout_tracker/domain/workout_exercise.dart';
import 'package:workout_tracker/domain/workout_record.dart';
import 'package:workout_tracker/domain/exercise_sets.dart';

const bicepsCurl = Exercise(
    id: 1,
    name: "Biceps Curl",
    exerciseType: ExerciseType.dumbbell,
    note: "Lorem ipsum dolor sit amet.",
    settings: []);
const seatedLegCurl = Exercise(
    id: 2,
    name: "Seated Leg Curl",
    exerciseType: ExerciseType.machine,
    note: "Sample note content.",
    settings: [
      ExerciseSetting(setting: "lower", value: "3"),
      ExerciseSetting(setting: "middle", value: "6"),
      ExerciseSetting(setting: "upper", value: "3"),
      ExerciseSetting(setting: "seat", value: "4")
    ]);
const chestPress = Exercise(
    id: 3,
    name: "Chest Press",
    exerciseType: ExerciseType.machine,
    settings: []);
const pecFly = Exercise(
    id: 4, name: "Pec Fly", exerciseType: ExerciseType.machine, settings: []);
const legExtension = Exercise(
    id: 5,
    name: "Leg Extension",
    exerciseType: ExerciseType.machine,
    settings: [
      ExerciseSetting(setting: "lower", value: "1"),
      ExerciseSetting(setting: "upper", value: "2")
    ]);
const benchDip = Exercise(
    id: 6,
    name: "Bench Dip",
    exerciseType: ExerciseType.bodyWeight,
    settings: []);
const shoulderPress = Exercise(
    id: 7,
    name: "Shoulder Press",
    exerciseType: ExerciseType.dumbbell,
    settings: []);
const forwardRaise = Exercise(
    id: 8,
    name: "Forward Raise",
    exerciseType: ExerciseType.dumbbell,
    settings: []);
const tricepPulldown = Exercise(
    id: 9,
    name: "Tricep Pulldown",
    exerciseType: ExerciseType.machine,
    settings: []);
const exerciseList = [
  bicepsCurl,
  seatedLegCurl,
  chestPress,
  pecFly,
  legExtension,
  benchDip,
  shoulderPress,
  forwardRaise,
  tricepPulldown,
];
const routine1 = WorkoutDefinition(id: 1, name: "Routine 1", exercises: [
  WorkoutExercise(id: 1, order: 1, exercise: bicepsCurl),
  WorkoutExercise(id: 2, order: 2, exercise: seatedLegCurl),
  WorkoutExercise(id: 5, order: 3, exercise: legExtension),
  WorkoutExercise(id: 5, order: 4, exercise: chestPress),
  WorkoutExercise(id: 5, order: 5, exercise: pecFly),
]);
const routine2 = WorkoutDefinition(name: "Routine 2", exercises: [
  WorkoutExercise(id: 3, order: 1, exercise: chestPress),
  WorkoutExercise(id: 4, order: 2, exercise: pecFly),
]);
const routine3 = WorkoutDefinition(name: "Routine 3", exercises: [
  WorkoutExercise(order: 1, exercise: chestPress),
  WorkoutExercise(order: 2, exercise: pecFly),
  WorkoutExercise(order: 3, exercise: bicepsCurl),
]);
const workoutDefinitions = [routine1, routine2, routine3];
final workoutStartTime = DateTime.now().subtract(const Duration(days: 60));

List<SetEntry> generateSets(DateTime startTime) {
  final setCount = Random().nextInt(2) + 2;
  final durations = List.generate(
      setCount,
      (index) => Duration(
          seconds: Random().nextInt(59), minutes: Random().nextInt(3) + 1));
  return List.generate(
      setCount,
      (index) => generateSetEntry(
          startTime,
          durations.take(index).fold(
              Duration.zero,
              (previousValue, element) => Duration(
                  seconds: previousValue.inSeconds + element.inSeconds))));
}

SetEntry generateSetEntry(
        DateTime previousSetStartTime, Duration setDuration) =>
    SetEntry(
        reps: Random().nextInt(10) + 5,
        weight: Random().nextInt(100) + 20,
        units: "lbs",
        finishedAt: previousSetStartTime.add(setDuration));

Iterable<ExerciseSets> createExerciseSets(
    {required int id,
    required int workoutId,
    required WorkoutDefinition routine,
    required DateTime startTime,
    bool isComplete = true}) {
  final setsCount = isComplete
      ? routine.exercises.length
      : Random().nextInt(routine.exercises.length - 2) + 1;

  var currentId = id;

  return routine.exercises.map((e) {
    final sets = ExerciseSets(
        id: currentId,
        workoutId: workoutId,
        order: e.order,
        exercise: e.exercise,
        sets: e.order > setsCount ? [] : generateSets(startTime),
        isComplete: isComplete);

    currentId++;
    return sets;
  });
}

final workout1Sets = createExerciseSets(
    id: 1, workoutId: 1, routine: routine1, startTime: workoutStartTime);

final workoutRecord1 = WorkoutRecord(
  id: 1,
  fromWorkoutDefinition: routine1,
  startedAt: workoutStartTime,
  lastActivityAt: workout1Sets.last.sets.last.finishedAt,
);

var prevWorkoutRecord = workoutRecord1;
final routines = [routine1, routine2, routine3];

final workout2StartsAt =
    workoutRecord1.lastActivityAt!.add(Duration(days: Random().nextInt(2)));
final workout2Sets = createExerciseSets(
    id: routine1.exercises.length + 1,
    workoutId: 2,
    routine: routine2,
    startTime: workout2StartsAt);

final workoutRecord2 = WorkoutRecord(
  id: 2,
  fromWorkoutDefinition: routine2,
  startedAt: workout2StartsAt,
  lastActivityAt: workout2Sets.last.sets.last.finishedAt,
);

final workout3StartsAt =
    workoutRecord1.lastActivityAt!.add(Duration(days: Random().nextInt(2)));
final workout3Sets = createExerciseSets(
    id: routine1.exercises.length + routine2.exercises.length + 1,
    workoutId: 3,
    routine: routine3,
    startTime: workout3StartsAt,
    isComplete: false);

final workoutRecord3 = WorkoutRecord(
  id: 3,
  fromWorkoutDefinition: routine3,
  startedAt: DateTime.now(),
  lastActivityAt: workout2Sets.any((element) => element.isComplete)
      ? workout2Sets.last.sets.last.finishedAt
      : null,
);
