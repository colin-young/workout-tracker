import 'package:flutter/material.dart';
import 'package:workout_tracker/utility/relative_date.dart';

class RelativeDate extends StatelessWidget {
  final DateTime date;
  final TextStyle style;
  const RelativeDate(
    this.date, {
    required this.style,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    String displayValue = date.getRelativeDateString();

    return Text(displayValue, style: style);
  }
}
