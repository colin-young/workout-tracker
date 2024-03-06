import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workout_tracker/controller/timer_controller.dart';
import 'package:workout_tracker/timer/timer_event.dart';

class TimerWidget extends ConsumerWidget {
  const TimerWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timerContext = ref.watch(getContextProvider);
    final allowedEvents = ref.watch(getAllowedEventsProvider);

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

    return Padding(
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
                  timerContext.when(
                    data: (context) {
                      return SizedBox(
                        width: timerDisplaysize.width * 1.1,
                        child: Center(
                          child: Text(
                            context.getDisplay(),
                            style: textStyle.headlineMedium,
                          ),
                        ),
                      );
                    },
                    error: (e, st) => Text(e.toString()),
                    loading: () => const Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
                  Center(child: Text('Rest', style: textStyle.labelSmall))
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
    );
  }
}
