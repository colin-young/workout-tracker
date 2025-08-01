import 'dart:math';
import 'package:workout_tracker/domain/exercise.dart';
import 'package:workout_tracker/domain/exercise_setting.dart';
import 'package:workout_tracker/domain/exercise_type.dart';
import 'package:workout_tracker/domain/set_entry.dart';
import 'package:workout_tracker/domain/workout_definition.dart';
import 'package:workout_tracker/domain/workout_exercise.dart';
import 'package:workout_tracker/domain/workout_record.dart';
import 'package:workout_tracker/domain/exercise_sets.dart';

final bicepsCurl = Exercise(
    id: 1,
    name: 'Biceps Curl',
    exerciseType: ExerciseType.freeWeight.serialize,
    note: 'Lorem ipsum dolor sit amet.',
    settings: []);
final seatedLegCurl = Exercise(
    id: 2,
    name: 'Seated Leg Curl',
    exerciseType: ExerciseType.machine.serialize,
    note: 'Sample note content.',
    settings: [
      const ExerciseSetting(id: 1, setting: 'lower', value: '3'),
      const ExerciseSetting(id: 2, setting: 'middle', value: '6'),
      const ExerciseSetting(id: 3, setting: 'upper', value: '3'),
      const ExerciseSetting(id: 4, setting: 'seat', value: '4')
    ]);
final chestPress = Exercise(
    id: 3,
    name: 'Chest Press',
    exerciseType: ExerciseType.machine.serialize,
    settings: []);
final pecFly = Exercise(
    id: 4, name: 'Pec Fly', exerciseType: ExerciseType.machine.serialize, settings: []);
final legExtension = Exercise(
    id: 5,
    name: 'Leg Extension',
    exerciseType: ExerciseType.machine.serialize,
    settings: [
      const ExerciseSetting(id: 1, setting: 'lower', value: '1'),
      const ExerciseSetting(id: 2, setting: 'upper', value: '2')
    ]);
final benchDip = Exercise(
    id: 6,
    name: 'Bench Dip',
    exerciseType: ExerciseType.bodyWeight.serialize,
    settings: []);
final shoulderPress = Exercise(
    id: 7,
    name: 'Shoulder Press',
    exerciseType: ExerciseType.freeWeight.serialize,
    settings: []);
final forwardRaise = Exercise(
    id: 8,
    name: 'Forward Raise',
    exerciseType: ExerciseType.freeWeight.serialize,
    settings: []);
final tricepPulldown = Exercise(
    id: 9,
    name: 'Tricep Pulldown',
    exerciseType: ExerciseType.machine.serialize,
    settings: []);
final exerciseList = [
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
final routine1 = WorkoutDefinition(id: 1, name: 'Routine 1', exercises: [
  WorkoutExercise(id: 1, order: 1, exercise: bicepsCurl),
  WorkoutExercise(id: 2, order: 2, exercise: seatedLegCurl),
  WorkoutExercise(id: 5, order: 3, exercise: legExtension),
  WorkoutExercise(id: 5, order: 4, exercise: chestPress),
  WorkoutExercise(id: 5, order: 5, exercise: pecFly),
]);
final routine2 = WorkoutDefinition(id: 2, name: 'Routine 2', exercises: [
  WorkoutExercise(id: 3, order: 1, exercise: chestPress),
  WorkoutExercise(id: 4, order: 2, exercise: pecFly),
]);
final routine3 = WorkoutDefinition(id: 3, name: 'Routine 3', exercises: [
  WorkoutExercise(order: 1, exercise: chestPress),
  WorkoutExercise(order: 2, exercise: pecFly),
  WorkoutExercise(order: 3, exercise: bicepsCurl),
]);
final workoutDefinitions = [routine1, routine2, routine3];
final workoutStartTime = DateTime.now().subtract(const Duration(days: 8 * 7));

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
        units: 'lbs',
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
