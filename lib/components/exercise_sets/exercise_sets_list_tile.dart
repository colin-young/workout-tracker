import 'package:flutter/material.dart';

class ExerciseSetsListTile extends StatelessWidget {
  const ExerciseSetsListTile({
    super.key,
    required this.icon,
    required this.title, this.subtitle = '',
  });

  final IconData? icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      key: super.key,
      leading: Icon(icon),
      title: Text(title),
      subtitle: subtitle.isNotEmpty ? Text(subtitle) : null,
    );
  }
}
