import 'package:workout_tracker/fsm/state.dart';

class TimerContext {
  final Duration timerDuration;
  final Duration elapsedTime;
  final DateTime startedAt;
  final bool isRunning;

  TimerContext._(
      {required this.timerDuration,
      required this.elapsedTime,
      required this.startedAt,
      this.isRunning = false});

  factory TimerContext.init({required Duration duration}) {
    return TimerContext._(
        timerDuration: duration,
        elapsedTime: Duration.zero,
        startedAt: DateTime.now());
  }
  factory TimerContext._handleEvent(
      {required Duration timerDuration,
      required Duration elapsedTime,
      bool? isRunning}) {
    return TimerContext._(
        timerDuration: timerDuration,
        elapsedTime: elapsedTime,
        startedAt: DateTime.now(),
        isRunning: isRunning ?? false);
  }

  String getDisplay() {
    final duration = timerDuration -
        elapsedTime -
        (isRunning ? DateTime.now().difference(startedAt) : Duration.zero);
    final hours = duration.inHours.toString().padLeft(2, '0');
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');

    return '${hours == "00" ? "" : "$hours:"}$minutes:$seconds';
  }

  TimerContext copyWith(
      {Duration? timerDuration,
      Duration? elapsedTime,
      DateTime? startedAt,
      String? display,
      bool? isRunning}) {
    return TimerContext._(
        timerDuration: timerDuration ?? this.timerDuration,
        elapsedTime: elapsedTime ?? this.elapsedTime,
        startedAt: startedAt ?? this.startedAt,
        isRunning: isRunning ?? this.isRunning);
  }
}

sealed class TimerState extends State<TimerContext> {
  TimerState({required super.name});
}

class Initiated extends TimerState {
  Initiated() : super(name: 'initiated');

  @override
  StateAction<TimerContext>? get onEntry =>
      (prev) => TimerContext?._handleEvent(
          timerDuration: prev.timerDuration, elapsedTime: Duration.zero);

  (String,) _equality() => (name,);

  @override
  operator ==(covariant State<TimerContext> other) {
    return other is Initiated;
  }

  @override
  int get hashCode => _equality().hashCode;
}

class Running extends TimerState {
  Running() : super(name: 'running');

  @override
  StateAction<TimerContext>? get onEntry => (prev) => TimerContext._handleEvent(
      timerDuration: prev.timerDuration,
      elapsedTime: prev.elapsedTime,
      isRunning: true);

  @override
  StateAction<TimerContext>? get onExit => (prev) => TimerContext._handleEvent(
      timerDuration: prev.timerDuration,
      elapsedTime:
          prev.elapsedTime + DateTime.now().difference(prev.startedAt));

  (String,) _equality() => (name,);

  @override
  operator ==(covariant State<TimerContext> other) {
    return other is Running;
  }

  @override
  int get hashCode => _equality().hashCode;
}

class Paused extends TimerState {
  Paused() : super(name: 'paused');

  @override
  StateAction<TimerContext>? get onEntry => (prev) => TimerContext._handleEvent(
      timerDuration: prev.timerDuration,
      elapsedTime:
          prev.elapsedTime + DateTime.now().difference(prev.startedAt));

  (String,) _equality() => (name,);

  @override
  operator ==(covariant State<TimerContext> other) {
    return other is Paused;
  }

  @override
  int get hashCode => _equality().hashCode;
}

class Finished extends TimerState {
  Finished() : super(name: 'finished');

  (String,) _equality() => (name,);

  @override
  operator ==(covariant State<TimerContext> other) {
    return other is Finished;
  }

  @override
  int get hashCode => _equality().hashCode;
}
