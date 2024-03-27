import 'dart:async';
import 'package:workout_tracker/timer/timer_event.dart';
import 'package:workout_tracker/timer/timer_context.dart';
import 'package:workout_tracker/fsm/machine.dart';
import 'dart:developer' as developer;

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
    developer.log('event: ${event.name}', name: 'TimerMachine.handleEvent');
    super.handleEvent(event);

    if (state == Running()) {
      if (event == UpdateDisplay()) {
        if (context.elapsedTime >= context.timerDuration) {
          if (_timer != null) {
            _timer?.cancel();
          }
          super.handleEvent(Finish());
          super.handleEvent(Reset());
        }
      } else {
        if (_timer != null) {
          _timer?.cancel();
        }

        _timer = Timer.periodic(const Duration(seconds: 1), (_) {
          handleEvent(UpdateDisplay());
        });
      }
    } else {
      _timer?.cancel();
    }

    // super.handleEvent(UpdateDisplay());
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
