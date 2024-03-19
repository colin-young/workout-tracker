import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_memory.dart';
import 'package:test/test.dart';
import 'package:workout_tracker/domain/exercise_sets.dart';

void main() {
  test('workout_record_data_test', () async {
    // In memory factory for unit test
    var factory = newDatabaseFactoryMemory();

    // Define the store
    var store = StoreRef<int, Map<String, dynamic>>.main();

    const Map<String, dynamic> sets = {
        "id": -1,
        "workoutId": 1,
        "exercise": {
          "id": 1,
          "name": "Biceps Curl",
          "exerciseType": "dumbbell",
          "note": "Lorem ipsum dolor sit amet.",
          "settings": []
        },
        "sets": [
          {
            "id": -1,
            "reps": 12,
            "weight": 25,
            "units": "lbs",
            "finishedAt": "2024-02-29T14:30:05.654142"
          },
          {
            "id": -1,
            "reps": 11,
            "weight": 25,
            "units": "lbs",
            "finishedAt": "2024-02-29T14:31:05.654142"
          },
          {
            "id": -1,
            "reps": 9,
            "weight": 25,
            "units": "lbs",
            "finishedAt": "2024-02-29T14:32:05.654142"
          }
        ],
        "isComplete": true,
        "order": 1
    };

    // Define the record
    var record = store.record(1);

    // Open the database
    var db = await factory.openDatabase('test.db');

    // Write a record
    await record.put(db, sets);

    // Verify record content.
    final setsRecord = await record.get(db);
    final readSets = ExerciseSets.fromJson(setsRecord!);
    expect(readSets.sets.length, 3);

    // Close the database
    await db.close();
  });
}
