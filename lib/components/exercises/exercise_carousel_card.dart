import 'dart:math';

import 'package:flutter/material.dart';
import 'package:workout_tracker/components/exercises/exercise_settings_display.dart';
import 'package:workout_tracker/domain/exercise.dart';

class ExerciseCarouselCard extends StatelessWidget {
  const ExerciseCarouselCard({super.key, required this.entry});

  final Exercise entry;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    var screenWidth = MediaQuery.of(context).size.width;
    var screenHeight = MediaQuery.of(context).size.height;

    return Card(
        child: SizedBox(
          height: min(screenWidth / 6.6 * (16 / 9), screenHeight * .35),
          width: screenWidth / 8,
          child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(entry.name,
                        style: Theme.of(context).textTheme.titleLarge),
                    ExerciseSettingsDisplay(
                        entry: entry,
                        backgroundColor: colorScheme.secondary,
                        onBackgroundColor: colorScheme.onSecondary),
                  ],
              )
          ),
        )
    );
  }
}