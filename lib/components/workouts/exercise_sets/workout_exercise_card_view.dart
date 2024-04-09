import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:workout_tracker/components/common/ui/chart.dart';
import 'package:workout_tracker/components/sets_list_view.dart';
import 'package:workout_tracker/domain/exercise_sets.dart';
import 'package:workout_tracker/utility/relative_date.dart';
import 'dart:developer' as developer;

class WorkoutExerciseCardView extends StatelessWidget {
  const WorkoutExerciseCardView({
    super.key,
    required this.workoutExercise,
    this.inset = 12.0,
  });

  final double inset;
  final ExerciseSets workoutExercise;

  @override
  Widget build(BuildContext context) {
    return ClosedWorkoutExerciseCard(
      inset: inset,
      workoutExercise: workoutExercise,
      detailPanelColor: Theme.of(context).colorScheme.secondaryContainer,
      backgroundColor: Theme.of(context).colorScheme.background,
    );
  }
}

class ClosedWorkoutExerciseCard extends StatefulWidget {
  const ClosedWorkoutExerciseCard(
      {super.key,
      required this.inset,
      required this.workoutExercise,
      required this.detailPanelColor,
      required this.backgroundColor,
      this.chartHeight = 160,
      this.animationDuration = const Duration(milliseconds: 1500),
      this.chartOpacityBackground = 0.125});

  final double inset;
  final ExerciseSets workoutExercise;
  final Duration animationDuration;
  final double chartOpacityBackground;
  final int chartHeight;
  final Color detailPanelColor;
  final Color backgroundColor;

  @override
  State<ClosedWorkoutExerciseCard> createState() =>
      _ClosedWorkoutExerciseCardState();
}

class _ClosedWorkoutExerciseCardState extends State<ClosedWorkoutExerciseCard>
    with TickerProviderStateMixin {
  late final chartOpacityBackground = widget.chartOpacityBackground;
  late final chartOpacityRangeSize = 1 - widget.chartOpacityBackground;
  late final chartHeightOpen = widget.chartHeight;

  var isOpen = false;
  final colorForwardCurve =
      const Interval(0.25, 1.0, curve: Curves.fastOutSlowIn);
  final colorReverseCurve =
      const Interval(0.25, 1.0, curve: Curves.fastOutSlowIn).flipped;

  late final AnimationController _controller = AnimationController(
    duration: widget.animationDuration,
    reverseDuration:
        Duration(milliseconds: (widget.animationDuration.inMilliseconds ~/ 2)),
    vsync: this,
  );

  late final Animation<double> _expandDetailPanel =
      Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(
    parent: _controller,
    curve: const Interval(0, 0.75, curve: Curves.bounceOut),
    reverseCurve:
        const Interval(0.0, 0.75, curve: Curves.fastEaseInToSlowEaseOut).flipped,
  ));
  
  late final _colorTween = ColorTween(
    begin: widget.backgroundColor,
    end: widget.detailPanelColor,
  ).animate(CurvedAnimation(
    parent: _controller,
    curve: colorForwardCurve,
    reverseCurve: colorReverseCurve,
  ));
  
  late final _opacityTween =
      Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(
    parent: _controller,
    curve: colorForwardCurve,
    reverseCurve: colorReverseCurve,
  ));

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> toggleState() async {
    setState(() {
      isOpen = !isOpen;
    });

    try {
      if (isOpen) {
        await _controller.forward().orCancel;
      } else {
        await _controller.reverse().orCancel;
      }
    } on TickerCanceled {
      // The animation got canceled, probably because it was disposed of.
    }
  }

  Size _textSize(String text, TextStyle style) {
    final TextPainter textPainter = TextPainter(
        text: TextSpan(text: text, style: style),
        maxLines: 1,
        textDirection: TextDirection.ltr)
      ..layout(minWidth: 0, maxWidth: double.infinity);
    return textPainter.size;
  }

  @override
  Widget build(BuildContext context) {
    final subHeadingStyle = Theme.of(context).textTheme.bodyMedium;
    final headingStyle = Theme.of(context).textTheme.headlineSmall;
    final setEntryStyle = Theme.of(context).textTheme.bodyMedium;

    final cardHeightClosed = max(
        _textSize(widget.workoutExercise.exercise.name, headingStyle!).height +
            widget.inset +
            _textSize('dummy string', subHeadingStyle!).height +
            widget.inset,
        widget.workoutExercise.sets.length *
            _textSize('1 dummy entry', setEntryStyle!).height);

    return GestureDetector(
      onTap: () {
        toggleState();
      },
      child: Card.outlined(
        margin: EdgeInsets.zero,
        clipBehavior: Clip.hardEdge,
        child: Stack(
          children: [
            Column(
              children: [
                Card.outlined(
                  elevation: 0,
                  margin: EdgeInsets.zero,
                  child: AnimatedBuilder(
                    animation: _expandDetailPanel,
                    builder: (BuildContext context, Widget? child) {
                      return SizedBox(
                        height: _expandDetailPanel.value * cardHeightClosed,
                      );
                    },
                  ),
                ),
                Card(
                  shape: ContinuousRectangleBorder(
                      side: BorderSide(
                    color: widget.detailPanelColor,
                    width: 1,
                  )),
                  color: _colorTween.value,
                  clipBehavior: Clip.hardEdge,
                  elevation: 0,
                  margin: EdgeInsets.zero,
                  child: AnimatedBuilder(
                    key: UniqueKey(),
                    animation: _expandDetailPanel,
                    builder: (BuildContext context, Widget? child) {
                      return Container(
                        key: UniqueKey(),
                        height: _expandDetailPanel.value * chartHeightOpen +
                            cardHeightClosed +
                            widget.inset / 2,
                        color: _colorTween.value,
                        child: Padding(
                          key: UniqueKey(),
                          padding: EdgeInsets.all(widget.inset),
                          child: Opacity(
                              key: UniqueKey(),
                              opacity: _opacityTween.value *
                                      chartOpacityRangeSize +
                                  chartOpacityBackground,
                              child: SimpleTimeSeriesChart(
                                key: UniqueKey(),
                                widget.workoutExercise.exercise.id,
                                showAxis: isOpen,
                                animation: _opacityTween.value,
                              )),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(
                  widget.inset, widget.inset, widget.inset, widget.inset),
              child: Row(
                key: UniqueKey(),
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        widget.workoutExercise.exercise.name,
                        style: headingStyle,
                        overflow: TextOverflow.ellipsis,
                      ),
                      widget.workoutExercise.isComplete
                          ? Row(
                              key: UniqueKey(),
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.check,
                                  size: 16,
                                ),
                                const SizedBox(
                                  width: 8,
                                ),
                                Text(
                                  widget.workoutExercise.sets.last.finishedAt
                                      .getRelativeDateString(),
                                  style: subHeadingStyle,
                                ),
                              ],
                            )
                          : const Text("in progress"),
                    ],
                  ),
                  Expanded(
                      flex: 3,
                      child: SetsListView(
                        widget.workoutExercise.sets,
                        itemStyle: setEntryStyle,
                      )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
