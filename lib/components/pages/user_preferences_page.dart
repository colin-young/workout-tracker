import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workout_tracker/components/common/custom_scaffold.dart';
import 'package:workout_tracker/components/common/ui/chart.dart';
import 'package:workout_tracker/components/common/ui/wheel_picker/multi_digit_wheel.dart';
import 'package:workout_tracker/controller/user_preferences_state.dart';
import 'package:workout_tracker/data/repositories/user_preferences_repository.dart';
import 'package:workout_tracker/domain/set_entry.dart';
import 'package:workout_tracker/domain/user_preferences.dart';
import 'package:workout_tracker/timer/timer_set_dialog.dart';
import 'package:workout_tracker/utility/constants.dart';
import 'package:workout_tracker/utility/separated_list.dart';
import 'package:workout_tracker/utility/set_entry_list_utils.dart';
import 'package:workout_tracker/utility/set_entry_utils.dart';

class UserPreferencesPage extends ConsumerWidget with UserPreferencesState {
  const UserPreferencesPage({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CustomScaffold(
      title: const Text('User preferences'),
      body: UserPreferencesEditor(preferences: userPreferences(ref)),
    );
  }
}

class UserPreferencesEditor extends ConsumerStatefulWidget {
  UserPreferencesEditor({super.key, required this.preferences});

  final _formKey = GlobalKey<FormState>();
  final UserPreferences preferences;

  @override
  ConsumerState<UserPreferencesEditor> createState() => _UserPreferencesState();
}

class _UserPreferencesState extends ConsumerState<UserPreferencesEditor> {
  final unitsController = TextEditingController();
  late UserPreferences _userPreferences;
  late double _chartOpacity;

  @override
  void initState() {
    super.initState();
    _userPreferences = widget.preferences;
    unitsController.text = _userPreferences.weightUnits;
    _chartOpacity = _userPreferences.chartOpacity;

    unitsController.addListener(() {});
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

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    inputDecoration(name, {helper}) =>
        InputDecoration(labelText: name, helperText: helper, helperMaxLines: 4);
    final textTheme = Theme.of(context).textTheme;

    return Form(
      key: widget._formKey,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: ([
              DropdownButtonFormField<String>(
                decoration: inputDecoration('Weight units',
                    helper:
                        'These units will be used to record new sets. Previously recorded sets will not be updated.'),
                value: _userPreferences.weightUnits,
                items: const [
                  DropdownMenuItem(
                    value: 'lbs',
                    child: Text('lbs'),
                  ),
                  DropdownMenuItem(
                    value: 'kg',
                    child: Text('kg'),
                  ),
                ],
                onChanged: (String? value) {
                  updatePrefs(_userPreferences.copyWith(weightUnits: value!));
                },
              ),
              DurationPickerFormField(
                  decoration: inputDecoration('Rest Timer',
                      helper:
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
                      helper:
                          'If a workout has not had a set recorded for this length of time it will be marked as completed automatially.'),
                  value:
                      _userPreferences.autoCloseWorkout.autoCloseWorkoutAfter,
                  style: textTheme.titleLarge,
                  styleSub: textTheme.labelMedium,
                  enabled: _userPreferences.autoCloseWorkout.autoClose,
                  onChanged: (newDuration) {
                    updatePrefs(_userPreferences.copyWith(
                        autoCloseWorkout: _userPreferences.autoCloseWorkout
                            .copyWith(autoCloseWorkoutAfter: newDuration!)));
                  }),
              InputDecorator(
                decoration: inputDecoration('Chart visibility',
                    helper:
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
                        onPressed:
                            _chartOpacity != _userPreferences.chartOpacity
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
        ),
      ),
    );
  }

  int seconds() =>
      _userPreferences.timerLength.inSeconds -
      60 * _userPreferences.timerLength.inMinutes;

  int minutes() => _userPreferences.timerLength.inMinutes;
}

class SampleChart extends StatelessWidget {
  const SampleChart({super.key, required this.chartOpacity});

  final double chartOpacity;

  @override
  Widget build(BuildContext context) {
    var startDate = DateTime.now();
    var exercises = [for (var i = -14; i < 0; i += 1) i].map((d) => [
          SetEntry(
              reps: 10 + (d.isEven ? d % 3 : -1 * d % 4) + d ~/ 2,
              weight: 5,
              units: 'lbs',
              finishedAt: startDate.add(Duration(days: d, minutes: 1))),
          SetEntry(
              reps: 9 + (d.isEven ? d % 2 : -1 * d % 3) + d ~/ 2,
              weight: 5,
              units: 'lbs',
              finishedAt: startDate.add(Duration(days: d, minutes: 2))),
          SetEntry(
              reps: 8 + (d.isEven ? d % 4 : -1 * d % 2) + d ~/ 2,
              weight: 5,
              units: 'lbs',
              finishedAt: startDate.add(Duration(days: d, minutes: 3))),
        ]);
    final sets = exercises
        .map((i) => TimeSeriesSets(
              time: i[0].finishedAt,
              value: SetEntryListUtils.average(i, SetEntryUtils.oneRMEpley),
              min: SetEntryListUtils.min(i, SetEntryUtils.oneRMEpley),
              max: SetEntryListUtils.max(i, SetEntryUtils.oneRMEpley),
            ))
        .toList();

    final Map<DateTime, List<SetEntry>> exerciseSets = {
      for (var item in exercises) item[0].finishedAt: item
    };

    final trend = exerciseSets
        .trend(
          SetEntryUtils.oneRMEpley,
          SetEntryListUtils.average,
          windowSize: 5,
        )
        .keys
        .map((t) => TimeSeriesSets(
            time: t,
            value: exerciseSets.trend(
              SetEntryUtils.oneRMEpley,
              SetEntryListUtils.average,
              windowSize: 5,
            )[t]))
        .toList();

    return Stack(
      children: [
        SizedBox(
          height: Constants.digitWheelHeight * 2,
          child: Opacity(
            opacity: chartOpacity,
            child: SimpleTimeSeriesChart(
              data: sets,
              trend: trend,
              animate: false,
              animation: 1,
              showAxis: true,
              showRange: true,
              showGridLines: true,
              measure: 6.65,
            ),
          ),
        ),
        Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: Constants.digitWheelHeight,
                child: MultiDigitWheel(
                  key: const ValueKey('demoReps'),
                  suffix: 'reps',
                  value: 10,
                  updateTens: (i) {},
                  updateOnes: (i) {},
                ),
              ),
              SizedBox(
                height: Constants.digitWheelHeight,
                child: MultiDigitWheel(
                  key: const ValueKey('demoWeight'),
                  suffix: 'lbs',
                  value: 5,
                  updateHundreds: (i) {},
                  updateTens: (i) {},
                  updateOnes: (i) {},
                ),
              ),
            ]),
      ],
    );
  }
}

