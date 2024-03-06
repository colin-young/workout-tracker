import 'package:flutter/material.dart';

class RelativeDate extends StatelessWidget {
  final DateTime date;
  final TextStyle style;
  const RelativeDate(this.date, { required this.style,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final DateTime now = DateTime.now();
    final Duration difference = now.difference(date);
    final int days = difference.inDays;
    final int hours = difference.inHours;
    final int minutes = difference.inMinutes;
    String displayValue = '';
    if (days > 14) {
      displayValue = date.toIso8601String();
    } else if (days == 1) {
      displayValue = 'Yesterday';
    } else if (days > 1) {
      displayValue = '$days days ago';
    } else if (hours == 1) {
      displayValue = 'An hour ago';
    } else if (hours >= 12 && now.day != date.day) {
      displayValue = 'Yesterday';
    } else if (hours > 1) {
      displayValue = '$hours hours ago';
    } else if (minutes == 1) {
      displayValue = 'A minute ago';
    } else if (minutes > 1) {
      displayValue = '$minutes minutes ago';
    } else {
      displayValue = 'Just now';
    }

    return Text(displayValue, style: style);
  }
}
