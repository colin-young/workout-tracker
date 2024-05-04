import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:workout_tracker/domain/exercise.dart';
import 'package:workout_tracker/utility/text_ui_utilities.dart';

class ExerciseSettingsDisplay extends StatelessWidget {
  const ExerciseSettingsDisplay({
    super.key,
    required this.entry,
    this.addFunc,
  });

  final Exercise entry;
  final void Function()? addFunc;

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    final chipTheme = theme.chipTheme;
    final chipLabel = chipTheme.labelStyle ?? theme.textTheme.labelLarge ?? theme.textTheme.bodyLarge!;
    final chipIconSize = chipTheme.iconTheme?.size ?? 4;

    final textWidth = entry.settings.fold(
        TextUiUtilities.getTextSize('add', chipLabel).width + chipIconSize,
        (prev, curr) {
      final size = TextUiUtilities.getTextSize(
              '${curr.setting} | ${curr.value}', chipLabel)
          .width;
      return size > prev ? size : prev;
    });

    return ChipTheme(
      data: ChipTheme.of(context).copyWith(),
      child: Wrap(
        alignment: WrapAlignment.spaceAround,
        runAlignment: WrapAlignment.spaceAround,
        runSpacing: 4.0,
        children: [
          ...(addFunc != null
              ? [
                  ActionChip(
                    avatar: SizedBox(
                      width: chipIconSize,
                      height: chipIconSize,
                      child: const Icon(
                        Icons.add,
                      ),
                    ),
                    label: SizedBox(
                      width: clampDouble(
                          textWidth - chipIconSize, 0.0, double.infinity),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [Text('add')],
                      ),
                    ),
                    onPressed: addFunc,
                  )
                ]
              : []),
          for (var item in entry.settings)
            Chip(
              label: SizedBox(
                  width: textWidth,
                  child:
                      Center(child: Text('${item.setting} | ${item.value}'))),
              visualDensity: VisualDensity.compact,
            )
        ],
      ),
    );
  }
}
