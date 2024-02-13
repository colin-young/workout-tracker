import 'package:flutter/material.dart';
import 'package:flutter_application_1/components/rounded_button.dart';
import 'package:flutter_application_1/components/workout_exercise_card_view.dart';
import 'package:flutter_application_1/components/workout_summary_card.dart';
import 'package:flutter_application_1/domain/exercise.dart';
import 'package:flutter_application_1/domain/set_entry.dart';
import 'package:flutter_application_1/domain/workout_definition.dart';
import 'package:flutter_application_1/domain/workout_exercise.dart';
import 'package:flutter_application_1/domain/workout_record.dart';
import 'package:flutter_application_1/domain/workout_sets.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Workout Tracker',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.lightBlue),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Summary'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState.factory();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  List<Exercise> exercises = [];
  List<WorkoutRecord> workoutRecords = [];
  List<WorkoutDefinition> workoutDefinitions = [];

  _MyHomePageState(
      this.exercises, this.workoutRecords, this.workoutDefinitions);

  factory _MyHomePageState.factory() {
    var workoutStartTime = DateTime.now().subtract(const Duration(days: 1));
    Exercise bicepsCurl = const Exercise(name: "Biceps Curl");
    Exercise seatedLegCurl = const Exercise(name: "Seated Leg Curl");
    var exerciseList = [bicepsCurl, seatedLegCurl];

    var workoutDefinition = WorkoutDefinition(name: "Routine 1", exercises: [
      WorkoutExercise(order: 1, exercise: bicepsCurl),
      WorkoutExercise(order: 2, exercise: seatedLegCurl),
    ]);

    var workoutDefinition2 = WorkoutDefinition(name: "Routine 2", exercises: [
      WorkoutExercise(order: 1, exercise: bicepsCurl),
      WorkoutExercise(order: 2, exercise: seatedLegCurl),
    ]);

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

    var workoutRecords = [
      WorkoutRecord(
        fromWorkoutDefinition: workoutDefinition,
        sets: sets,
        startedAt: workoutStartTime,
      )
    ];
    var workoutDefinitions = [workoutDefinition, workoutDefinition2];
    return _MyHomePageState(exerciseList, workoutRecords, workoutDefinitions);
  }

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    WorkoutRecord? lastWorkout = WorkoutRecord(fromWorkoutDefinition: const WorkoutDefinition(name: "", exercises: <WorkoutExercise>[]), sets: [], startedAt: DateTime.now());
    workoutRecords.sort((a,b) => a.finishedAt().compareTo(b.finishedAt()));

    lastWorkout = workoutRecords.first;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      appBar: AppBar(
        title: Text(widget.title, style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),),
        backgroundColor: Theme.of(context).colorScheme.primary,
        elevation: 2.0,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          WorkoutSummaryCard(lastWorkout),
          Expanded(
            child: ListView.builder(
                shrinkWrap: true,
                itemCount: workoutRecords[0].sets.length,
                itemBuilder: (BuildContext context, int index) {
                  return WorkoutExerciseCardView(
                      workoutExercise: workoutRecords[0].sets[index]);
                }),
          ),
          Card(
            elevation: 5,
            shape: const BeveledRectangleBorder(),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    "Title",
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  Text(
                    "Subheading",
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const Wrap(
                      alignment: WrapAlignment.spaceAround,
                      runAlignment: WrapAlignment.spaceAround,
                      children: [
                        RoundedButton(
                          "New Routine",
                          Icons.add,
                          iconSize: 20,
                        ),
                        RoundedButton(
                          "Exercises",
                          FontAwesomeIcons.weightHanging,
                          iconSize: 14,
                        ),
                      ]),
                  Wrap(
                    alignment: WrapAlignment.spaceAround,
                    runAlignment: WrapAlignment.spaceAround,
                    children: [
                      for (var definition in workoutDefinitions)
                        RoundedButton(definition.name, Icons.play_arrow),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
