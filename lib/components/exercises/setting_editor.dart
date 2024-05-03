import 'package:flutter/material.dart';
import 'package:workout_tracker/components/common/line_item_delete_button.dart';
import 'package:workout_tracker/domain/exercise_setting.dart';

class SettingEditor extends StatefulWidget {
  const SettingEditor({
    super.key,
    required this.setting,
    required this.inputDecoration,
    required this.deleteItem,
    required this.updateSetting,
  });

  final Function inputDecoration;
  final ExerciseSetting setting;
  final void Function(int) deleteItem;
  final void Function(ExerciseSetting) updateSetting;

  @override
  State<SettingEditor> createState() => _SettingEditorState();
}

class _SettingEditorState extends State<SettingEditor> {
  final settingNameController = TextEditingController();
  final settingValueController = TextEditingController();
  String setting = ''; // NON-NLS
  String value = ''; // NON-NLS

  @override
  void dispose() {
    settingNameController.dispose();
    settingValueController.dispose();

    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    settingNameController.text = widget.setting.setting;
    settingValueController.text = widget.setting.value;

    settingNameController.addListener(() {
      widget.updateSetting(
          widget.setting.copyWith(setting: settingNameController.text));
    });

    settingValueController.addListener(() {
      widget.updateSetting(
          widget.setting.copyWith(value: settingValueController.text));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      mainAxisSize: MainAxisSize.max,
      children: [
        Expanded(
            child: TextFormField(
          controller: settingNameController,
          decoration: widget.inputDecoration('Name'),
        )),
        const SizedBox(
          width: 8,
        ),
        Expanded(
            child: TextFormField(
          controller: settingValueController,
          decoration: widget.inputDecoration('Setting'),
        )),
        LineItemDeleteButton(
          deleteItem: widget.deleteItem,
          itemId: widget.setting.id,
          size: 36,
        )
      ],
    );
  }
}
