import 'package:flutter/material.dart';
import 'package:workout_tracker/components/common/ui/card_title_divider.dart';
import 'package:workout_tracker/components/exercises/setting_editor.dart';
import 'package:workout_tracker/domain/exercise_setting.dart';

class SettingsEditSubForm extends StatelessWidget {
  const SettingsEditSubForm({
    super.key,
    required this.settings,
    required this.inputDecoration,
    required this.addSetting,
    required this.updateSetting,
    required this.deleteSetting,
  });

  final List<ExerciseSetting> settings;
  final Function inputDecoration;
  final Function(ExerciseSetting) addSetting;
  final void Function(ExerciseSetting) updateSetting;
  final void Function(int) deleteSetting;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        settings.isNotEmpty
            ? const CardTitleDivider(child: Text("Settings"))
            : const SizedBox(),
        settings.isNotEmpty
            ? Column(
                children: settings
                    .map((setting) => Padding(
                          padding: const EdgeInsets.fromLTRB(0, 4, 0, 4),
                          child: SettingEditor(
                              key: ValueKey('settingEditor${setting.id}'),
                              setting: setting,
                              deleteItem: deleteSetting,
                              updateSetting: updateSetting,
                              inputDecoration: inputDecoration,
                              ),
                        ))
                    .toList(),
              )
            : const SizedBox(),
        TextButton(
            onPressed: () =>
                addSetting(const ExerciseSetting(setting: "", value: "")), child: const Row(
                  children: [
                    Icon(Icons.add),
                    SizedBox(width: 8,),
                    Text("Add Setting"),
                  ],
                ),),
      ],
    );
  }
}
