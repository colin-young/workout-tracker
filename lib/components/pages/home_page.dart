import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workout_tracker/components/common/timer_widget.dart';
import 'package:workout_tracker/components/summary_page.dart';
import 'package:workout_tracker/controller/timer_controller.dart';
import 'dart:developer' as developer;

class HomePage extends StatelessWidget {
  const HomePage({
    super.key,
    required this.title,
  });

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          title,
        ),
      ),
      body: const SummaryPage(),
      bottomSheet: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Consumer(
          builder: (context, ref, child) {
            return const TimerWidget();
          },
        ),
      ),
    );
  }
}
