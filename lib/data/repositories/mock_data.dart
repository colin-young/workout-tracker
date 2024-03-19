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
const exerciseList = [
  bicepsCurl,
  seatedLegCurl,
  chestPress,
  pecFly,
  legExtension,
  benchDip
];
const routine1 = WorkoutDefinition(name: "Routine 1", exercises: [
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
final workoutStartTime = DateTime.now().subtract(const Duration(days: 1));

final sets = <ExerciseSets>[
  ExerciseSets(
      workoutId: 1,
      exercise: bicepsCurl,
      order: 1,
      sets: [
        SetEntry(
            reps: 12,
            weight: 25,
            units: "lbs",
            finishedAt: workoutStartTime.add(const Duration(minutes: 1))),
        SetEntry(
            reps: 11,
            weight: 25,
            units: "lbs",
            finishedAt: workoutStartTime.add(const Duration(minutes: 2))),
        SetEntry(
            reps: 9,
            weight: 25,
            units: "lbs",
            finishedAt: workoutStartTime.add(const Duration(minutes: 3))),
      ],
      isComplete: true),
  ExerciseSets(
      workoutId: 1,
      exercise: seatedLegCurl,
      order: 2,
      sets: [
        SetEntry(
            reps: 12,
            weight: 160,
            units: "lbs",
            finishedAt: workoutStartTime.add(const Duration(minutes: 5))),
        SetEntry(
            reps: 9,
            weight: 160,
            units: "lbs",
            finishedAt: workoutStartTime.add(const Duration(minutes: 6))),
        SetEntry(
            reps: 8,
            weight: 160,
            units: "lbs",
            finishedAt: workoutStartTime.add(const Duration(minutes: 7))),
      ],
      isComplete: false),
  const ExerciseSets(
    workoutId: 1,
    order: 3,
    exercise: legExtension,
    sets: [],
    isComplete: false,
  ),
  const ExerciseSets(
    workoutId: 1,
    order: 4,
    exercise: chestPress,
    sets: [],
    isComplete: false,
  ),
  const ExerciseSets(
    workoutId: 1,
    order: 5,
    exercise: benchDip,
    sets: [],
    isComplete: false,
  ),
  const ExerciseSets(
    workoutId: 1,
    order: 6,
    exercise: pecFly,
    sets: [],
    isComplete: false,
  ),
];

final record = WorkoutRecord(
  fromWorkoutDefinition: routine1,
  startedAt: workoutStartTime,
);
