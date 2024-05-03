import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:workout_tracker/controller/timer_controller.dart';
import 'package:workout_tracker/controller/user_preferences_state.dart';
import 'package:workout_tracker/timer/timer_event.dart';
import 'package:workout_tracker/utility/int_digits.dart';
import 'package:workout_tracker/utility/text_ui_utilities.dart';

class TimerSetDialog extends ConsumerStatefulWidget {
  const TimerSetDialog({
    super.key,
    required this.buttonPadding,
    required this.gridSpacing,
  });

  final double buttonPadding;
  final double gridSpacing;

  @override
  ConsumerState<TimerSetDialog> createState() => _TimerSetDialogState();
}

class _TimerSetDialogState extends ConsumerState<TimerSetDialog>
    with UserPreferencesState {
  late String setValue = '';
  late Duration setDuration;

  @override
  void initState() {
    setValue = '';
    setDuration = const Duration();

    super.initState();
  }

  addToSetValue(String appendValue) {
    setState(() {
      setValue = '$setValue$appendValue';
      setDuration = Duration(minutes: minutes(), seconds: seconds());
    });
  }

  int get remainingLength => 4 - setValue.length;
  bool get canInput => setValue.length < 4;
  int minutes() => int.parse(setValue.padLeft(4, '0').substring(0, 2));
  int seconds() => int.parse(setValue.padLeft(4, '0').substring(2, 4));

  @override
  Widget build(BuildContext context) {
    final inputStyle = Theme.of(context).textTheme.displayLarge!.copyWith(
        textBaseline: TextBaseline.alphabetic,
        color: Theme.of(context).colorScheme.outlineVariant);
    final inputStyleActive = inputStyle.copyWith(
        color: Theme.of(context).colorScheme.onSecondaryContainer);
    final labelStyle = Theme.of(context)
        .textTheme
        .labelLarge!
        .copyWith(textBaseline: TextBaseline.alphabetic);
    final textStyle = TextUiUtilities.getFilledButtonTextStyle(context, '00');
    final textSize = TextUiUtilities.getTextSize('00', textStyle);

    addDigit(digit) => FilledButton.tonal(
        onPressed: canInput
            ? () {
                addToSetValue(digit);
              }
            : null,
        child: Text(digit));

    var width = (textSize.width + widget.buttonPadding * 2) * 3 +
        2 * widget.gridSpacing;
    var height =
        width + widget.gridSpacing + textSize.width + widget.buttonPadding * 2;
    final inputHeight = TextUiUtilities.getTextSize('00', inputStyle).height;
    const spacerHeight = 24.0;

    return AlertDialog(
      title: const Text('Set Timer'),
      icon: const Icon(Icons.timer_outlined),
      actions: [
        TextButton(
            onPressed: () {
              context.pop();
            },
            child: const Text('Cancel')),
        Consumer(
          builder: (BuildContext context, WidgetRef ref, Widget? child) =>
              TextButton(
                  onPressed: () {
                    ref.read(getAllowedEventsProvider.future).then((value) {
                      if (value
                          .any((element) => element.name == Reset(duration: setDuration).name)) {
                        ref
                            .read(timerControllerProvider.notifier)
                            .handleEvent(Reset(duration: setDuration));
                        ref
                            .read(timerControllerProvider.notifier)
                            .handleEvent(Start());
                      } else {
                        ref
                            .read(timerControllerProvider.notifier)
                            .handleEvent(Start());
                      }
                    });
                    context.pop();
                  },
                  child: const Text('Start timer')),
        ),
      ],
      content: SizedBox(
        height: height + inputHeight + spacerHeight,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DurationDisplay(
              labelStyle: labelStyle,
              inputStyle: inputStyle,
              inputStyleActive: inputStyleActive,
              input: setValue,
              minutes: minutes,
              seconds: seconds,
            ),
            const SizedBox(height: spacerHeight),
            InputKeypad(
              width: width,
              height: height,
              spacing: widget.gridSpacing,
              iconSize: textSize.height * 0.75,
              addDigit: addDigit,
              delete: setValue.isNotEmpty
                  ? () {
                      setState(() {
                        setValue = setValue.substring(0, setValue.length - 1);
                      });
                    }
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

class DurationDisplay extends StatelessWidget {
  const DurationDisplay({
    super.key,
    required this.labelStyle,
    required this.inputStyleActive,
    required this.inputStyle,
    required this.input,
    required this.minutes,
    required this.seconds,
  });

  final TextStyle labelStyle;
  final TextStyle inputStyleActive;
  final TextStyle inputStyle;
  final String input;
  final int Function() minutes;
  final int Function() seconds;

  inputTextStyle(index) =>
      input.length >= index ? inputStyleActive : inputStyle;

  @override
  Widget build(BuildContext context) {
    final inputBaseline =
        TextUiUtilities.getTextBaselineDistance('00', inputStyle);
    final labelBaseline =
        TextUiUtilities.getTextBaselineDistance('00', labelStyle);
    final deltaBaseline = inputBaseline - labelBaseline;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Text('${minutes().tens()}', style: inputTextStyle(4)),
        Text('${minutes().ones()}', style: inputTextStyle(3)),
        Column(
          children: [
            SizedBox(height: deltaBaseline),
            Text('m', style: labelStyle),
          ],
        ),
        const SizedBox(width: 8),
        Text('${seconds().tens()}', style: inputTextStyle(2)),
        Text('${seconds().ones()}', style: inputTextStyle(1)),
        Column(
          children: [
            SizedBox(height: deltaBaseline),
            Text('s', style: labelStyle),
          ],
        ),
      ],
    );
  }
}

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
