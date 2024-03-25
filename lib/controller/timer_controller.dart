import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:workout_tracker/fsm/event.dart';
import 'package:workout_tracker/timer/timer_context.dart';
import 'package:workout_tracker/timer/timer_event.dart';
import 'package:workout_tracker/timer/timer_machine.dart';

part 'timer_controller.g.dart';

@Riverpod(keepAlive: true)
class TimerController extends _$TimerController {
  @override
  Future<void> build() async {
    final timerMachine = ref.watch(getTimerProvider.future);
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => timerMachine);
    // return timerMachine;
  }

  Future<void> handleEvent(TimerEvent event) async {
    state = const AsyncLoading();

    final timerMachine = await ref.watch(getTimerProvider.future);

    state = await AsyncValue.guard(() async {
      timerMachine.handleEvent(event);
    });
  }
}

@Riverpod(keepAlive: true)
Future<TimerMachine> getTimer(GetTimerRef ref) async {
  return TimerMachine.create(
      context:
          // TODO Read default timer duration from UserPrefs.
          TimerContext.init(duration: const Duration(minutes: 0, seconds: 5)));
}

@Riverpod(keepAlive: true)
Stream<TimerState> getState(GetStateRef ref) async* {
  final timer = await ref.watch(getTimerProvider.future);

  yield Initiated();

  await for (final state in timer.streamState) {
    yield state;
  }
}

@Riverpod(keepAlive: true)
Stream<TimerContext> getContext(GetContextRef ref) async* {
  final timer = await ref.watch(getTimerProvider.future);

  yield TimerContext.init(duration: Duration.zero);

  await for (final context in timer.streamContext) {
    yield context;
  }
}

@Riverpod(keepAlive: true)
Stream<List<Event>> getAllowedEvents(GetAllowedEventsRef ref) async* {
  final timer = await ref.watch(getTimerProvider.future);

  yield timer.allowedEvents();

  await for (final _ in timer.streamState) {
    yield timer.allowedEvents();
  }
}
