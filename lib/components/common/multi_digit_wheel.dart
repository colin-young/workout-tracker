import 'package:flutter/material.dart';
import 'package:workout_tracker/components/common/digit_wheel.dart';
import 'package:workout_tracker/utility/int_digits.dart';

class MultiDigitWheel extends StatelessWidget {
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
            updateHundreds != null
                ? DigitWheel(
                    value: value.hundreds(),
                    textStyle: textTitle,
                    updateSelectedValue: updateHundreds!,
                  )
                : Container(),
            updateHundreds != null
                ? const SizedBox(
                    width: 16,
                  )
                : Container(),
            updateTens != null
                ? DigitWheel(
                    value: value.tens(),
                    textStyle: textTitle,
                    updateSelectedValue: updateTens!,
                  )
                : Container(),
            updateTens != null
                ? const SizedBox(
                    width: 16,
                  )
                : Container(),
            DigitWheel(
              value: value.ones(),
              textStyle: textTitle,
              updateSelectedValue: updateOnes,
            ),
          ]),
        ),
        Expanded(
          flex: 1,
          child: Text(
            suffix,
            style: textTitle,
          ),
        )
      ],
    );
  }
}
