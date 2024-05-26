import 'package:flutter/material.dart';
import 'package:workout_tracker/components/common/ui/list_editor/string_list_editor_dialog.dart';

class ItemListFormField<T extends String> extends FormField<List<T>> {
  ItemListFormField({
    super.key,
    super.onSaved,
    super.validator,
    List<T>? value,
    super.enabled,
    super.autovalidateMode,
    super.restorationId,
    required this.onChanged,
    Color? focusColor,
    InputDecoration? decoration,
    TextStyle? style,
    TextStyle? styleSub,
  })  : decoration = decoration ?? InputDecoration(focusColor: focusColor),
        super(
          initialValue: value,
          builder: (FormFieldState<List<T>> field) {
            final InputDecoration decorationArg =
                decoration ?? InputDecoration(focusColor: focusColor);
            decorationArg.applyDefaults(
              Theme.of(field.context).inputDecorationTheme,
            );
            return Focus(
              canRequestFocus: false,
              skipTraversal: true,
              child: Builder(builder: (BuildContext context) {
                return InputDecorator(
                  decoration: decoration!,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        flex: 5,
                        child: Text(value?.join(', ') ?? 'no entries'),
                      ),
                      Expanded(
                        flex: 1,
                        child: TextButton(
                            onPressed: enabled && value != null
                                ? () async {
                                    final List<T>? newTypes = await showDialog(
                                      context: context,
                                      builder: (context) =>
                                          ListEditorDialog<String>(
                                        data: value,
                                        itemName: 'exercise type',
                                        simpleStringEditor: StringItemEditorRow.getExerciseTypeItemEditor,
                                      ),
                                    );

                                    if (newTypes != null && onChanged != null) {
                                      onChanged(newTypes);
                                    }
                                  }
                                : null,
                            child: const Text('Edit')),
                      )
                    ],
                  ),
                );
              }),
            );
          },
        );

  final ValueChanged<List<T>?>? onChanged;
  final InputDecoration decoration;

  @override
  FormFieldState<List<T>> createState() => _ItemListFormFieldState<T>();
}

class _ItemListFormFieldState<T extends String>
    extends FormFieldState<List<T>> {
  ItemListFormField<T> get _itemListFormField => widget as ItemListFormField<T>;

  @override
  void didChange(List<T>? value) {
    super.didChange(value);
    _itemListFormField.onChanged?.call(value);
  }

  @override
  void didUpdateWidget(ItemListFormField<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialValue != widget.initialValue) {
      setValue(widget.initialValue);
    }
  }

  @override
  void reset() {
    super.reset();
    _itemListFormField.onChanged?.call(value);
  }
}
