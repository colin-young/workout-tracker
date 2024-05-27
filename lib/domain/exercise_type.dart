import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:workout_tracker/domain/exercise_type_serialized.dart';

// enum ExerciseType {
//   freeWeight(display: 'Free weights', icon: FontAwesomeIcons.dumbbell),
//   machine(display: 'Machine', icon: FontAwesomeIcons.gears),
//   bodyWeight(display: 'Body weight', icon: Icons.person);

//   const ExerciseType({required this.display, required this.icon});

//   final String display;
//   final IconData icon;
// }

class ExerciseType {
  final String display;
  final IconData icon;

  static const String freeWeightsDisplay = 'Free weights';
  static const String machineDisplay = 'Machine';
  static const String bodyWeightDisplay = 'Body weight';

  const ExerciseType({required this.display, required this.icon});

  @override
  operator ==(other) => other is ExerciseType && other.display.toLowerCase() == display.toLowerCase();

  static ExerciseType get freeWeight => const ExerciseType(
      display: freeWeightsDisplay, icon: FontAwesomeIcons.dumbbell);
  static ExerciseType get machine =>
      const ExerciseType(display: machineDisplay, icon: FontAwesomeIcons.gears);
  static ExerciseType get bodyWeight =>
      const ExerciseType(display: bodyWeightDisplay, icon: Icons.person);
  static ExerciseType get unknown =>
      const ExerciseType(display: 'unknown', icon: Icons.question_mark);

  static List<ExerciseType> get values =>
      [ExerciseType.freeWeight, ExerciseType.machine, ExerciseType.bodyWeight];
  
  @override
  int get hashCode => display.hashCode;

  static ExerciseType deserialize(String display) {
    switch (display) {
      case freeWeightsDisplay:
        return ExerciseType.freeWeight;
      case machineDisplay:
        return ExerciseType.machine;
      case bodyWeightDisplay:
        return ExerciseType.bodyWeight;
    }

    return ExerciseType(display: display, icon: Icons.person_add);
  }

  ExerciseTypeSerialized get serialize => ExerciseTypeSerialized(display: display);
}
