import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workout_tracker/components/common/custom_scaffold.dart';
import 'package:workout_tracker/components/common/ui/workout_run_menu.dart';
import 'package:workout_tracker/timer/timer_set_dialog.dart';
import 'package:workout_tracker/components/summary_page.dart';

class HomePage extends ConsumerWidget {
  const HomePage({
    super.key,
    required this.title,
  });

  final String title;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CustomScaffold(
      // TODO move to common component
      appBar: AppBar(
        title: Text(
          title,
        ),
        actions: const [
          WorkoutRunMenu()
        ],
      ),
      body: SummaryPage(),
    );
  }
}
