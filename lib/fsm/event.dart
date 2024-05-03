// Finite State Machine
// based on https://github.com/SandroMaglione/dart-state-chart
import 'package:workout_tracker/fsm/state.dart';

typedef EventAction<C> = C Function(C ctx)?;

abstract class Event<C, S extends MachineState> {
  final EventAction<C> action;
  final String name;
  final bool includeInStream;

  Event({required this.name, this.action, this.includeInStream = false});
}
