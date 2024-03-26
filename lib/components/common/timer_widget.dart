import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workout_tracker/controller/timer_controller.dart';
import 'package:workout_tracker/timer/timer_context.dart';
import 'package:workout_tracker/timer/timer_event.dart';
import 'dart:developer' as developer;

class TimerWidget extends ConsumerWidget {
  const TimerWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timerContext = ref.watch(getTimerProvider);
    final allowedEvents = ref.watch(getAllowedEventsProvider);
    final events = ref.watch(getEventsProvider);

    switch (events) {
      case AsyncData(:final value):
        developer.log('Timer event: ${value.name}', name: 'TimerWidget.build');
        if (value == Finish()) {
          SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
            final route2 = Router.of(context).routeInformationProvider?.value.uri;
            developer.log('route: ${route2.toString()}', name: 'TimerWidget.build');

            final snackBar = SnackBar(
              content: const Text('Timer completed'),
              action: SnackBarAction(
                label: 'Dismiss',
                onPressed: () {},
              ),
            );

            ScaffoldMessenger.of(context).showSnackBar(snackBar);
          });
        }
    }

    var textStyle = Theme.of(context).textTheme;

    final Size timerDisplaysize = (TextPainter(
            text: TextSpan(text: "00:00", style: textStyle.headlineMedium),
            maxLines: 1,
            textScaler: MediaQuery.of(context).textScaler,
            textDirection: TextDirection.ltr)
          ..layout())
        .size;
    var resetIconButton = IconButton(
      iconSize: 40,
      onPressed: () {
        ref.read(timerControllerProvider.notifier).handleEvent(Reset());
      },
      icon: (const Icon(Icons.restore)),
    );
    var resetIconButtonDisabled = const IconButton(
      iconSize: 40,
      onPressed: null,
      icon: (Icon(Icons.restore)),
    );
    var playIconButton = IconButton(
      onPressed: () {
        ref.read(timerControllerProvider.notifier).handleEvent(Start());
      },
      icon: (const Icon(Icons.play_circle, size: 40)),
    );
    var playIconButtonDisabled = const IconButton(
      onPressed: null,
      icon: (Icon(Icons.play_circle, size: 40)),
    );
    var pauseIconButton = IconButton(
      onPressed: () {
        ref.read(timerControllerProvider.notifier).handleEvent(Pause());
      },
      icon: (const Icon(Icons.pause_circle, size: 40)),
    );

    return switch (timerContext) {
      AsyncData(:final value) => value.state != Initiated()
          ? Hero(
            tag: 'timer',
            child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      allowedEvents.when(
                        data: (events) {
                          return events.contains(Reset())
                              ? resetIconButton
                              : resetIconButtonDisabled;
                        },
                        error: (e, st) => Text(e.toString()),
                        loading: () => const Center(
                          child: CircularProgressIndicator(),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              width: timerDisplaysize.width * 1.1,
                              child: Center(
                                child: Text(
                                  value.context.getDisplay(),
                                  style: textStyle.headlineMedium,
                                ),
                              ),
                            ),
                            Center(
                                child: Text('Rest', style: textStyle.labelSmall))
                          ],
                        ),
                      ),
                      allowedEvents.when(
                        data: (events) {
                          return events.contains(Start())
                              ? playIconButton
                              : events.contains(Pause())
                                  ? pauseIconButton
                                  : playIconButtonDisabled;
                        },
                        error: (e, st) => Text(e.toString()),
                        loading: () => const Center(
                          child: CircularProgressIndicator(),
                        ),
                      ),
                    ]),
              ),
          )
          : const SizedBox(),
      _ => Container(),
    };
  }
}
