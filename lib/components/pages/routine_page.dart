import 'package:flutter/material.dart';
import 'package:workout_tracker/components/common/custom_scaffold.dart';
import 'package:workout_tracker/components/pages/routine/routine_manager.dart';

class RoutinePage extends StatefulWidget {
  const RoutinePage({super.key});

  @override
  State<RoutinePage> createState() => _RoutinePageState();
}

class _RoutinePageState extends State<RoutinePage> {
  late bool addNew;

  @override
  void initState() {
    addNew = false;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      title: const Text('Routines'),
      body: RoutineManager(
        newRoutine: addNew,
        onSave: () {
          setState(() {
            addNew = false;
          });
        },
        onCancel: () {
          setState(() {
            addNew = false;
          });
        },
      ),
      floatingActionButton: addNew
          ? null
          : FloatingActionButton.extended(
              onPressed: addNew
                  ? null
                  : () {
                      setState(() {
                        addNew = true;
                      });
                    },
              label: const Text('New routine'),
              icon: const Icon(Icons.add),
            ),
    );
  }
}
