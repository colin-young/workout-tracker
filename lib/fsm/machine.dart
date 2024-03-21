// Finite State Machine
// based on https://github.com/SandroMaglione/dart-state-chart
import 'dart:async';

import 'package:workout_tracker/fsm/event.dart';
import 'package:workout_tracker/fsm/state.dart';
// import 'dart:developer' as developer;

abstract class Machine<C, S extends State<C>, E extends Event> {
  Machine({required this.state, required this.events, required this.context});

  final _stateController = StreamController<S>.broadcast();
  Stream<S> get streamState => _stateController.stream;
  final _contextController = StreamController<C>.broadcast();
  Stream<C> get streamContext => _contextController.stream;

  final Map<S, Map<E, S>> events;
  S state;
  C context;

  Future<void> close() async {
    await Future.wait([
      _stateController.close(),
      _contextController.close()
    ]);
  }

  List<E> allowedEvents() {
    var list = events[state]?.keys.map((e) => e).toList() ?? [];

    return list;
  }

  void handleEvent(E event) {
    if (_stateController.isClosed) {
      throw StateError('Cannot emit new states after calling close');
    }

    final nextState = events[state]?[event];

    if (nextState == null) return;

    /// Apply `exit` action for previous state
    final exitContext = state.onExit?.call(context) ?? context;
    context = exitContext;

    /// Apply `event` action
    final action = event.action;
    final actionContext =
        action != null ? (action(context, state, nextState) ?? context) : context;
    context = actionContext;

    /// Apply `entry` action for upcoming state
    final entryContext = nextState.onEntry?.call(context) ?? context;
    context = entryContext;

    _stateController.add(nextState);
    _contextController.add(exitContext);
    state = nextState;
  }
}
