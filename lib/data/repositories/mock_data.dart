import 'package:workout_tracker/domain/exercise.dart';
import 'package:workout_tracker/domain/set_entry.dart';
import 'package:workout_tracker/domain/workout_definition.dart';
import 'package:workout_tracker/domain/workout_exercise.dart';
import 'package:workout_tracker/domain/workout_record.dart';
import 'package:workout_tracker/domain/workout_sets.dart';

const bicepsCurl = Exercise(name: "Biceps Curl", exerciseType: "dumbbell", note: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Quisque vehicula orci at tempus consectetur. Aliquam eu tellus lorem. Curabitur quis metus finibus, dignissim purus aliquam, mollis nulla. Duis id felis ligula. Aenean et massa varius, accumsan ipsum eu, rutrum leo. Sed iaculis felis non hendrerit sollicitudin. Nam odio nisi, semper.");
const seatedLegCurl = Exercise(name: "Seated Leg Curl", exerciseType: "machine");
const chestPress = Exercise(name: "Chest Press", exerciseType: "machine");
const pecFly = Exercise(name: "Pec Fly", exerciseType: "machine");
const legExtension = Exercise(name: "Leg Extension", exerciseType: "machine");
const exerciseList = [bicepsCurl, seatedLegCurl, chestPress, pecFly, legExtension];
const routine1 = WorkoutDefinition(name: "Routine 1", exercises: [
  WorkoutExercise(order: 1, exercise: bicepsCurl),
  WorkoutExercise(order: 2, exercise: seatedLegCurl),
  WorkoutExercise(order: 3, exercise: legExtension),
]);
const routine2 = WorkoutDefinition(name: "Routine 2", exercises: [
  WorkoutExercise(order: 1, exercise: chestPress),
  WorkoutExercise(order: 2, exercise: pecFly),
]);
const routine3 = WorkoutDefinition(name: "Routine 3", exercises: [
  WorkoutExercise(order: 1, exercise: chestPress),
  WorkoutExercise(order: 2, exercise: pecFly),
  WorkoutExercise(order: 3, exercise: bicepsCurl),
]);
const workoutDefinitions = [routine1, routine2, routine3];

class MockData {
  final exercises = exerciseList;
  final WorkoutRecord workoutRecord;

  MockData(this.workoutRecord);

  factory MockData.factory() {
    var workoutStartTime = DateTime.now().subtract(const Duration(days: 1));
    var sets = <WorkoutSets>[
      WorkoutSets(
          exercise: bicepsCurl,
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
      WorkoutSets(
          exercise: seatedLegCurl,
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
    ];
    var record = WorkoutRecord(
      fromWorkoutDefinition: routine1,
      sets: sets,
      startedAt: workoutStartTime,
    );

    return MockData(record);
  }
}