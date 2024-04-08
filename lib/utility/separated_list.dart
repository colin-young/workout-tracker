import 'package:flutter/material.dart';

extension SeparatedList on Iterable<Widget> {
  List<Widget> separatedList(Widget widget) {
    var index = 0;
    return map((e) {
      return index++ == 0 ? [e] : [widget, e];
    }).expand((element) => element).toList();
  }
}
