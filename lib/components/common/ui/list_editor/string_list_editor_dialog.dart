import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:workout_tracker/components/common/line_item_delete_button.dart';
import 'package:workout_tracker/utility/constants.dart';
import 'package:workout_tracker/utility/separated_list.dart';
import 'package:workout_tracker/utility/string_extensions.dart';

// TODO create base class for V that can create the editor for the type, e.g. String, String with Icon, numbers, etc.
/// A dialog to edit lists of type [V].
class ListEditorDialog<V extends String>
    extends StatefulWidget {
  /// Create a new dialog to edit a list of items, [data]. The dialog title and
  /// other references to the collection of items is defined by [itemName].
  const ListEditorDialog({
    super.key,
    required this.data,
    required this.itemName,
  });

  final List<V> data;
  final String itemName;

  @override
  State<ListEditorDialog<V>> createState() => _ListEditorDialogState<V>();
}

class _ListEditorDialogState<V extends String>
    extends State<ListEditorDialog<V>> {
  late Map<String, V> listItems;

  @override
  void initState() {
    super.initState();
    listItems = {for (var item in widget.data) UniqueKey().toString(): item};
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Edit ${widget.itemName} list'),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * Constants.dialogWidth,
        height: MediaQuery.of(context).size.width * Constants.dialogHeight,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: listItems.keys
                .map((i) => StringItemEditor<V>(
                    key: ValueKey(i),
                    itemValue: listItems[i]!,
                    itemKey: i,
                    valueName: widget.itemName.toBeginningOfSentenceCase(),
                    deleteItem: (index) {
                      setState(() => listItems = Map.fromEntries(
                          listItems.entries.where((entry) => entry.key != i)));
                    },
                    updateSetting: (item, key) {
                      setState(() {
                        listItems = Map.fromEntries(listItems.entries.map(
                            (entry) => entry.key == key
                                ? MapEntry(key, item)
                                : entry));
                      });
                    },
                    inputDecoration: Constants.inputDecoration))
                .separatedList(const SizedBox(
                  height: Constants.cardPadding,
                )),
          ),
        ),
      ),
      actions: [
        TextButton(
            onPressed: () {
              setState(() {
                listItems = Map.fromEntries([
                  ...listItems.entries,
                  MapEntry(UniqueKey().toString(), '' as V)
                ]);
              });
            },
            child: Text('Add ${widget.itemName}')),
        TextButton(
            onPressed: () {
              context.pop(widget.data);
            },
            child: const Text('Cancel')),
        TextButton(
            onPressed: () {
              context.pop(listItems.values.toList());
            },
            child: const Text('Save')),
      ],
    );
  }
}

class StringItemEditor<V extends String>
    extends StatefulWidget {
  const StringItemEditor(
      {super.key,
      required this.itemValue,
      required this.itemKey,
      required this.valueName,
      required this.deleteItem,
      required this.updateSetting,
      required this.inputDecoration});

  final V itemValue;
  final String itemKey;
  final void Function(String) deleteItem;
  final void Function(V, String) updateSetting;
  final Function inputDecoration;
  final String valueName;

  @override
  State<StringItemEditor<V>> createState() => _StringItemEditorState<V>();
}

class _StringItemEditorState<V extends String>
    extends State<StringItemEditor<V>> {
  final valueController = TextEditingController();
  String value = '';

  @override
  void initState() {
    valueController.text = widget.itemValue;

    valueController.addListener(() {
      widget.updateSetting(valueController.text as V, widget.itemKey);
    });

    super.initState();
  }

  @override
  void dispose() {
    valueController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      mainAxisSize: MainAxisSize.max,
      children: [
        Expanded(
            child: TextFormField(
          controller: valueController,
          decoration: widget.inputDecoration(widget.valueName),
        )),
        LineItemDeleteButton<String>(
          deleteItem: widget.deleteItem,
          itemId: widget.itemKey,
          size: 36,
        )
      ],
    );
  }
}
