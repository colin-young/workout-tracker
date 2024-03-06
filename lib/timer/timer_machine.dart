import 'dart:async';

import 'package:workout_tracker/timer/timer_event.dart';
import 'package:workout_tracker/timer/timer_context.dart';
import 'package:workout_tracker/fsm/machine.dart';

class TimerMachine extends Machine<TimerContext, TimerState, TimerEvent> {
  Timer? _timer;

  TimerMachine._(
      {required Initiated super.state,
      required super.events,
      required super.context}) {
    if (super.state == Running()) {
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        handleEvent(UpdateDisplay());
      });
    }
  }

  @override
  Future<void> close() async {
    await super.close();
    _timer?.cancel();
  }

  @override
  handleEvent(TimerEvent event) {
    super.handleEvent(event);

    if (state == Running()) {
      if (_timer != null)
      {
        _timer?.cancel();
      }

      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        handleEvent(UpdateDisplay());
      });
    } else {
      _timer?.cancel();
    }

    super.handleEvent(UpdateDisplay());
  }

  factory TimerMachine.create({required TimerContext context}) {
    return TimerMachine._(
        state: Initiated(),
        events: {
          Initiated(): {Start(): Running(), UpdateDisplay(): Initiated()},
          Running(): {
            Finish(): Finished(),
            Pause(): Paused(),
            Reset(): Initiated(),
            UpdateDisplay(): Running(),
          },
          Paused(): {
            Start(): Running(),
            Reset(): Initiated(),
            UpdateDisplay(): Paused(),
          },
          Finished(): {
            Reset(): Initiated(),
            UpdateDisplay(): Finished(),
          }
        },
        context: context);
  }
}
