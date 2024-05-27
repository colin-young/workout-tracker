import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:workout_tracker/components/exercises/settings_edit_sub_form.dart';
import 'package:workout_tracker/data/exercise_controller.dart';
import 'package:workout_tracker/data/repositories/exercise_repository.dart';
import 'package:workout_tracker/data/user_preferences_state.dart';
import 'package:workout_tracker/domain/exercise.dart';
import 'package:workout_tracker/domain/exercise_setting.dart';
import 'package:workout_tracker/domain/exercise_type.dart';
import 'package:workout_tracker/utility/constants.dart';
import 'package:workout_tracker/utility/separated_list.dart';

class ExerciseEditDialog extends ConsumerStatefulWidget {
  final Exercise exercise;
  final String? cancelLabel;
  final String? saveLabel;
  final String title;
  final void Function()? onCancel;
  final void Function()? afterSave;

  const ExerciseEditDialog(
      {super.key,
      required this.exercise,
      required this.title,
      required this.cancelLabel,
      required this.saveLabel,
      required this.onCancel,
      required this.afterSave});

  @override
  ConsumerState<ExerciseEditDialog> createState() => _ExerciseEditDialogState();
}

class _ExerciseEditDialogState extends ConsumerState<ExerciseEditDialog> {
  final _formKey = GlobalKey<FormState>();
  late Exercise _exercise;

  @override
  void initState() {
    super.initState();
    _exercise = widget.exercise;
  }

  Exercise updateExercise(Exercise newExercise) {
    setState(() {
      _exercise = newExercise;
    });

    return _exercise;
  }

  @override
  Widget build(BuildContext context) {
    // Build a Form widget using the _formKey created above.
    var screenSize = MediaQuery.of(context).size;

    return AlertDialog(
      title: Text(widget.title),
      content: Form(
        key: _formKey,
        child: SizedBox(
          width: screenSize.width * Constants.dialogWidth,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              ExerciseEditorControl(
                exercise: _exercise,
                updateExercise: updateExercise,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: widget.onCancel ?? () => context.pop(),
          child: Text(widget.cancelLabel ?? 'Cancel'),
        ),
        TextButton(
          onPressed: () {
            if (_exercise.id > 0) {
              ref.read(updateExerciseProvider(exercise: _exercise));
            } else {
              ref
                  .read(exerciseControllerProvider.notifier)
                  .createExercise(newExercise: _exercise);
            }

            if (widget.afterSave != null) {
              widget.afterSave!();
            } else {
              context.pop();
            }
          },
          child: Text(widget.saveLabel ?? 'Save'),
        ),
      ],
    );
  }
}

class ExerciseEditForm extends ConsumerStatefulWidget {
  const ExerciseEditForm({
    required this.exercise,
    this.cancelLabel,
    this.saveLabel,
    this.onCancel,
    this.afterSave,
    super.key,
  });

  final Exercise exercise;
  final String? cancelLabel;
  final String? saveLabel;
  final void Function()? onCancel;
  final void Function()? afterSave;

  @override
  ConsumerState<ExerciseEditForm> createState() => _ExerciseEditFormState();
}

class _ExerciseEditFormState extends ConsumerState<ExerciseEditForm> {
  // Note: This is a `GlobalKey<FormState>`,
  // not a GlobalKey<MyCustomFormState>.
  final _formKey = GlobalKey<FormState>();
  late Exercise _exercise;

  @override
  void initState() {
    super.initState();
    _exercise = widget.exercise;
  }

  Exercise updateExercise(Exercise newExercise) {
    setState(() {
      _exercise = newExercise;
    });

    return _exercise;
  }

