import 'package:flutter/material.dart';
import 'package:workout_tracker/domain/set_entry.dart';

class SetsListView extends StatelessWidget {
  const SetsListView(this.entries, {super.key, required this.itemStyle});

  final List<SetEntry> entries;
  final TextStyle? itemStyle;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: entries.length,
      itemBuilder: (BuildContext context, int index) {
        var entry = entries[index];
        return Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              '${entry.reps.toString()} reps @ ${entries[index].weight}${entries[index].units}',
              style: itemStyle,
            ),
          ],
        );
      },
    );
  }
}
