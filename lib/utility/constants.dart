import 'package:flutter/material.dart';

class Constants {
  static const double dialogWidth = 0.9;
  static const double dialogHeight = 0.85;
  static const double floatingActionButtonHeight = 64;
  static const chartOpacity = 0.25;

  static inputDecoration(name, {String? helperText, Widget? helper}) =>
      InputDecoration(
          labelText: name,
          helperText: helperText,
          helper: helper,
          helperMaxLines: 4);

  // animations
  static const Duration formSwapDuration = Duration(milliseconds: 200);

  // set recorder
  static const double recorderButton = 68.0;
  static const double digitWheelHeight = 140.0;
  static const double cardPadding = 8.0;
}
