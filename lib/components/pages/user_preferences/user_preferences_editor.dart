import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workout_tracker/components/common/ui/duration_picker/duration_picker_form_field.dart';
import 'package:workout_tracker/components/common/ui/list_editor/item_list_form_field.dart';
import 'package:workout_tracker/components/common/ui/list_editor/string_list_editor_dialog.dart';
import 'package:workout_tracker/components/pages/user_preferences/sample_chart.dart';
import 'package:workout_tracker/data/repositories/user_preferences_repository.dart';
import 'package:workout_tracker/domain/user_preferences.dart';
import 'package:workout_tracker/utility/separated_list.dart';

class UserPreferencesEditor extends ConsumerStatefulWidget {
  const UserPreferencesEditor({super.key, required this.preferences});

  final UserPreferences preferences;

  @override
  ConsumerState<UserPreferencesEditor> createState() => _UserPreferencesState();
}

class _UserPreferencesState extends ConsumerState<UserPreferencesEditor> {
  final unitsController = TextEditingController();
  ScrollController scrollController = ScrollController();

  late UserPreferences _userPreferences;
  late double _chartOpacity;

  @override
  void initState() {
    super.initState();
    _userPreferences = widget.preferences;
    unitsController.text = _userPreferences.weightUnits;
    _chartOpacity = _userPreferences.chartOpacity;

    unitsController.addListener(() {});
    scrollController.addListener(() {});
  }

  void updatePrefs(UserPreferences newPrefs) {
    ref.read(updateUserPreferencesProvider(userPreferences: newPrefs));

    setState(() {
      _userPreferences = newPrefs;
    });
  }

  @override
  void dispose() {
    unitsController.dispose();
    scrollController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    inputDecoration(name, {String? helperText, Widget? helper}) =>
        InputDecoration(
            labelText: name,
            helperText: helperText,
            helper: helper,
            helperMaxLines: 4);
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ListView(
        children: ([
          DropdownButtonFormField<String>(
            decoration: inputDecoration(
              'Weight units',
              helper: Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text(
                        'These units will be used to record new sets. Previously recorded sets will not be updated.',
                        style: textTheme.bodySmall,
                      ),
                    ),
                    TextButton(
                      onPressed: () async {
                        final List<String>? newUnits = await showDialog(
                          context: context,
                          builder: (context) => ListEditorDialog(
                            data: _userPreferences.weightUnitList,
                            itemName: 'unit',
                          ),
                        );

                        if (newUnits != null) {
                          String defaultWeightUnits =
                              newUnits.contains(_userPreferences.weightUnits)
                                  ? _userPreferences.weightUnits
                                  : newUnits.first;

                          updatePrefs(_userPreferences.copyWith(
                              weightUnitList:
                                  newUnits.where((u) => u.isNotEmpty).toList(),
                              weightUnits: defaultWeightUnits));
                        }
                      },
                      child: const Text('Edit units'),
                    ),
                  ],
                ),
              ),
            ),
            value: _userPreferences.weightUnits,
            items: _userPreferences.weightUnitList
                .map((u) => DropdownMenuItem(value: u, child: Text(u)))
                .toList(),
            onChanged: (String? value) {
              updatePrefs(_userPreferences.copyWith(weightUnits: value!));
            },
          ),
          ItemListFormField(
            decoration: inputDecoration(
              'Exercise types',
              helperText:
                  'These types are used to group exercises into general categories such as machine, free weights, body weight, etc. They can be used to distinguish between different styles of equivalent exercises, for example a chest press with free weights vs. a chest press machine.',
            ),
            onChanged: (newList) {
              if (newList != null) {
                updatePrefs(_userPreferences.copyWith(
                    exerciseTypeList:
                        newList.where((u) => u.isNotEmpty).toList()));
              }
            },
            value: _userPreferences.exerciseTypeList,
          ),
          DurationPickerFormField(
              decoration: inputDecoration('Rest timer',
                  helperText:
                      'The duration of the timer used for rests between sets.'),
              value: _userPreferences.timerLength,
              style: textTheme.titleLarge,
              styleSub: textTheme.labelMedium,
              onChanged: (newDuration) {
                updatePrefs(
                    _userPreferences.copyWith(timerLength: newDuration!));
              }),
          InputDecorator(
              decoration: inputDecoration('Auto-complete workout'),
              child: CheckboxListTile(
                value: _userPreferences.autoCloseWorkout.autoClose,
                title: const Text('Auto-complete workouts'),
                subtitle: const Text(
                    'Enable this to allow workouts to be automatically marked as completed after a period of inactivity.'),
                onChanged: (autoClose) {
                  updatePrefs(_userPreferences.copyWith(
                      autoCloseWorkout: _userPreferences.autoCloseWorkout
                          .copyWith(autoClose: autoClose!)));
                },
              )),
          DurationPickerFormField(
              decoration: inputDecoration('Auto-complete workout after',
                  helperText:
                      'If a workout has not had a set recorded for this length of time it will be marked as completed automatially.'),
              value: _userPreferences.autoCloseWorkout.autoCloseWorkoutAfter,
              style: textTheme.titleLarge,
              styleSub: textTheme.labelMedium,
              enabled: _userPreferences.autoCloseWorkout.autoClose,
              showHours: true,
              onChanged: (newDuration) {
                updatePrefs(_userPreferences.copyWith(
                    autoCloseWorkout: _userPreferences.autoCloseWorkout
                        .copyWith(autoCloseWorkoutAfter: newDuration!)));
              }),
          InputDecorator(
            decoration: inputDecoration('Chart visibility',
                helperText:
                    'Tweak the visibility of the chart in the set recorder for the best view.'),
            child: Column(
              children: [
                Slider(
                    value: _chartOpacity,
                    max: 1.0,
                    divisions: 10,
                    onChanged: (opacity) {
                      setState(() {
                        _chartOpacity = opacity;
                      });
                    }),
                TextButton(
                    onPressed: _chartOpacity != _userPreferences.chartOpacity
                        ? () {
                            updatePrefs(_userPreferences.copyWith(
                                chartOpacity: _chartOpacity));
                          }
                        : null,
                    child: const Text('Save')),
                Card.filled(
                  color: Theme.of(context).colorScheme.surface,
                  child: SampleChart(chartOpacity: _chartOpacity),
                ),
              ],
            ),
          ),
        ]).separatedList(const SizedBox(
          height: 24.0,
        )),
      ),
    );
  }

  int seconds() =>
      _userPreferences.timerLength.inSeconds -
      60 * _userPreferences.timerLength.inMinutes;

  int minutes() => _userPreferences.timerLength.inMinutes;
}
