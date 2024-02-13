import 'package:flutter/material.dart';

class RoundedButton extends StatelessWidget {
  final String text;
  final IconData icon;
  final double width;
  final double height;
  final double iconSize;

  const RoundedButton(this.text, this.icon,
      {this.width = 146, this.height = 32, this.iconSize = 20, super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
          child: Container(
            constraints: BoxConstraints(minWidth: width, minHeight: height),
            // width: width,
            // height: height,
            child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                      padding: const EdgeInsets.fromLTRB(8.0, 0, 0, 0),
                      child: Icon(
                        icon,
                        size: iconSize,
                      )),
                  const SizedBox(
                    width: 8,
                  ),
                  Padding(
                      padding: const EdgeInsets.fromLTRB(0, 0, 8, 0),
                      child: Text(text,
                          style: Theme.of(context).textTheme.bodyMedium))
                ]),
          )),
    );
  }
}
