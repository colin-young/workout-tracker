// Finite State Machine
// based on https://github.com/SandroMaglione/dart-state-chart
typedef MachineStateAction<C> = C? Function(C ctx)?;

abstract class MachineState<C> {
  final String name;

  const MachineState({required this.name, this.onEntry, this.onExit});

  final MachineStateAction<C> onEntry;
  final MachineStateAction<C> onExit;
}
