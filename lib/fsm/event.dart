// Finite State Machine
// based on https://github.com/SandroMaglione/dart-state-chart
import 'package:workout_tracker/fsm/state.dart';

typedef EventAction<C, S extends MachineState> = C Function(C ctx, S prevState, S nextState)?;

abstract class Event<C, S extends MachineState> {
  final EventAction<C, S> action;
  final String name;

  const Event({required this.name, this.action});
}