  @override
  Widget build(BuildContext context) {
    // Build a Form widget using the _formKey created above.
    return SingleChildScrollView(
      child: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                ExerciseEditorControl(
                  exercise: _exercise,
                  updateExercise: updateExercise,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    OutlinedButton(
                      onPressed: widget.onCancel ?? () => context.pop(),
                      child: Text(widget.cancelLabel ?? 'Cancel'),
                    ),
                    FilledButton(
                      onPressed: () {
                        if (_exercise.id > 0) {
                          ref.read(updateExerciseProvider(exercise: _exercise));
                        } else {
                          ref
                              .read(exerciseControllerProvider.notifier)
                              .createExercise(newExercise: _exercise);
                        }

                        if (widget.afterSave != null) {
                          widget.afterSave!();
                        } else {
                          context.pop();
                        }
                      },
                      child: Text(widget.saveLabel ?? 'Save'),
                    ),
                  ],
                )
              ],
            ),
          )),
    );
  }
}

class ExerciseEditorControl extends ConsumerStatefulWidget {
  const ExerciseEditorControl({
    super.key,
    required this.exercise,
    required this.updateExercise,
  });

  final Exercise exercise;
  final Exercise Function(Exercise) updateExercise;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _ExerciseEditorControlState();
}

class _ExerciseEditorControlState extends ConsumerState<ExerciseEditorControl>
    with UserPreferencesState {
  late Exercise _exercise;
  final nameController = TextEditingController();
  final noteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _exercise = widget.exercise;
    nameController.text = _exercise.name;
    noteController.text = _exercise.note ?? '';

    nameController.addListener(() {
      setState(() {
        _exercise =
            updateExercise(_exercise.copyWith(name: nameController.text));
      });
    });
    noteController.addListener(() {
      setState(() {
        _exercise =
            updateExercise(_exercise.copyWith(note: noteController.text));
      });
    });
  }

  @override
  void dispose() {
    nameController.dispose();
    noteController.dispose();

    super.dispose();
  }

  Exercise updateExercise(Exercise newExercise) {
    setState(() {
      _exercise = newExercise;
      widget.updateExercise(newExercise);
    });

    return _exercise;
  }

  Exercise addSetting(ExerciseSetting setting) {
    final newExercise = _exercise.copyWith(settings: [
      ..._exercise.settings,
      setting.copyWith(id: _exercise.settings.length + 1)
    ]);
    return updateExercise(newExercise);
  }

  Exercise updateSetting(ExerciseSetting setting) {
    final newExercise = _exercise.copyWith(settings: [
      ..._exercise.settings.map((e) => e.id == setting.id ? setting : e)
    ]);
    return updateExercise(newExercise);
  }

  Exercise deleteSetting(String id) {
    final newExercise = _exercise.copyWith(
        settings: [..._exercise.settings.where((e) => e.id.toString() != id)]);
    return updateExercise(newExercise);
  }

  @override
  Widget build(BuildContext context) {
    inputDecoration(name) => InputDecoration(labelText: name);

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: ([
        TextFormField(
          controller: nameController,
          decoration: inputDecoration('Name'),
          onChanged: (value) {
            setState(() {
              _exercise =
                  widget.updateExercise(_exercise.copyWith(name: value));
            });
          },
        ),
        DropdownButtonFormField<ExerciseType>(
            onChanged: (ExerciseType? newType) {
              setState(() {
                _exercise = updateExercise(
                    _exercise.copyWith(exerciseType: newType?.serialize));
              });
            },
            decoration: inputDecoration('Type'),
            value: _exercise.exerciseType?.deserialize,
            items: userPreferences(ref).exerciseTypeList.map((e) {
              final exerciseType = ExerciseType.deserialize(e);
              
              return DropdownMenuItem(
                  value: exerciseType,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        exerciseType.icon,
                        size: 16,
                      ),
                      const SizedBox(
                        width: 16,
                      ),
                      Text(exerciseType.display),
                    ],
                  ));
            }).toList()),
        TextFormField(
          controller: noteController,
          decoration: inputDecoration('Note'),
          maxLines: null,
          onChanged: (value) {
            setState(() {
              _exercise = updateExercise(_exercise.copyWith(note: value));
            });
          },
        ),
        SettingsEditSubForm(
          settings: _exercise.settings,
          inputDecoration: inputDecoration,
          addSetting: addSetting,
          updateSetting: updateSetting,
          deleteSetting: deleteSetting,
        ),
      ]).separatedList(const SizedBox(
        height: 24.0,
      )),
    );
  }
}