class DurationPickerFormField extends FormField<Duration> {
  DurationPickerFormField({
    super.key,
    super.onSaved,
    super.validator,
    Duration? value,
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
          builder: (FormFieldState<Duration> field) {
            final InputDecoration decorationArg =
                decoration ?? InputDecoration(focusColor: focusColor);
            decorationArg.applyDefaults(
              Theme.of(field.context).inputDecorationTheme,
            );
            return Focus(
              canRequestFocus: false,
              skipTraversal: true,
              child: Builder(builder: (BuildContext context) {

                final theme = Theme.of(context);
                minutes() => value?.inMinutes ?? 0;
                seconds() => (value?.inSeconds ?? 0) - minutes() * 60;
                final displayRaw =
                    '${minutes().toString().padLeft(2, '0')}${seconds().toString().padLeft(2, '0')}';

                return InputDecorator(
                  decoration: decoration!,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      DurationDisplay(
                        labelStyle: styleSub?.copyWith(
                            color: theme.colorScheme.outlineVariant),
                        inputStyle: style?.copyWith(
                            color: theme.colorScheme.outlineVariant),
                        inputActiveColor: enabled
                            ? theme.colorScheme.onSurfaceVariant
                            : theme.colorScheme.outlineVariant,
                        input: displayRaw,
                        minutes: minutes,
                        seconds: seconds,
                      ),
                      TextButton(
                          onPressed: enabled
                              ? () {
                                  if (onChanged != null) {
                                    showDialog(
                                        context: context,
                                        builder: (context) {
                                          return TimerSetDialog(
                                            saveLabel: 'Update default',
                                            onSave: (duration) {
                                              onChanged(duration);

                                              value = duration;
                                            },
                                          );
                                        });
                                  }
                                }
                              : null,
                          child: const Text('Edit'))
                    ],
                  ),
                );
              }),
            );
          },
        );

  final ValueChanged<Duration?>? onChanged;
  final InputDecoration decoration;

  @override
  FormFieldState<Duration> createState() => _DurationPickerFormFieldState();
}

class _DurationPickerFormFieldState extends FormFieldState<Duration> {
  DurationPickerFormField get _durationPickerFormField =>
      widget as DurationPickerFormField;
  @override
  void didChange(Duration? value) {
    super.didChange(value);
    _durationPickerFormField.onChanged?.call(value);
  }

  @override
  void didUpdateWidget(DurationPickerFormField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialValue != widget.initialValue) {
      setValue(widget.initialValue);
    }
  }

  @override
  void reset() {
    super.reset();
    _durationPickerFormField.onChanged?.call(value);
  }
}
