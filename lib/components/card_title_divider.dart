import 'package:flutter/material.dart';

class CardTitleDivider extends StatelessWidget {
  const CardTitleDivider({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        SizedBox(
            width: 10,
            child:
                Column(mainAxisSize: MainAxisSize.min, children: [
              Divider(
                thickness: 1,
                indent: 0,
                endIndent: 5,
                color: Theme.of(context).colorScheme.primary,
              )
            ])),
        child,
        Expanded(
            child:
                Column(mainAxisSize: MainAxisSize.max, children: [
          Divider(
            thickness: 1,
            indent: 5,
            endIndent: 0,
            color: Theme.of(context).colorScheme.primary,
          )
        ])),
      ],
    );
  }
}
