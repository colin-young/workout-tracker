import 'package:workout_tracker/fsm/event.dart';
import 'package:workout_tracker/components/timer/timer_context.dart';

sealed class TimerEvent extends Event<TimerContext, TimerState> {
  TimerEvent({required super.name, super.includeInStream, super.action});
}

class Start extends TimerEvent {
  Start() : super(name: 'start', includeInStream: true);

  (String,) _equality() => (name,);

  @override
  operator ==(covariant Event other) {
    return other is Start;
  }

  @override
  int get hashCode => _equality().hashCode;
}

class Pause extends TimerEvent {
  Pause() : super(name: 'pause', includeInStream: true);

  (String,) _equality() => (name,);

  @override
  operator ==(covariant Event other) {
    return other is Pause;
  }

  @override
  int get hashCode => _equality().hashCode;
}

class Reset extends TimerEvent {
  Reset({Duration? duration})
      : super(
            name: 'reset',
            includeInStream: true,
            action: (dynamic context) =>
                context.copyWith(timerDuration: duration));

  (String,) _equality() => (name,);

  @override
  operator ==(covariant Event other) {
    return other is Reset;
  }

  @override
  int get hashCode => _equality().hashCode;
}

class Finish extends TimerEvent {
  Finish() : super(name: 'finish', includeInStream: true);

  (String,) _equality() => (name,);

  @override
  operator ==(covariant Event other) {
    return other is Finish;
  }

  @override
  int get hashCode => _equality().hashCode;
}

class UpdateDisplay extends TimerEvent {
  UpdateDisplay() : super(name: 'update-display');

  (String,) _equality() => (name,);

  @override
  operator ==(covariant Event other) {
    return other is UpdateDisplay;
  }

  @override
  int get hashCode => _equality().hashCode;
}
