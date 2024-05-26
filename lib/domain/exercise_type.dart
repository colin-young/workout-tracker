import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

enum ExerciseType {
  freeWeight(display: 'Free weights', icon: FontAwesomeIcons.dumbbell),
  machine(display: 'Machine', icon: FontAwesomeIcons.gears),
  bodyWeight(display: 'Body weight', icon: Icons.person);

  const ExerciseType({required this.display, required this.icon});

  final String display;
  final IconData icon;
}
