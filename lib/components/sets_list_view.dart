import 'package:flutter/material.dart';
import 'package:workout_tracker/domain/set_entry.dart';

class SetsListView extends StatelessWidget {
  const SetsListView(this.entries, {super.key, required this.itemStyle});

  final List<SetEntry> entries;
  final TextStyle? itemStyle;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: entries
            .map((e) => Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      '${e.reps.toString()} reps @ ${e.weight}${e.units}',
                      style: itemStyle,
                    ),
                  ],
                ))
            .toList(),
      ),
    );
  }
}
