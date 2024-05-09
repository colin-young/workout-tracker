import 'package:flutter/material.dart';
import 'package:workout_tracker/components/timer/timer_set_dialog.dart';

class DurationPickerFormField extends FormField<Duration> {
  DurationPickerFormField({
    super.key,
    super.onSaved,
    super.validator,
    Duration? value,
    super.enabled,
    super.autovalidateMode,
    super.restorationId,
    required this.onChanged,
    Color? focusColor,
    InputDecoration? decoration,
    TextStyle? style,
    TextStyle? styleSub,
    bool showHours = false,
  })  : decoration = decoration ?? InputDecoration(focusColor: focusColor),
        super(
          initialValue: value,
          builder: (FormFieldState<Duration> field) {
            final InputDecoration decorationArg =
                decoration ?? InputDecoration(focusColor: focusColor);
            decorationArg.applyDefaults(
              Theme.of(field.context).inputDecorationTheme,
            );
            return Focus(
              canRequestFocus: false,
              skipTraversal: true,
              child: Builder(builder: (BuildContext context) {

                final theme = Theme.of(context);
                hours() => value?.inHours ?? 0;
                minutes() => (value?.inMinutes ?? 0) - hours() * 60;
                seconds() => (value?.inSeconds ?? 0) - minutes() * 60;
                final displayRaw =
                    '${minutes().toString().padLeft(2, '0')}${seconds().toString().padLeft(2, '0')}';

                return InputDecorator(
                  decoration: decoration!,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      DurationDisplay(
                        labelStyle: styleSub?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5)),
                        inputStyle: style?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5)),
                        inputActiveColor: enabled
                            ? theme.colorScheme.onSurfaceVariant
                            : theme.colorScheme.onSurfaceVariant.withOpacity(0.25),
                        input: displayRaw,
                        hours: hours,
                        minutes: minutes,
                        seconds: seconds,
                      ),
                      TextButton(
                          onPressed: enabled
                              ? () {
                                  if (onChanged != null) {
                                    showDialog(
                                        context: context,
                                        builder: (context) {
                                          return TimerSetDialog(
                                            title: 'Enter duration',
                                            saveLabel: 'Update default',
                                            showHours: showHours,
                                            onSave: (duration) {
                                              onChanged(duration);

                                              value = duration;
                                            },
                                          );
                                        });
                                  }
                                }
                              : null,
                          child: const Text('Edit'))
                    ],
                  ),
                );
              }),
            );
          },
        );

  final ValueChanged<Duration?>? onChanged;
  final InputDecoration decoration;

  @override
  FormFieldState<Duration> createState() => _DurationPickerFormFieldState();
}

class _DurationPickerFormFieldState extends FormFieldState<Duration> {
  DurationPickerFormField get _durationPickerFormField =>
      widget as DurationPickerFormField;
  @override
  void didChange(Duration? value) {
    super.didChange(value);
    _durationPickerFormField.onChanged?.call(value);
  }

  @override
  void didUpdateWidget(DurationPickerFormField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialValue != widget.initialValue) {
      setValue(widget.initialValue);
    }
  }

  @override
  void reset() {
    super.reset();
    _durationPickerFormField.onChanged?.call(value);
  }
}
