import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:workout_tracker/components/common/timer_widget.dart';
import 'package:workout_tracker/components/summary_page.dart';

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
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              context.go('/licenses');
            },
          )
        ],
      ),
      body: const SummaryPage(),
      bottomSheet: Consumer(
        builder: (context, ref, child) => const TimerWidget(),
      ),
    );
  }
}
