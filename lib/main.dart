import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_io.dart';
import 'package:workout_tracker/components/pages/exercise_page.dart';
import 'package:workout_tracker/components/pages/home_page.dart';
import 'package:workout_tracker/data/providers/global_providers.dart';
import 'package:workout_tracker/data/repositories/mock_data.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final appPath = await getApplicationDocumentsDirectory();
  appPath.createSync(recursive: true);
  final dbPath = join(appPath.path, 'workout_tracker.db');
  // final database = await databaseFactoryIo.openDatabase(dbPath);

  var workoutDefinitionStore =
      intMapStoreFactory.store('workout_definition_store');
  var exerciseStore = intMapStoreFactory.store('exercise_store');
  var json = routine1.toJson();

  final database = await databaseFactoryIo.openDatabase(dbPath, version: 1,
      onVersionChanged: (db, oldVersion, newVersion) async {
    // If the db does not exist, create some data
    if (oldVersion == 0) {
      await workoutDefinitionStore.add(db, json);
      await workoutDefinitionStore.add(db, routine2.toJson());

      await exerciseStore.add(db, bicepsCurl.toJson());
      await exerciseStore.add(db, seatedLegCurl.toJson());
      await exerciseStore.add(db, chestPress.toJson());
      await exerciseStore.add(db, pecFly.toJson());
      await exerciseStore.add(db, legExtension.toJson());
    }
  });

  runApp(
    ProviderScope(
      overrides: [
        databaseProvider.overrideWithValue(database),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final GoRouter router = GoRouter(
      routes: [
        GoRoute(
          path: "/",
          builder: (context, state) => const HomePage(title: "Summary"),
        ),
        GoRoute(
          path: "/exercises",
          builder: (context, state) => const ExercisePage(),
        ),
      ],
    );

    return MaterialApp.router(
      routerConfig: router,
      title: 'Workout Tracker',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.lightBlue),
        useMaterial3: true,
      ),
    );
  }
}
