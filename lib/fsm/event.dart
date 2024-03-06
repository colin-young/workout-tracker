import 'package:workout_tracker/fsm/state.dart';

typedef EventAction<C, S extends State> = C Function(C ctx, S prevState, S nextState)?;

abstract class Event<C, S extends State> {
  final EventAction<C, S> action;
  final String name;

  const Event({required this.name, this.action});
}
