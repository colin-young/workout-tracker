import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workout_tracker/components/common/custom_scaffold.dart';
import 'package:workout_tracker/components/common/ui/workout_run_menu.dart';
import 'package:workout_tracker/components/summary_page.dart';
import 'package:workout_tracker/controller/timer_controller.dart';
import 'package:workout_tracker/timer/timer_context.dart';
import 'package:workout_tracker/timer/timer_event.dart';

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
        actions: [
          IconButton(
              onPressed: () {
                ref.read(getAllowedEventsProvider.future).then((value) {
                  if (value.any((element) => element.name == Running().name)) {
                    ref
                        .read(timerControllerProvider.notifier)
                        .handleEvent(Reset());
                  } else {
                    ref
                        .read(timerControllerProvider.notifier)
                        .handleEvent(Start());
                  }
                });
              },
              icon: const Icon(Icons.timer)),
          const WorkoutRunMenu()
        ],
      ),
      body: SummaryPage(),
    );
  }
}
