import 'package:flutter/material.dart';

class LineItemDeleteButton<K extends String> extends StatelessWidget {
  const LineItemDeleteButton({
    super.key,
    required this.deleteItem,
    required this.itemId,
    this.size,
  });

  final void Function(K) deleteItem;
  final K itemId;
  final double? size;

  @override
  Widget build(BuildContext context) {
    return IconButton(
        onPressed: () => deleteItem(itemId),
        icon: Icon(
          Icons.delete_forever,
          color: Theme.of(context).colorScheme.error,
          size: size,
        ));
  }
}
