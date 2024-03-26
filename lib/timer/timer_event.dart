import 'package:workout_tracker/fsm/event.dart';
import 'package:workout_tracker/timer/timer_context.dart';

sealed class TimerEvent extends Event<TimerContext, TimerState> {
  TimerEvent({required super.name, super.includeInStream});
}

class Start extends TimerEvent {
  Start() : super(name: 'start');

  (String,) _equality() => (name,);

  @override
  operator ==(covariant Event other) {
    return other is Start;
  }

  @override
  int get hashCode => _equality().hashCode;
}

class Pause extends TimerEvent {
  Pause() : super(name: 'pause');

  (String,) _equality() => (name,);

  @override
  operator ==(covariant Event other) {
    return other is Pause;
  }

  @override
  int get hashCode => _equality().hashCode;
}

class Reset extends TimerEvent {
  Reset() : super(name: 'reset');

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
