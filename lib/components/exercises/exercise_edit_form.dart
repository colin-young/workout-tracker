import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:workout_tracker/components/exercises/settings_edit_sub_form.dart';
import 'package:workout_tracker/data/repositories/exercise_repository.dart';
import 'package:workout_tracker/domain/exercise.dart';
import 'package:workout_tracker/domain/exercise_setting.dart';
import 'package:workout_tracker/domain/exercise_type.dart';
import 'dart:developer' as developer;

class ExerciseEditForm extends ConsumerStatefulWidget {
  const ExerciseEditForm(
      {required this.exercise, super.key});

  final Exercise exercise;

  @override
  ConsumerState<ExerciseEditForm> createState() => _ExerciseEditFormState();
}

class _ExerciseEditFormState extends ConsumerState<ExerciseEditForm> {
  // Note: This is a `GlobalKey<FormState>`,
  // not a GlobalKey<MyCustomFormState>.
  final _formKey = GlobalKey<FormState>();
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
      updateExercise(
          _exercise.copyWith(name: nameController.text));
    });
    noteController.addListener(() {
      updateExercise(_exercise.copyWith(note: noteController.text));
    });
  }

  @override
  void dispose() {
    nameController.dispose();
    noteController.dispose();

    super.dispose();
  }

  void updateExercise(Exercise newExercise) {
    setState(() {
      _exercise = newExercise;
    });
  }

  void addSetting(ExerciseSetting setting) {
    final newExercise = _exercise.copyWith(settings: [..._exercise.settings, setting.copyWith(id: _exercise.settings.length + 1)]);
    updateExercise(newExercise);
  }

  void updateSetting(ExerciseSetting setting) {
    final newExercise = _exercise.copyWith(settings: [..._exercise.settings.map((e) => e.id == setting.id ? setting : e)]);
    updateExercise(newExercise);
  }

  void deleteSetting(int id) {
    final newExercise = _exercise.copyWith(settings: [
      ..._exercise.settings.where((e) => e.id != id)
    ]);
    updateExercise(newExercise);
  }

  @override
  Widget build(BuildContext context) {
    // Build a Form widget using the _formKey created above.
    inputDecoration(name) => InputDecoration(
          labelText: name,
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              ),
          filled: true,
          isDense: true,
        );
    return SingleChildScrollView(
      child: Form(
          key: _formKey,
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: ([
                  TextFormField(
                    controller: nameController,
                    decoration: inputDecoration("Name"),
                    onChanged:(value) {
                      setState(() {
                        updateExercise(_exercise.copyWith(name: value));
                      });
                    },
                  ),
                  DropdownButtonFormField<ExerciseType>(
                      onChanged: (ExerciseType? newType) {
                        setState(() {
                          updateExercise(
                              _exercise.copyWith(exerciseType: newType));
                        });
                      },
                      decoration: inputDecoration("Type"),
                      value: _exercise.exerciseType,
                      items: ExerciseType.values
                          .map((exerciseType) => DropdownMenuItem(
                              value: exerciseType,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
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
                              )))
                          .toList()),
                  TextFormField(
                    controller: noteController,
                    decoration: inputDecoration("Note"),
                    maxLines: null,
                    onChanged: (value) {
                      setState(() {
                        updateExercise(_exercise.copyWith(note: value));
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: () => context.pop(),
                        icon: const Icon(Icons.cancel),
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                      IconButton(
                        onPressed: () {
                          updateExercise(_exercise);
                          developer.log("Calling _saveExercise for id ${_exercise.id}",
                              name: "ExerciseEditForm");

                          if (_exercise.id > 0) {
                            ref.read(
                                updateExerciseProvider(exercise: _exercise));
                          } else {
                            ref.read(
                                insertExerciseProvider(exercise: _exercise));
                          }

                          context.pop();
                        },
                        icon: const Icon(Icons.check),
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ],
                  )
                ])
                    .map((e) => Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: e,
                        ))
                    .toList(),
              ),
            ),
          )),
    );
  }
}
