import 'package:flutter/material.dart';

class CardTitleDivider extends StatelessWidget {
  const CardTitleDivider({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    const thickness = 1.5;
    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        const SizedBox(
            width: 16,
            child:
                Column(mainAxisSize: MainAxisSize.min, children: [
              Divider(
                thickness: thickness,
                indent: 0,
                endIndent: 5,
              )
            ])),
        child,
        const Expanded(
            child:
                Column(mainAxisSize: MainAxisSize.max, children: [
          Divider(
            thickness: thickness,
            indent: 5,
            endIndent: 0,
          )
        ])),
      ],
    );
  }
}
