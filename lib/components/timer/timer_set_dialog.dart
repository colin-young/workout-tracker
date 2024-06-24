import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:workout_tracker/components/timer/duration_display.dart';
import 'package:workout_tracker/components/timer/input_keypad.dart';
import 'package:workout_tracker/data/timer_controller.dart';
import 'package:workout_tracker/data/user_preferences_state.dart';
import 'package:workout_tracker/components/timer/timer_event.dart';
import 'package:workout_tracker/utility/constants.dart';
import 'package:workout_tracker/utility/text_ui_utilities.dart';

class TimerSetDialog extends ConsumerStatefulWidget {
  const TimerSetDialog({
    super.key,
    this.buttonPadding = 24.0,
    this.gridSpacing = 4.0,
    this.onSave,
    this.saveLabel,
    this.showHours = false,
    required this.title,
  });

  final double buttonPadding;
  final double gridSpacing;
  final Function(Duration)? onSave;
  final String? saveLabel;
  final bool showHours;
  final String title;

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
      setDuration =
          Duration(hours: hours(), minutes: minutes(), seconds: seconds());
    });
  }

  int get remainingLength => 4 - setValue.length;
  bool get canInput => setValue.length < 4;
  int hours() => widget.showHours
      ? int.parse(setValue.padLeft(4, '0').substring(0, 2))
      : 0;
  int minutes() => widget.showHours
      ? int.parse(setValue.padLeft(4, '0').substring(2, 4))
      : int.parse(setValue.padLeft(4, '0').substring(0, 2));
  int seconds() => widget.showHours
      ? 0
      : int.parse(setValue.padLeft(4, '0').substring(2, 4));

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
    final textSize = TextUiUtilities.getTextSize(context, '00', textStyle);

    addDigit(digit) => FilledButton.tonal(
        onPressed: canInput &&
                (int.parse(digit) > 0 || setValue.isNotEmpty) &&
                (digit.length <= 4 - setValue.length)
            ? () {
                addToSetValue(digit);
              }
            : null,
        child: Text(digit));

    var width = (textSize.width + widget.buttonPadding * 2) * 3 +
        2 * widget.gridSpacing;
    var height =
        width + widget.gridSpacing + textSize.width + widget.buttonPadding * 2;
    final inputHeight = TextUiUtilities.getTextSize(context, '00', inputStyle).height;
    const spacerHeight = 24.0;

    return AlertDialog.adaptive(
      title: Text(widget.title),
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
                  onPressed: setValue.isNotEmpty
                      ? widget.onSave != null
                          ? () {
                              widget.onSave!(setDuration);
                              context.pop();
                            }
                          : () {
                              ref
                                  .read(timerControllerProvider.notifier)
                                  .handleEvent(Reset(duration: setDuration));
                              ref
                                  .read(timerControllerProvider.notifier)
                                  .handleEvent(Start());
                              context.pop();
                            }
                      : null,
                  child: Text(widget.saveLabel ?? 'Start timer')),
        ),
      ],
      content: Padding(
        padding: const EdgeInsets.only(bottom: Constants.rowSpacing),
        child: SizedBox(
          height: height + inputHeight + spacerHeight,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DurationDisplay(
                labelStyle: labelStyle,
                inputStyle: inputStyle,
                input: setValue,
                hours: hours,
                minutes: minutes,
                seconds: seconds,
                showHours: widget.showHours,
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
      ),
    );
  }
}
