import 'package:flutter/material.dart';
import 'package:wheel_picker/wheel_picker.dart';
import 'package:workout_tracker/components/common/ui/wheel_picker/digit_wheel.dart';
import 'package:workout_tracker/utility/int_digits.dart';

class MultiDigitWheel extends StatefulWidget {
  final void Function(int) updateOnes;
  final void Function(int)? updateTens;
  final void Function(int)? updateHundreds;
  final int value;
  final String suffix;

  const MultiDigitWheel(
      {super.key,
      required this.value,
      required this.updateOnes,
      this.updateTens,
      this.updateHundreds,
      required this.suffix});

  @override
  State<MultiDigitWheel> createState() => _MultiDigitWheelState();
}

class _MultiDigitWheelState extends State<MultiDigitWheel> {
  late final hundredsWheelPicker = WheelPickerController(
    itemCount: 10,
    initialIndex: widget.value.hundreds(),
  );
  late final tensWheelPicker = WheelPickerController(
    itemCount: 10,
    initialIndex: widget.value.tens(),
    mounts: [hundredsWheelPicker],
  );
  late final onesWheelPicker = WheelPickerController(
    itemCount: 10,
    initialIndex: widget.value.ones(),
    mounts: [tensWheelPicker],
  );

  @override
  void dispose() {
    hundredsWheelPicker.dispose();
    tensWheelPicker.dispose();
    onesWheelPicker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var textStyle = Theme.of(context).textTheme;
    var textTitle = textStyle.titleLarge;

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Expanded(
          flex: 1,
          child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
            widget.updateHundreds != null
                ? DigitWheel(
                    key: ValueKey('${widget.key}100s'),
                    value: widget.value.hundreds(),
                    textStyle: textTitle,
                    updateSelectedValue: widget.updateHundreds!,
                    wheelPickerController: hundredsWheelPicker,
                  )
                : Container(),
            widget.updateHundreds != null
                ? const SizedBox(
                    width: 4,
                  )
                : Container(),
            widget.updateTens != null
                ? DigitWheel(
                    key: ValueKey('${widget.key}10s'),
                    value: widget.value.tens(),
                    textStyle: textTitle,
                    updateSelectedValue: widget.updateTens!,
                    wheelPickerController: tensWheelPicker,
                  )
                : Container(),
            widget.updateTens != null
                ? const SizedBox(
                    width: 4,
                  )
                : Container(),
            DigitWheel(
              key: ValueKey('${widget.key}1s'),
              value: widget.value.ones(),
              textStyle: textTitle,
              updateSelectedValue: widget.updateOnes,
              wheelPickerController: onesWheelPicker,
            ),
          ]),
        ),
        const SizedBox(
          width: 8,
        ),
        Expanded(
          flex: 1,
          child: Text(
            widget.suffix,
            style: textTitle,
          ),
        )
      ],
    );
  }
}
