import 'package:flutter/material.dart';

class TextUiUtilities {
  static Size getTextSize(
      BuildContext context, String text, TextStyle inputStyle) {
    final defaultStyle = DefaultTextStyle.of(context).style;

    final style = inputStyle.merge(defaultStyle).copyWith(
          height: defaultStyle.height,
          letterSpacing: defaultStyle.letterSpacing ?? 0.0,
        );

    final TextPainter textPainter = TextPainter(
        text: TextSpan(text: text, style: style),
        maxLines: 1,
        textDirection: TextDirection.ltr)
      ..layout(minWidth: 0, maxWidth: double.infinity);
    var size = textPainter.size;
    textPainter.dispose();

    return size;
  }

  static double getTextBaselineDistance(String text, TextStyle style) {
    final TextPainter textPainter = TextPainter(
        text: TextSpan(text: text, style: style),
        maxLines: 1,
        textDirection: TextDirection.ltr)
      ..layout(minWidth: 0, maxWidth: double.infinity);

    return textPainter.computeDistanceToActualBaseline(TextBaseline.alphabetic);
  }

  static getFilledButtonTextStyle(BuildContext context, String testString) {
    final theme = Theme.of(context).filledButtonTheme;
    final dummyButton = FilledButton(
      onPressed: () {},
      child: Text(testString),
    );
    final textStyle = (theme.style ?? dummyButton.defaultStyleOf(context))
            .textStyle
            ?.resolve(WidgetState.focused as Set<WidgetState>) ??
        Theme.of(context).textTheme.labelLarge!;

    return textStyle;
  }
}
