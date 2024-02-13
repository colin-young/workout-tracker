import 'package:flutter/material.dart';

class RelativeDate extends StatelessWidget {
  final DateTime date;
  const RelativeDate(this.date, {
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final DateTime now = DateTime.now();
    final Duration difference = now.difference(date);
    final int days = difference.inDays;
    final int hours = difference.inHours;
    final int minutes = difference.inMinutes;
    if (days > 14) {
      return Text(date.toIso8601String());
    } else if (days == 1) {
      return const Text('Yesterday');
    } else if (days > 1) {
      return Text('$days days ago');
    } else if (hours == 1) {
      return const Text('An hour ago');
    } else if (hours >= 12 && now.day != date.day) {
      return const Text('Yesterday');
    } else if (hours > 1) {
      return Text('$hours hours ago');
    } else if (minutes == 1) {
      return const Text('A minute ago');
    } else if (minutes > 1) {
      return Text('$minutes minutes ago');
    } else {
      return const Text('Just now');
    }
  }
}
