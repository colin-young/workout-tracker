import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workout_tracker/controller/timer_controller.dart';
import 'package:workout_tracker/timer/timer_context.dart';
import 'package:workout_tracker/timer/timer_event.dart';
import 'dart:developer' as developer;

class TimerWidget extends ConsumerStatefulWidget {
  const TimerWidget({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _TimerWidgetState();
}

class _TimerWidgetState extends ConsumerState<TimerWidget> {
  late double height;
  late bool isVisible;

  double widgetHeight = 72.0;
  String display = '';

  @override
  void initState() {
    super.initState();
    height = 0.0;
    isVisible = false;
  }

  void _setVisible() {
    setState(() {
      isVisible = true;
      height = widgetHeight;
    });
  }

  void _setInvisible() {
    setState(() {
      height = 0;
    });
  }

  void _setIsVisible(bool visible) {
    setState(() {
      isVisible = visible;
    });
  }

  void _setDisplay(TimerContext context) {
    setState(() {
      display = context.getDisplay();
    });
  }

  @override
  Widget build(BuildContext context) {
    final timerContext = ref.watch(getTimerProvider);
    final allowedEvents = ref.watch(getAllowedEventsProvider);
    final events = ref.watch(getEventsProvider);

    switch (events) {
      case AsyncData(:final value):
        developer.log('Timer event: ${value.name}', name: 'TimerWidget.build');
        if (value == Finish()) {
          SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
            final route2 =
                Router.of(context).routeInformationProvider?.value.uri;
            developer.log('route: ${route2.toString()}',
                name: 'TimerWidget.build');

            final snackBar = SnackBar(
              content: const Text('Timer completed'),
              action: SnackBarAction(
                label: 'Dismiss',
                onPressed: () {},
              ),
            );

            ScaffoldMessenger.of(context).showSnackBar(snackBar);
            _setInvisible();
          });
        } else {
          if (value == Reset()) {
            _setInvisible();
          } else {
            _setVisible();
          }
        }
    }

    switch (timerContext) {
      case AsyncData(:final value):
        if (value.state != Initiated()) {
          _setVisible();
        }
        _setDisplay(value.context);
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
        developer.log('start event fired',
            name: '_TimerWidgetState.playIconButton.onPressed');
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

    return Hero(
            tag: 'timer',
            child: AnimatedSize(
              duration: const Duration(milliseconds: 100),
              reverseDuration: const Duration(milliseconds: 100),
              onEnd: () {
                _setIsVisible(height == widgetHeight);
              },
              child: SizedBox(
                height: height,
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
                                    display,
                                    style: textStyle.headlineMedium,
                                  ),
                                ),
                              ),
                              Center(
                                  child:
                                      Text('Rest', style: textStyle.labelSmall))
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
              ),
            ),
          );
  }
}
