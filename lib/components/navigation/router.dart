import 'package:go_router/go_router.dart';
import 'package:workout_tracker/components/pages/workout/add_workout_exercise.dart';
import 'package:workout_tracker/components/pages/exercise_edit_page.dart';
import 'package:workout_tracker/components/pages/exercise_page.dart';
import 'package:workout_tracker/components/pages/home_page.dart';
import 'package:workout_tracker/components/pages/licenses_page.dart';
import 'package:workout_tracker/components/pages/routine_page.dart';
import 'package:workout_tracker/components/pages/user_preferences_page.dart';
import 'package:workout_tracker/components/pages/workout_page.dart';

final GoRouter router = GoRouter(
  routes: [
    GoRoute(
        name: 'home',
        path: '/',
        builder: (context, state) => const HomePage(title: 'Summary'),
        routes: [
          GoRoute(
              name: 'exercises',
              path: 'exercises',
              builder: (context, state) => const ExercisePage(),
              routes: [
                GoRoute(
                  name: 'exerciseEdit',
                  path: 'exercise/:exerciseId/edit',
                  builder: (context, state) => ExerciseEditPage(
                    exerciseId: state.pathParameters['exerciseId']!,
                    title: 'Edit Exercise',
                  ),
                ),
              ]),
          GoRoute(
              name: 'routines',
              path: 'routines',
              builder: (context, state) => const RoutinePage(),
              routes: const []),
          GoRoute(
              name: 'workout',
              path: 'workout/:workoutId',
              builder: (context, state) => WorkoutPage(
                  title: 'Workout',
                  workoutId: state.pathParameters['workoutId']!),
              routes: [
                GoRoute(
                  name: 'addWorkoutExercise',
                  path: 'addExercise',
                  builder: (context, state) => AddWorkoutExercise(
                      title: 'Add Exercise',
                      workoutId: state.pathParameters['workoutId']!),
                )
              ]),
          GoRoute(
            name: 'userPreferences',
            path: 'userPreferences',
            builder: (context, state) => const UserPreferencesPage()),
          GoRoute(
            name: 'licenses',
            path: 'licenses',
            builder: (context, state) => const LicencesPage(),
          )
        ]),
  ],
);
