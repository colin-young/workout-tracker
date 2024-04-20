import 'dart:math';

import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_io.dart';
import 'package:workout_tracker/data/providers/global_providers.dart';
import 'package:workout_tracker/data/repositories/mock_data.dart';
import 'package:workout_tracker/domain/exercise_sets.dart';
import 'package:workout_tracker/domain/user_preferences.dart';
import 'package:workout_tracker/domain/workout_record.dart';
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

  // TODO remove mock data, handle no data case for all stores
  final database = await databaseFactoryIo.openDatabase(dbPath, version: 1,
      onVersionChanged: (db, oldVersion, newVersion) async {
    // If the db does not exist, create some data
    if (oldVersion == 0) {
      await mainStore.record(UserPreferences.storeName).put(
          db,
          const UserPreferences(
            weightUnits: "lbs",
            autoCloseWorkout: UserPreferencesAutoCloseWorkout(
                autoClose: true, autoCloseWorkoutAfter: Duration(hours: 12)),
            showcase: UserPreferencesShowcase(summaryPage: false),
          ).toJson());

      await exerciseStore.add(db, bicepsCurl.toJson());
      await exerciseStore.add(db, seatedLegCurl.toJson());
      await exerciseStore.add(db, chestPress.toJson());
      await exerciseStore.add(db, pecFly.toJson());
      await exerciseStore.add(db, legExtension.toJson());
      await exerciseStore.add(db, benchDip.toJson());
      await exerciseStore.add(db, shoulderPress.toJson());
      await exerciseStore.add(db, forwardRaise.toJson());
      await exerciseStore.add(db, tricepPulldown.toJson());

      await workoutDefinitionStore.add(db, routine1.toJson());
      await workoutDefinitionStore.add(db, routine2.toJson());
      await workoutDefinitionStore.add(db, routine3.toJson());

      final routines = [routine1, routine2, routine3];
      var prevWorkoutRecordStart = workoutStartTime;
      var setsCount = 0;

      for (int i = 1; i < 4; i++) {
        var routine = routines[i % 3];

        final workoutStartsAt =
            prevWorkoutRecordStart.add(Duration(days: Random().nextInt(2) + 7));
        final workoutSets = createExerciseSets(
            id: setsCount + 1,
            workoutId: i,
            routine: routine,
            startTime: workoutStartsAt);

        setsCount = setsCount + workoutSets.length;

        final workoutRecord = WorkoutRecord(
          id: i,
          fromWorkoutDefinition: routine,
          startedAt: prevWorkoutRecordStart,
          lastActivityAt: workoutSets.last.sets.last.finishedAt,
        );

        prevWorkoutRecordStart = workoutRecord.lastActivityAt;

        await workoutRecordStore.add(db, workoutRecord.toJson());
        await insertExerciseSets(workoutSets, exerciseSetsStore, db);
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

Future<void> insertExerciseSets(Iterable<ExerciseSets> sets,
    StoreRef<int, Map<String, Object?>> exerciseSetsStore, Database db) async {
  for (final set in sets) {
    await exerciseSetsStore.add(db, set.toJson());
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: router,
      title: 'Workout Tracker',
      theme: FlexThemeData.light(
        scheme: FlexScheme.bahamaBlue,
        subThemesData: const FlexSubThemesData(
          interactionEffects: false,
          blendOnColors: false,
          useTextTheme: true,
          elevatedButtonSecondarySchemeColor: SchemeColor.onPrimary,
          inputDecoratorBorderType: FlexInputBorderType.underline,
          inputDecoratorUnfocusedBorderIsColored: false,
          alignedDropdown: true,
          tooltipRadius: 4.0,
          tooltipSchemeColor: SchemeColor.inverseSurface,
          tooltipOpacity: 0.9,
          useInputDecoratorThemeInDialogs: true,
          snackBarElevation: 6.0,
          snackBarBackgroundSchemeColor: SchemeColor.inverseSurface,
          navigationBarSelectedLabelSchemeColor: SchemeColor.onSurface,
          navigationBarUnselectedLabelSchemeColor: SchemeColor.onSurface,
          navigationBarMutedUnselectedLabel: false,
          navigationBarSelectedIconSchemeColor: SchemeColor.onSurface,
          navigationBarUnselectedIconSchemeColor: SchemeColor.onSurface,
          navigationBarMutedUnselectedIcon: false,
          navigationBarIndicatorSchemeColor: SchemeColor.secondaryContainer,
          navigationBarIndicatorOpacity: 1.00,
          navigationRailSelectedLabelSchemeColor: SchemeColor.onSurface,
          navigationRailUnselectedLabelSchemeColor: SchemeColor.onSurface,
          navigationRailMutedUnselectedLabel: false,
          navigationRailSelectedIconSchemeColor: SchemeColor.onSurface,
          navigationRailUnselectedIconSchemeColor: SchemeColor.onSurface,
          navigationRailMutedUnselectedIcon: false,
          navigationRailIndicatorSchemeColor: SchemeColor.secondaryContainer,
          navigationRailIndicatorOpacity: 1.00,
          navigationRailBackgroundSchemeColor: SchemeColor.surface,
          navigationRailLabelType: NavigationRailLabelType.none,
        ),
        keyColors: const FlexKeyColors(),
        visualDensity: FlexColorScheme.comfortablePlatformDensity,
        useMaterial3: true,
        swapLegacyOnMaterial3: true,
        // To use the Playground font, add GoogleFonts package and uncomment
        // fontFamily: GoogleFonts.notoSans().fontFamily,
      ),
      darkTheme: FlexThemeData.dark(
        scheme: FlexScheme.bahamaBlue,
        subThemesData: const FlexSubThemesData(
          interactionEffects: false,
          useTextTheme: true,
          elevatedButtonSecondarySchemeColor: SchemeColor.onPrimary,
          inputDecoratorBorderType: FlexInputBorderType.underline,
          inputDecoratorUnfocusedBorderIsColored: false,
          alignedDropdown: true,
          tooltipRadius: 4.0,
          tooltipSchemeColor: SchemeColor.inverseSurface,
          tooltipOpacity: 0.9,
          useInputDecoratorThemeInDialogs: true,
          snackBarElevation: 6.0,
          snackBarBackgroundSchemeColor: SchemeColor.inverseSurface,
          navigationBarSelectedLabelSchemeColor: SchemeColor.onSurface,
          navigationBarUnselectedLabelSchemeColor: SchemeColor.onSurface,
          navigationBarMutedUnselectedLabel: false,
          navigationBarSelectedIconSchemeColor: SchemeColor.onSurface,
          navigationBarUnselectedIconSchemeColor: SchemeColor.onSurface,
          navigationBarMutedUnselectedIcon: false,
          navigationBarIndicatorSchemeColor: SchemeColor.secondaryContainer,
          navigationBarIndicatorOpacity: 1.00,
          navigationRailSelectedLabelSchemeColor: SchemeColor.onSurface,
          navigationRailUnselectedLabelSchemeColor: SchemeColor.onSurface,
          navigationRailMutedUnselectedLabel: false,
          navigationRailSelectedIconSchemeColor: SchemeColor.onSurface,
          navigationRailUnselectedIconSchemeColor: SchemeColor.onSurface,
          navigationRailMutedUnselectedIcon: false,
          navigationRailIndicatorSchemeColor: SchemeColor.secondaryContainer,
          navigationRailIndicatorOpacity: 1.00,
          navigationRailBackgroundSchemeColor: SchemeColor.surface,
          navigationRailLabelType: NavigationRailLabelType.none,
        ),
        keyColors: const FlexKeyColors(),
        visualDensity: FlexColorScheme.comfortablePlatformDensity,
        useMaterial3: true,
        swapLegacyOnMaterial3: true,
      ),
      themeMode: ThemeMode.system,
    );
  }
}
