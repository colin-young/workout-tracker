typedef StateAction<Context> = Context? Function(Context ctx)?;

abstract class State<Context> {
  final String name;

  const State({required this.name, this.onEntry, this.onExit});

  final StateAction<Context> onEntry;
  final StateAction<Context> onExit;
}
