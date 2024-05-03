import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workout_tracker/controller/timer_controller.dart';
import 'package:workout_tracker/timer/timer_context.dart';
import 'package:workout_tracker/timer/timer_event.dart';
import 'dart:developer' as developer;

class TimerWidget extends ConsumerStatefulWidget {
  final Duration animationDuration;
  final bool isVisible;

  const TimerWidget(
      {super.key,
      this.animationDuration = const Duration(milliseconds: 300),
      this.isVisible = false});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => TimerWidgetState();
}

class TimerWidgetState extends ConsumerState<TimerWidget>
    with TickerProviderStateMixin {
  late bool isVisible;

  double widgetHeight = 72.0;
  String display = '';

  @override
  void initState() {
    super.initState();
    isVisible = widget.isVisible;
    developer.log('Animation: ${_controller.value}',
        name: 'TimerWidget.initState');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  late final AnimationController _controller = AnimationController(
    duration: widget.animationDuration,
    reverseDuration:
        Duration(milliseconds: (widget.animationDuration.inMilliseconds ~/ 2)),
    vsync: this,
  );

  late final Animation<double> _expandTimer =
      Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(
    parent: _controller,
    curve: const Interval(0, 0.75, curve: Easing.standardDecelerate),
    reverseCurve:
        const Interval(0.25, 1.0, curve: Easing.standardAccelerate)
            .flipped,
  ));

  late final Animation<double> _opacity = Tween(begin: 0.0, end: 1.0).animate(
    CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.5, 1.0, curve: Easing.standardDecelerate),
        reverseCurve:
            const Interval(0.0, 0.5, curve: Easing.standardAccelerate).flipped),
  );

  Future<void> _setIsVisible(bool visible) async {
    setState(() {
      isVisible = visible;
    });

    try {
      if (isVisible) {
        await _controller.forward().orCancel;
      } else {
        await _controller.reverse().orCancel;
      }
    } on TickerCanceled {
      // The animation got canceled, probably because it was disposed of.
    }
  }

  void _setDisplay(TimerContext context) {
    setState(() {
      display = context.getDisplay();
    });
  }

  @override
  Widget build(BuildContext context) {
    final timerContext = ref.watch(getTimerProvider());
    final allowedEvents = ref.watch(getAllowedEventsProvider);
    final events = ref.watch(getEventsProvider);

    switch (events) {
      case AsyncValue(:final value, hasValue: true):
        if (value == Finish()) {
          SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
            final snackBar = SnackBar(
              content: const Text('Timer completed'),
              action: SnackBarAction(
                label: 'Dismiss',
                onPressed: () {},
              ),
            );

            ScaffoldMessenger.of(context).showSnackBar(snackBar);
            _setIsVisible(false);
          });
        } else {
          _setIsVisible(value != Reset());
        }
    }

    switch (timerContext) {
      case AsyncValue(:final value?):
        if (value.state != Initiated()) {
          _setIsVisible(true);
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

    var hero = AnimatedBuilder(
      animation: _expandTimer,
      builder: (BuildContext context, Widget? child) {
        var isAnimating = _controller.status != AnimationStatus.completed &&
            _controller.status != AnimationStatus.dismissed;
        double finalScale = isVisible ? 1.0 : 0;

        return Transform.scale(
          scale: isAnimating ? _expandTimer.value : finalScale,
          child: SizedBox(
            height: isAnimating
                ? widgetHeight * _expandTimer.value
                : widgetHeight * finalScale,
            child: Opacity(
              opacity: _opacity.value,
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
      },
    );

    return switch (timerContext) {
      AsyncValue(hasValue: true) => hero,
      _ => const SizedBox(width: 0, height: 0)
    };
  }
}
