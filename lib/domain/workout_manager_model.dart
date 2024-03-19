import 'dart:async';

import 'package:workout_tracker/domain/exercise.dart';
import 'package:workout_tracker/domain/exercise_sets.dart';
import 'package:workout_tracker/domain/workout_record.dart';

class WorkoutManagerModel {
  final WorkoutRecord workoutRecord;
  final List<ExerciseSets> exerciseSets;

  final _currentExerciseController = StreamController<Exercise>.broadcast();
  Stream<Exercise> get streamState => _currentExerciseController.stream;

  final _upcomingExercisesController =
      StreamController<List<Exercise>>.broadcast();
  Stream<List<Exercise>> get streamUpcoming =>
      _upcomingExercisesController.stream;

  final _completedExercisesController =
      StreamController<List<Exercise>>.broadcast();
  Stream<List<Exercise>> get streamCompleted =>
      _completedExercisesController.stream;

  WorkoutManagerModel(
      {required this.exerciseSets, required this.workoutRecord});

  Future<void> close() async {
    await Future.wait([
      _currentExerciseController.close(),
      _upcomingExercisesController.close(),
      _completedExercisesController.close(),
    ]);
  }
}
