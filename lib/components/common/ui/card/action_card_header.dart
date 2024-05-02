import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ActionCardHeader extends ConsumerWidget {
  const ActionCardHeader({
    super.key,
    required this.title,
    required this.workoutRecordId,
    required this.textStyle,
    required this.swapEnabled,
    this.actions,
  });

  final int workoutRecordId;
  final TextTheme textStyle;
  final bool swapEnabled;
  final List<Widget>? actions;
  final String title;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(title,
                    style: textStyle.titleMedium?.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onSecondaryContainer)),
              ]),
          const SizedBox(height: 8),
          ...(actions != null
              ? [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: actions!,
                  )
                ]
              : []),
        ],
      ),
    );
  }
}
