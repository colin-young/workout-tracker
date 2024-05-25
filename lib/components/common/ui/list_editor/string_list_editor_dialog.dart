import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:workout_tracker/components/common/line_item_delete_button.dart';
import 'package:workout_tracker/utility/constants.dart';
import 'package:workout_tracker/utility/separated_list.dart';
import 'package:workout_tracker/utility/string_extensions.dart';

class StringListEditorDialog extends StatefulWidget {
  const StringListEditorDialog({
    super.key,
    required this.data,
    required this.itemName,
  });

  final List<String> data;
  final String itemName;

  @override
  State<StringListEditorDialog> createState() => _StringListEditorDialogState();
}

class _StringListEditorDialogState extends State<StringListEditorDialog> {
  late Map<String, String> listItems;

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
                .map((i) => StringItemEditor<String>(
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
                  MapEntry(UniqueKey().toString(), '')
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

class StringItemEditor<T> extends StatefulWidget {
  const StringItemEditor(
      {super.key,
      required this.itemValue,
      required this.itemKey,
      required this.valueName,
      required this.deleteItem,
      required this.updateSetting,
      required this.inputDecoration});

  final String itemValue;
  final T itemKey;
  final void Function(T) deleteItem;
  final void Function(String, T) updateSetting;
  final Function inputDecoration;
  final String valueName;

  @override
  State<StringItemEditor<T>> createState() => _StringItemEditorState<T>();
}

class _StringItemEditorState<T> extends State<StringItemEditor<T>> {
  final settingValueController = TextEditingController();
  String value = '';

  @override
  void initState() {
    settingValueController.text = widget.itemValue;

    settingValueController.addListener(() {
      widget.updateSetting(settingValueController.text, widget.itemKey);
    });

    super.initState();
  }

  @override
  void dispose() {
    settingValueController.dispose();
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
          controller: settingValueController,
          decoration: widget.inputDecoration(widget.valueName),
        )),
        LineItemDeleteButton<T>(
          deleteItem: widget.deleteItem,
          itemId: widget.itemKey,
          size: 36,
        )
      ],
    );
  }
}
