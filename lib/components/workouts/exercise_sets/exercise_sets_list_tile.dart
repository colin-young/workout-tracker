import 'package:flutter/material.dart';

class ExerciseSetsListTile extends StatelessWidget {
  const ExerciseSetsListTile({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle = '', // NON-NLS
    this.trailing,
  });

  final IconData? icon;
  final String title;
  final String subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      key: super.key,
      leading: Icon(icon),
      trailing: trailing,
      title: Text(title),
      subtitle: subtitle.isNotEmpty ? Text(subtitle) : null,
    );
  }
}
