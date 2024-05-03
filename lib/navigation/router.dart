import 'package:go_router/go_router.dart';
import 'package:workout_tracker/components/pages/add_workout_exercise.dart';
import 'package:workout_tracker/components/pages/exercise_edit_page.dart';
import 'package:workout_tracker/components/pages/exercise_page.dart';
import 'package:workout_tracker/components/pages/home_page.dart';
import 'package:workout_tracker/components/pages/licenses_page.dart';
import 'package:workout_tracker/components/pages/routine_page.dart';
import 'package:workout_tracker/components/pages/workout_page.dart';

final GoRouter router = GoRouter(
  routes: [
    GoRoute(
        name: 'home', // NON-NLS
        path: '/', // NON-NLS
        builder: (context, state) => const HomePage(title: 'Summary'), // NON-NLS
        routes: [
          GoRoute(
              name: 'exercises', // NON-NLS
              path: 'exercises', // NON-NLS
              builder: (context, state) => const ExercisePage(),
              routes: [
                GoRoute(
                  name: 'exerciseEdit', // NON-NLS
                  path: 'exercise/:exerciseId/edit', // NON-NLS
                  builder: (context, state) => ExerciseEditPage(
                    exerciseId: state.pathParameters['exerciseId']!, // NON-NLS
                    title: 'Exercise Name', // NON-NLS
                  ),
                ),
              ]),
          GoRoute(
              name: 'routines', // NON-NLS
              path: 'routines', // NON-NLS
              builder: (context, state) => const RoutinePage(),
              routes: const []),
          GoRoute(
              name: 'workout', // NON-NLS
              path: 'workout/:workoutId', // NON-NLS
              builder: (context, state) => WorkoutPage(
                  title: 'Workout', // NON-NLS
                  workoutId: state.pathParameters['workoutId']!), // NON-NLS
              routes: [
                GoRoute(
                  name: 'addWorkoutExercise', // NON-NLS
                  path: 'addExercise', // NON-NLS
                  builder: (context, state) => AddWorkoutExercise(
                      title: 'Add Exercise', // NON-NLS
                      workoutId: state.pathParameters['workoutId']!), // NON-NLS
                )
              ]),
          GoRoute(
            name: 'licenses', // NON-NLS
            path: 'licenses', // NON-NLS
            builder: (context, state) => const LicencesPage(),
          )
        ]),
  ],
);
