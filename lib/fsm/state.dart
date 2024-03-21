// Finite State Machine
// based on https://github.com/SandroMaglione/dart-state-chart
typedef StateAction<Context> = Context? Function(Context ctx)?;

abstract class State<Context> {
  final String name;

  const State({required this.name, this.onEntry, this.onExit});

  final StateAction<Context> onEntry;
  final StateAction<Context> onExit;
}
