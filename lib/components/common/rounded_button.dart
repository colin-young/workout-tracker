import 'package:flutter/material.dart';

class RoundedButton extends StatelessWidget {
  final Widget text;
  final IconData icon;
  final double width;
  final double height;
  final double iconSize;
  final VoidCallback onPressed;

  const RoundedButton({required this.text, required this.icon,
      this.width = 120, this.height = 32, this.iconSize = 20, required this.onPressed, super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(4),
      child: ElevatedButton(
        onPressed: onPressed,
        child: Container(
          constraints: BoxConstraints(minWidth: width, minHeight: height),
          child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  size: iconSize,
                ),
                const SizedBox(
                  width: 8,
                ),
                text
              ]),
        ),
      ),
    );
  }
}
