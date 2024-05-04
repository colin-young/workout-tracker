import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:workout_tracker/fsm/event.dart';
import 'package:workout_tracker/fsm/state.dart';
import 'package:workout_tracker/timer/timer_context.dart';
import 'package:workout_tracker/timer/timer_event.dart';
import 'package:workout_tracker/timer/timer_machine.dart';

part 'timer_controller.g.dart';

@riverpod
class TimerController extends _$TimerController {
  @override
  Future<void> build() async {
    final timerMachine = ref.watch(getTimerProvider().future);
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => timerMachine);
  }

  Future<void> handleEvent(TimerEvent event) async {
    state = const AsyncLoading();

    final timerMachine = await ref.watch(getTimerProvider().future);

    state = await AsyncValue.guard(() async {
      timerMachine.handleEvent(event);
    });
  }
}

@riverpod
Future<TimerMachine> getTimer(GetTimerRef ref, {Duration timerDuration = Duration.zero}) async {
  return TimerMachine.create(
      context:
          TimerContext.init(duration: timerDuration));
}

@riverpod
Stream<TimerState> getTimerState(GetTimerStateRef ref) async* {
  final timer = await ref.watch(getTimerProvider().future);

  yield Initiated();

  await for (final state in timer.streamState) {
    yield state;
  }
}

@riverpod
Stream<TimerContext> getTimerContext(GetTimerContextRef ref) async* {
  final timer = await ref.watch(getTimerProvider().future);

  yield TimerContext.init(duration: Duration.zero);

  await for (final context in timer.streamContext) {
    yield context;
  }
}

@riverpod
Stream<List<Event>> getAllowedEvents(GetAllowedEventsRef ref) async* {
  final timer = await ref.watch(getTimerProvider().future);

  yield timer.allowedEvents();

  await for (final _ in timer.streamState) {
    yield timer.allowedEvents();
  }
}

@riverpod
Stream<Event> getEvents(GetEventsRef ref) async* {
  final timer = await ref.watch(getTimerProvider().future);

  await for (final event in timer.streamEvent) {
    yield event;
  }
}
