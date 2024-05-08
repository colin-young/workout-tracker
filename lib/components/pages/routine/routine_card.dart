import 'package:flutter/material.dart';
import 'package:workout_tracker/components/common/ui/exercise_sets/exercise_sets_list_tile.dart';
import 'package:workout_tracker/components/pages/routine/add_exercise_dialog.dart';
import 'package:workout_tracker/data/workout_definition_controller.dart';
import 'package:workout_tracker/domain/workout_definition.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workout_tracker/domain/workout_exercise.dart';

class RoutineCard extends ConsumerStatefulWidget {
  const RoutineCard({
    super.key,
    required this.definition,
    required this.textTheme,
    required this.isEditing,
  });

  final WorkoutDefinition definition;
  final TextTheme textTheme;
  final bool isEditing;

  @override
  ConsumerState<RoutineCard> createState() => _RoutineCardState();
}

class _RoutineCardState extends ConsumerState<RoutineCard>
    with TickerProviderStateMixin {
  late bool isEditing;
  late List<WorkoutExercise> _exercises;
  late WorkoutDefinition _originalDefinition = widget.definition;

  final nameController = TextEditingController();

  late final AnimationController _controller = AnimationController(
    duration: const Duration(milliseconds: 500),
    vsync: this,
  );

  @override
  void initState() {
    isEditing = widget.isEditing;
    nameController.text = widget.definition.name;
    _exercises = widget.definition.exercises.map((e) => e).toList();

    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void updateExercises(List<WorkoutExercise> newExercises) {
    setState(() {
      _exercises = newExercises;
    });
  }

  void updateEditStatus(
      bool editStatus, WorkoutDefinition newDefinition) async {
    setState(() {
      isEditing = editStatus;
      _originalDefinition = newDefinition;
      updateExercises(_originalDefinition.exercises);
    });

    try {
      if (isEditing) {
        await _controller.forward().orCancel;
      } else {
        await _controller.reverse().orCancel;
      }
    } on TickerCanceled {
      // The animation got canceled, probably because it was disposed of.
    }
  }

  void startEdit() {
    updateEditStatus(true, _originalDefinition);
  }

  void saveDefinition() {
    int order = 1;

    var newDefinition = _originalDefinition.copyWith(
      name: nameController.text,
      exercises: _exercises.map((e) => e.copyWith(order: order++)).toList(),
    );

    ref
        .read(workoutDefinitionControllerProvider.notifier)
        .updateWorkoutDefinition(definition: newDefinition);

    updateEditStatus(false, newDefinition);
  }

  void cancelEdit() {
    updateEditStatus(false, _originalDefinition);
  }

  @override
  Widget build(BuildContext context) {
    // timeDilation = 10;

    final defaultIconHeight = Theme.of(context)
            .iconButtonTheme
            .style
            ?.iconSize
            ?.resolve(MaterialState.selected as Set<MaterialState>) ??
        20;
    final EdgeInsetsGeometry iconPadding = Theme.of(context)
            .iconButtonTheme
            .style!
            .padding
            ?.resolve(MaterialState.selected as Set<MaterialState>) ??
        const EdgeInsets.all(8);

    const forwardCurve = Interval(0.0, 0.5, curve: Easing.emphasizedDecelerate);
    const reverseCurve = Interval(0.0, 0.5, curve: Easing.emphasizedAccelerate);
    const forwardCurveOverlap =
        Interval(0.25, 0.75, curve: Easing.emphasizedDecelerate);
    const reverseCurveOverlap =
        Interval(0.25, 075, curve: Easing.emphasizedAccelerate);
    const forwardCurveDelayed =
        Interval(0.5, 1.0, curve: Easing.emphasizedDecelerate);
    const reverseCurveDelayed =
        Interval(0.5, 1.0, curve: Easing.emphasizedAccelerate);

    final toEditAnimation = CurvedAnimation(
        parent: _controller, curve: forwardCurve, reverseCurve: reverseCurve);

    final fadeIn = Tween(begin: 0.0, end: 1.0).animate(toEditAnimation);
    final fadeOut = Tween(begin: 1.0, end: 0.0).animate(toEditAnimation);
    final fadeInDelayed = Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(
        parent: _controller,
        curve: forwardCurveDelayed,
        reverseCurve: reverseCurveDelayed));
    final fadeInOverlap = Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(
        parent: _controller,
        curve: forwardCurveOverlap,
        reverseCurve: reverseCurveOverlap));

    final sizeTween = Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(
        parent: _controller, curve: forwardCurve, reverseCurve: reverseCurve));
    final flexTween = IntTween(begin: 40000, end: 0).animate(CurvedAnimation(
        parent: _controller, curve: forwardCurve, reverseCurve: reverseCurve));

    // see https://api.flutter.dev/flutter/material/ListTile/titleTextStyle.html
    // for default with useMaterial3 == true
    var listViewTextStyle = ListTileTheme.of(context).titleTextStyle ??
        Theme.of(context).textTheme.bodyLarge;

    final listStyleTween = TextStyleTween(
      begin: Theme.of(context).textTheme.labelLarge,
      end: listViewTextStyle,
    ).animate(toEditAnimation);

    final editStyleTween = TextStyleTween(
      begin: widget.textTheme.titleSmall,
      end: widget.textTheme.titleMedium,
    ).animate(toEditAnimation);

    final borderTween = BorderTween(
            begin: null,
            end: Border(
                left: InputBorder.none.borderSide,
                top: InputBorder.none.borderSide,
                right: InputBorder.none.borderSide,
                bottom: InputBorder.none.borderSide))
        .animate(toEditAnimation);
    final edgeInsetsTween = EdgeInsetsGeometryTween(
            begin: const EdgeInsets.all(0),
            end: const EdgeInsets.fromLTRB(12, 24, 12, 4.5))
        .animate(toEditAnimation);

    inputDecoration(name) => InputDecoration(
          labelText: name,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          filled: true,
          isDense: true,
        );

    const buttonRowHeight = 64;
    const footerHeight = 36;

    return Card(
      elevation: 1,
      shadowColor: Colors.transparent,
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: AnimatedBuilder(
          animation: _controller,
          builder: (BuildContext context, Widget? child) {
            return Stack(
              children: [
                Opacity(
                  opacity: 1 - fadeInDelayed.value,
                  child: DecoratedBox(
                    decoration: BoxDecoration(border: borderTween.value),
                    child: Padding(
                      padding: edgeInsetsTween.value,
                      child: Text(
                        widget.definition.name,
                        style: editStyleTween.value,
                      ),
                    ),
                  ),
                ),
                Opacity(
                  opacity: fadeInDelayed.value,
                  child: TextFormField(
                    controller: nameController,
                    decoration: inputDecoration('Name'),
                  ),
                ),
                Stack(
                  children: [
                    AnimatedBuilder(
                      animation: _controller,
                      builder: (context, child) {
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(
                              height: 24,
                            ),
                            Padding(
                              padding: iconPadding,
                              child: SizedBox(
                                height: defaultIconHeight,
                              ),
                            )
                          ],
                        );
                      },
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: flexTween.value,
                          child: const SizedBox(),
                        ),
                        Expanded(
                          flex: 30000,
                          child: Column(
                            children: [
                              SizedBox(
                                  height: sizeTween.value * (buttonRowHeight),
                                  width: 1),
                              Stack(children: [
                                fadeInDelayed.value < 1.0
                                    ? Opacity(
                                        opacity: 1 - fadeInDelayed.value,
                                        child: Padding(
                                          padding: EdgeInsets.only(
                                              bottom: sizeTween.value *
                                                  footerHeight),
                                          child: ListView.builder(
                                            shrinkWrap: true,
                                            itemBuilder: (context, index) {
                                              return Padding(
                                                padding: EdgeInsets.all(
                                                    sizeTween.value * 14),
                                                child: Padding(
                                                  padding: EdgeInsets.only(
                                                      left: sizeTween.value *
                                                          40.0),
                                                  child: Text(
                                                    key: ValueKey(
                                                        'exercises$index'),
                                                    _exercises[index]
                                                        .exercise
                                                        .name,
                                                    style: listStyleTween.value,
                                                  ),
                                                ),
                                              );
                                            },
                                            itemCount: _exercises.length,
                                          ),
                                        ),
                                      )
                                    : const SizedBox(),
                                fadeInDelayed.value > 0
                                    ? Opacity(
                                        opacity: fadeInDelayed.value,
                                        child: ReorderableListView.builder(
                                            shrinkWrap: true,
                                            itemBuilder: (context, index) {
                                              return Dismissible(
                                                key:
                                                    ValueKey('exercises$index'),
                                                child: ExerciseSetsListTile(
                                                  icon: _exercises[index]
                                                      .exercise
                                                      .exerciseType!
                                                      .icon,
                                                  title: _exercises[index]
                                                      .exercise
                                                      .name,
                                                ),
                                                onDismissed: (direction) {
                                                  updateExercises(_exercises
                                                      .where((element) =>
                                                          element.id !=
                                                          _exercises[index].id)
                                                      .toList());
                                                },
                                              );
                                            },
                                            footer: Align(
                                              alignment: Alignment.centerRight,
                                              child: TextButton(
                                                onPressed: () {
                                                  showDialog(
                                                    context: context,
                                                    builder: (context) {
                                                      return AddExerciseDialog(
                                                        exercises: _exercises,
                                                        updateExercises:
                                                            updateExercises,
                                                      );
                                                    },
                                                  );
                                                },
                                                child:
                                                    const Text('Change exercises'),
                                              ),
                                            ),
                                            itemCount: _exercises.length,
                                            onReorder: (oldIndex, newIndex) {
                                              setState(() {
                                                if (oldIndex < newIndex) {
                                                  newIndex -= 1;
                                                }
                                                var newExercises = _exercises.toList();
                                                final WorkoutExercise item =
                                                    newExercises
                                                        .removeAt(oldIndex);
                                                newExercises.insert(
                                                    newIndex, item);

                                                _exercises = newExercises;
                                              });
                                            }),
                                      )
                                    : const SizedBox()
                              ]),
                              SizedBox(
                                  height: sizeTween.value * 64,
                                  child: Opacity(
                                    opacity: fadeInDelayed.value,
                                    child: Column(
                                      children: [
                                        const Divider(),
                                        EditButtonsRow(
                                            save: saveDefinition,
                                            cancel: cancelEdit),
                                      ],
                                    ),
                                  ))
                            ],
                          ),
                        ),
                      ],
                    )
                  ],
                ),
                fadeOut.value > 0.0
                    ? Positioned(
                        bottom: 0,
                        left: 0,
                        child: Align(
                            alignment: Alignment.bottomLeft,
                            child: Opacity(
                                opacity: fadeOut.value,
                                child: ViewButtonsRow(edit: startEdit))),
                      )
                    : const SizedBox()
              ],
            );
          },
        ),
      ),
    );
  }
}

class ViewButtonsRow extends StatelessWidget {
  const ViewButtonsRow({super.key, required this.edit});

  final Function() edit;

  @override
  Widget build(BuildContext context) {
    return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [OutlinedButton(onPressed: edit, child: const Text('Edit'))]);
  }
}

class EditButtonsRow extends StatelessWidget {
  const EditButtonsRow({super.key, required this.save, required this.cancel});

  final Function() save;
  final Function() cancel;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        mainAxisSize: MainAxisSize.max,
        children: [
          OutlinedButton.icon(
              onPressed: cancel,
              label: const Text('Cancel'),
              icon: const Icon(Icons.close)),
          FilledButton.tonalIcon(
              onPressed: save,
              icon: const Icon(Icons.check),
              label: const Text('Save'))
        ],
      ),
    );
  }
}
