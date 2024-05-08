import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workout_tracker/components/common/custom_scaffold.dart';
import 'package:workout_tracker/controller/user_preferences_state.dart';
import 'package:workout_tracker/data/repositories/user_preferences_repository.dart';
import 'package:workout_tracker/domain/user_preferences.dart';
import 'package:workout_tracker/timer/timer_set_dialog.dart';
import 'package:workout_tracker/utility/separated_list.dart';

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

  @override
  void initState() {
    super.initState();
    _userPreferences = widget.preferences;
    unitsController.text = _userPreferences.weightUnits;

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
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: ([
            DropdownButtonFormField<String>(
              decoration: inputDecoration('Weight units',
                  helper:
                      'These units will be used to record new sets. Existing sets will not be updated.'),
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
          ]).separatedList(const SizedBox(
            height: 24.0,
          )),
        ),
      ),
    );
  }

  int seconds() =>
      _userPreferences.timerLength.inSeconds -
      60 * _userPreferences.timerLength.inMinutes;

  int minutes() => _userPreferences.timerLength.inMinutes;
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
            final _DurationPickerFormFieldState state =
                field as _DurationPickerFormFieldState;
            final InputDecoration decorationArg =
                decoration ?? InputDecoration(focusColor: focusColor);
            final InputDecoration effectiveDecoration =
                decorationArg.applyDefaults(
              Theme.of(field.context).inputDecorationTheme,
            );
            return Focus(
              canRequestFocus: false,
              skipTraversal: true,
              child: Builder(builder: (BuildContext context) {
                final bool isFocused = Focus.of(context).hasFocus;
                InputBorder? resolveInputBorder() {
                  if (isFocused) {
                    return effectiveDecoration.focusedBorder;
                  }
                  if (effectiveDecoration.enabled) {
                    return effectiveDecoration.enabledBorder;
                  }
                  return effectiveDecoration.border;
                }

                BorderRadius? effectiveBorderRadius() {
                  final InputBorder? inputBorder = resolveInputBorder();
                  if (inputBorder is OutlineInputBorder) {
                    return inputBorder.borderRadius;
                  }
                  if (inputBorder is UnderlineInputBorder) {
                    return inputBorder.borderRadius;
                  }
                  return null;
                }

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
                        inputActiveColor: theme.colorScheme.onSurfaceVariant,
                        input: displayRaw,
                        minutes: minutes,
                        seconds: seconds,
                      ),
                      TextButton(
                          onPressed: () {
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
                          },
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
