import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_io.dart';
import 'package:workout_tracker/data/providers/global_providers.dart';
import 'package:workout_tracker/data/repositories/mock_data.dart';
import 'package:workout_tracker/domain/user_preferences.dart';
import 'package:workout_tracker/navigation/router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final appPath = await getApplicationDocumentsDirectory();
  appPath.createSync(recursive: true);
  final dbPath = join(appPath.path, 'workout_tracker.db');

  var mainStore = StoreRef.main();
  var workoutDefinitionStore =
      intMapStoreFactory.store('workout_definition_store');
  var exerciseStore = intMapStoreFactory.store('exercise_store');
  var exerciseSetsStore = intMapStoreFactory.store('exercise_sets_store');
  var workoutRecordStore = intMapStoreFactory.store('workout_record_store');
  var json = routine1.toJson();

  // TODO remove mock data, handle no data case for all stores
  final database = await databaseFactoryIo.openDatabase(dbPath, version: 1,
      onVersionChanged: (db, oldVersion, newVersion) async {
    // If the db does not exist, create some data
    if (oldVersion == 0) {
      await mainStore.record(UserPreferences.storeName).put(db, const UserPreferences(weightUnits: "lbs").toJson());
      
      await workoutDefinitionStore.add(db, json);
      await workoutDefinitionStore.add(db, routine2.toJson());

      await exerciseStore.add(db, bicepsCurl.toJson());
      await exerciseStore.add(db, seatedLegCurl.toJson());
      await exerciseStore.add(db, chestPress.toJson());
      await exerciseStore.add(db, pecFly.toJson());
      await exerciseStore.add(db, legExtension.toJson());
      await exerciseStore.add(db, benchDip.toJson());
      await exerciseStore.add(db, shoulderPress.toJson());
      await exerciseStore.add(db, forwardRaise.toJson());
      await exerciseStore.add(db, tricepPulldown.toJson());

      await workoutRecordStore.add(db, record.toJson());

      for (final set in sets) {
        await exerciseSetsStore.add(db, set.toJson());
      }
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
    var appColorScheme = ColorScheme.fromSeed(seedColor: Colors.blueAccent.shade700);

    return MaterialApp.router(
      routerConfig: router,
      title: 'Workout Tracker',
      theme: ThemeData(
        colorScheme: appColorScheme,
        appBarTheme: AppBarTheme(
          foregroundColor: appColorScheme.onPrimary,
          backgroundColor: appColorScheme.primary,
          elevation: 5,
        ),
        cardTheme: CardTheme(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          elevation: 2,
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: appColorScheme.primary,
          foregroundColor: appColorScheme.onPrimary,
        ),
        useMaterial3: true,
      ),
    );
  }
}
