import 'package:flutter/material.dart';

class RoundedDisplay extends StatelessWidget {
  final Widget child;
  final double width;
  final double height;
  final Color background;

  const RoundedDisplay(
      {required this.child,
      this.width = 80,
      this.height = 26,
      required this.background,
      super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(4),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(height)),
          color: background,
        ),
        constraints: BoxConstraints(minWidth: width, minHeight: height),
        child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [child]),
      ),
    );
  }
}
