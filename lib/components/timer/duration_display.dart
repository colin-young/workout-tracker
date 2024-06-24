import 'package:flutter/material.dart';
import 'package:workout_tracker/utility/int_digits.dart';
import 'package:workout_tracker/utility/text_ui_utilities.dart';

class DurationDisplay extends StatelessWidget {
  const DurationDisplay({
    super.key,
    this.labelStyle,
    this.inputActiveColor,
    this.inputStyle,
    required this.input,
    required this.hours,
    required this.minutes,
    required this.seconds,
    this.showHours = false,
  });

  final TextStyle? labelStyle;
  final Color? inputActiveColor;
  final TextStyle? inputStyle;
  final String input;
  final int Function() hours;
  final int Function() minutes;
  final int Function() seconds;
  final bool showHours;

  @override
  Widget build(BuildContext context) {
    TextStyle getInputStyleForState(TextStyle style) {
      final ThemeData theme = Theme.of(context);
      final TextStyle stateStyle = WidgetStateProperty.resolveAs(
          theme.useMaterial3
              ? _m3StateInputStyle(context)!
              : _m2StateInputStyle(context)!,
          <WidgetState>{WidgetState.focused});
      final TextStyle providedStyle = WidgetStateProperty.resolveAs(
          style, <WidgetState>{WidgetState.focused});
      return providedStyle.merge(stateStyle);
    }

    final ThemeData theme = Theme.of(context);
    final TextStyle? providedStyleSub = WidgetStateProperty.resolveAs(
        labelStyle, <WidgetState>{WidgetState.focused});
    final TextStyle styleSub = getInputStyleForState(theme.useMaterial3
            ? _m3InputStyle(context)
            : theme.textTheme.labelSmall!)
        .merge(providedStyleSub);

    final TextStyle? providedStyle = WidgetStateProperty.resolveAs(
        inputStyle, <WidgetState>{WidgetState.focused});
    final TextStyle style = getInputStyleForState(theme.useMaterial3
            ? _m3InputStyle(context)
            : theme.textTheme.labelSmall!)
        .merge(providedStyle);
    final styleActive =
        style.copyWith(color: inputActiveColor ?? theme.colorScheme.primary);

    inputTextStyle(index) => input.length >= index ? styleActive : style;

    final inputBaseline = TextUiUtilities.getTextBaselineDistance('00', style);
    final labelBaseline =
        TextUiUtilities.getTextBaselineDistance('00', styleSub);
    final deltaBaseline = inputBaseline - labelBaseline;

    var showHourValue = hours() > 0 || showHours;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      textBaseline: TextBaseline.alphabetic,
      children: [
        ...showHourValue
            ? [
                Text('${hours().tens()}', style: inputTextStyle(4)),
                Text('${hours().ones()}', style: inputTextStyle(3)),
              ]
            : [
                Text('${minutes().tens()}', style: inputTextStyle(4)),
                Text('${minutes().ones()}', style: inputTextStyle(3)),
              ],
        Column(
          children: [
            SizedBox(height: deltaBaseline),
            Text(showHourValue ? 'h' : 'm', style: styleSub),
          ],
        ),
        const SizedBox(width: 8),
        ...showHourValue
            ? [
                Text('${minutes().tens()}', style: inputTextStyle(2)),
                Text('${minutes().ones()}', style: inputTextStyle(1)),
              ]
            : [
                Text('${seconds().tens()}', style: inputTextStyle(2)),
                Text('${seconds().ones()}', style: inputTextStyle(1)),
              ],
        Column(
          children: [
            SizedBox(height: deltaBaseline),
            Text(showHourValue ? 'm' : 's', style: styleSub),
          ],
        ),
      ],
    );
  }

  TextStyle? _m2StateInputStyle(BuildContext context) =>
      WidgetStateTextStyle.resolveWith((Set<WidgetState> states) {
        final ThemeData theme = Theme.of(context);
        if (states.contains(WidgetState.disabled)) {
          return TextStyle(color: theme.disabledColor);
        }
        return TextStyle(color: theme.textTheme.titleMedium?.color);
      });

  TextStyle? _m3StateInputStyle(BuildContext context) =>
      WidgetStateTextStyle.resolveWith((Set<WidgetState> states) {
        if (states.contains(WidgetState.disabled)) {
          return TextStyle(
              color: Theme.of(context)
                  .textTheme
                  .bodyLarge!
                  .color
                  ?.withOpacity(0.38));
        }
        return TextStyle(color: Theme.of(context).textTheme.bodyLarge!.color);
      });

  TextStyle _m3InputStyle(BuildContext context) =>
      Theme.of(context).textTheme.bodyLarge!;
}
