import 'package:flutter/material.dart';

class TextUiUtilities {
  static Size getTextSize(String text, TextStyle style) {
    final TextPainter textPainter = TextPainter(
        text: TextSpan(text: text, style: style),
        maxLines: 1,
        textDirection: TextDirection.ltr)
      ..layout(minWidth: 0, maxWidth: double.infinity);
    return textPainter.size;
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
            ?.resolve(MaterialState.focused as Set<MaterialState>) ??
        Theme.of(context).textTheme.labelLarge!;

    return textStyle;
  }
}
