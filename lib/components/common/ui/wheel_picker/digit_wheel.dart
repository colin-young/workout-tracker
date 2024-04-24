import 'package:flutter/material.dart';
import 'package:wheel_picker/wheel_picker.dart';

class DigitWheel extends StatefulWidget {
  const DigitWheel({
    super.key,
    required this.value,
    required this.textStyle,
    required this.updateSelectedValue,
  });

  final int value;
  final TextStyle? textStyle;
  final void Function(int) updateSelectedValue;

  @override
  State<StatefulWidget> createState() => _DigitWheelState();
}

class _DigitWheelState extends State<DigitWheel> {
  late int _value = widget.value;
  late final textStyle = widget.textStyle;
  late final void Function(int) updateSelectedValue =
      widget.updateSelectedValue;
  late final WheelPickerController wheelController =
      WheelPickerController(itemCount: 10, initialIndex: widget.value);

  @override
  void dispose() {
    wheelController.dispose();

    super.dispose();
  }

  @override
  void initState() {
    wheelController.shiftBy(steps: _value);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Card(
      clipBehavior: Clip.antiAlias,
      color: colors.secondaryContainer.withOpacity(0.5),
      elevation: 0,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(6))),
      child: WheelPicker(
        builder: (context, index) {
          return Text("$index", style: textStyle);
        },
        controller: wheelController,
        selectedIndexColor: Theme.of(context).colorScheme.onSurface,
        onIndexChanged: (index) {
          setState(() {
            _value = index;
          });
          updateSelectedValue(index);
        },
        style: WheelPickerStyle(
            size: 140,
            itemExtent:
                textStyle!.fontSize! * textStyle!.height!, // Text height
            squeeze: 1.25,
            diameterRatio: 1,
            surroundingOpacity: 0.5,
            magnification: 1.2,
            shiftAnimationStyle: const WheelShiftAnimationStyle(
                duration: Duration(milliseconds: 300),
                curve: Easing.standard)),
      ),
    );
  }
}
