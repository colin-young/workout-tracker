import 'package:flutter/material.dart';

class InputKeypad extends StatelessWidget {
  const InputKeypad({
    super.key,
    required this.width,
    required this.height,
    required this.spacing,
    required this.iconSize,
    required this.addDigit,
    required this.delete,
  });

  final double width;
  final double height;
  final double spacing;
  final Function addDigit;
  final void Function()? delete;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: GridView.count(
        mainAxisSpacing: spacing,
        crossAxisSpacing: 4,
        shrinkWrap: true,
        crossAxisCount: 3,
        children: [
          addDigit('7'),
          addDigit('8'),
          addDigit('9'),
          addDigit('4'),
          addDigit('5'),
          addDigit('6'),
          addDigit('1'),
          addDigit('2'),
          addDigit('3'),
          addDigit('00'),
          addDigit('0'),
          FilledButton.tonal(
            onPressed: delete,
            child: Center(
                child: Icon(
              Icons.backspace_outlined,
              size: iconSize,
            )),
          )
        ],
      ),
    );
  }
}
