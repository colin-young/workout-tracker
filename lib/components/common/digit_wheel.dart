import 'package:flutter/material.dart';
import 'package:wheel_picker/wheel_picker.dart';

class DigitWheel extends StatelessWidget {
  const DigitWheel({
    super.key,
    required this.textStyle,
    required this.wheelController,
    required this.updateReps,
  });

  final TextStyle? textStyle;
  final WheelPickerController wheelController;
  final void Function(int) updateReps;

  @override
  Widget build(BuildContext context) {
    return WheelPicker(
      builder: (context, index) {
        return Text("$index", style: textStyle);
      },
      controller: wheelController,
      selectedIndexColor: Theme.of(context).colorScheme.onSurface,
      onIndexChanged: (index) {
        updateReps(index);
      },
      style: WheelPickerStyle(
        size: 140,
        itemExtent: textStyle!.fontSize! * textStyle!.height!, // Text height
        squeeze: 1.25,
        diameterRatio: .8,
        surroundingOpacity: .25,
        magnification: 1.2,
      ),
    );
  }
}
