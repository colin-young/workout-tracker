import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:workout_tracker/components/common/line_item_delete_button.dart';
import 'package:workout_tracker/domain/exercise_type.dart';
import 'package:workout_tracker/utility/constants.dart';
import 'package:workout_tracker/utility/separated_list.dart';
import 'package:workout_tracker/utility/string_extensions.dart';

class ListEditorDialog<T> extends StatefulWidget {
  /// Create a new dialog to edit a list of items, [data]. The dialog title and
  /// other references to the collection of items is defined by [itemName].
  const ListEditorDialog({
    super.key,
    required this.data,
    required this.itemName,
    required this.simpleStringEditor,
  });

  final List<String> data;
  final String itemName;
  final ItemEditorRowFunction simpleStringEditor;

  @override
  State<ListEditorDialog> createState() => _ListEditorDialogState<String>();
}

class _ListEditorDialogState<V extends String> extends State<ListEditorDialog> {
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
            children: listItems.keys.map((i) {
              return StringItemEditor(
                  key: ValueKey(i),
                  itemValue: listItems[i]!,
                  itemKey: i,
                  itemEditorRow: widget.simpleStringEditor,
                  valueName: widget.itemName.toBeginningOfSentenceCase(),
                  deleteItem: (index) {
                    setState(() => listItems = Map.fromEntries(
                        listItems.entries.where((entry) => entry.key != i)));
                  },
                  updateSetting: (item, key) {
                    setState(() {
                      listItems = Map.fromEntries(listItems.entries.map(
                          (entry) =>
                              entry.key == key ? MapEntry(key, item) : entry));
                    });
                  },
                  inputDecoration: Constants.inputDecoration);
            }).separatedList(const SizedBox(
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

class StringItemEditor extends StatefulWidget {
  const StringItemEditor({
    super.key,
    required this.itemValue,
    required this.itemKey,
    required this.valueName,
    required this.deleteItem,
    required this.updateSetting,
    required this.itemEditorRow,
    required this.inputDecoration,
  });

  final String itemValue;
  final String itemKey;
  final void Function(String) deleteItem;
  final void Function(String, String) updateSetting;
  final ItemEditorRowFunction itemEditorRow;
  final Function inputDecoration;
  final String valueName;

  @override
  State<StringItemEditor> createState() => _StringItemEditorState();
}

class _StringItemEditorState extends State<StringItemEditor> {
  final valueController = TextEditingController();
  String value = '';

  @override
  void initState() {
    valueController.text = widget.itemValue;

    valueController.addListener(() {
      widget.updateSetting(valueController.text, widget.itemKey);
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
    // return Row(
    //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
    //   mainAxisSize: MainAxisSize.max,
    //   children: [
    //     Expanded(
    //         child: TextFormField(
    //       controller: valueController,
    //       decoration: widget.inputDecoration(widget.valueName),
    //     )),
    //     LineItemDeleteButton<String>(
    //       deleteItem: widget.deleteItem,
    //       itemId: widget.itemKey,
    //       size: 36,
    //     )
    //   ],
    // );
    return widget.itemEditorRow(
      controller: valueController,
      decorator: widget.inputDecoration(widget.valueName),
      valueName: widget.valueName,
      deleteItem: widget.deleteItem,
      itemKey: widget.itemKey,
      item: widget.itemValue,
    );
  }
}

typedef ItemEditorRowFunction = Widget Function({
  required TextEditingController controller,
  required InputDecoration decorator,
  required String valueName,
  required void Function(String) deleteItem,
  required String itemKey,
  required String item,
});

class StringItemEditorRow {
  static Widget getSimpleStringItemEditor({
    required TextEditingController controller,
    required InputDecoration decorator,
    required String valueName,
    required void Function(String) deleteItem,
    required String itemKey,
    required String item,
  }) =>
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        mainAxisSize: MainAxisSize.max,
        children: [
          Expanded(
              child: TextFormField(
            controller: controller,
            decoration: decorator,
          )),
          LineItemDeleteButton<String>(
            deleteItem: deleteItem,
            itemId: itemKey,
            size: 36,
          )
        ],
      );
  static Widget getExerciseTypeItemEditor({
    required TextEditingController controller,
    required InputDecoration decorator,
    required String valueName,
    required void Function(String) deleteItem,
    required String itemKey,
    required String item,
  }) {
    final ExerciseType? type = ExerciseType.values
        .where((e) => e.display.toLowerCase() == (item).toLowerCase())
        .firstOrNull;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      mainAxisSize: MainAxisSize.max,
      children: [
        type != null ? Icon(type.icon) : const Icon(Icons.question_mark),
        const SizedBox(width: Constants.rowSpacing),
        Expanded(
            child: TextFormField(
          controller: controller,
          decoration: decorator,
        )),
        LineItemDeleteButton<String>(
          deleteItem: deleteItem,
          itemId: itemKey,
          size: 36,
        )
      ],
    );
  }
}
