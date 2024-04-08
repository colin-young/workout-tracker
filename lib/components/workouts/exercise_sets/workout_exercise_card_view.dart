import 'dart:math';

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
        inset: inset, workoutExercise: workoutExercise);
  }
}

class ClosedWorkoutExerciseCard extends StatefulWidget {
  const ClosedWorkoutExerciseCard(
      {super.key,
      required this.inset,
      required this.workoutExercise,
      this.chartHeight = 160,
      this.animationDuration = const Duration(milliseconds: 500),
      this.chartOpacityBackground = 0.125});

  final double inset;
  final ExerciseSets workoutExercise;
  final Duration animationDuration;
  final double chartOpacityBackground;
  final int chartHeight;

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
  late final AnimationController _controller = AnimationController(
    duration: widget.animationDuration,
    vsync: this,
  );
  late final Animation<double> _hideOnOpenAnimation = CurvedAnimation(
    parent: _controller,
    curve: Curves.fastOutSlowIn,
  );

  @override
  void initState() {
    super.initState();
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  toggleState() {
    setState(() {
      isOpen = !isOpen;
    });

    if (!isOpen) {
      _controller.forward();
    } else {
      _controller.reverse();
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

    final cardHeadersHeight =
        _textSize(widget.workoutExercise.exercise.name, headingStyle!).height +
            widget.inset +
            _textSize(
                    'dummy string',
                    subHeadingStyle!)
                .height +
            widget.inset;
    final setsListHeight = widget.workoutExercise.sets.length *
        _textSize('1 dummy entry', setEntryStyle!).height;
    final cardHeightClosed =
        max(cardHeadersHeight, setsListHeight) + widget.inset;

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
                    animation: _hideOnOpenAnimation,
                    builder: (BuildContext context, Widget? child) {
                      return SizedBox(
                        height: (1.0 - _hideOnOpenAnimation.value) *
                            (_textSize(widget.workoutExercise.exercise.name,
                                        headingStyle)
                                    .height +
                                widget.inset +
                                widget.inset),
                      );
                    },
                  ),
                ),
                Card(
                  elevation: 0,
                  margin: EdgeInsets.zero,
                  child: AnimatedBuilder(
                    animation: _hideOnOpenAnimation,
                    builder: (BuildContext context, Widget? child) {
                      return SizedBox(
                        height: (1.0 - _hideOnOpenAnimation.value) * chartHeightOpen +
                            cardHeightClosed,
                        child: Padding(
                          padding: EdgeInsets.all(widget.inset),
                          child: Opacity(
                              opacity: (1.0 - _hideOnOpenAnimation.value) *
                                      chartOpacityRangeSize +
                                  chartOpacityBackground,
                              child: SimpleTimeSeriesChart(
                                widget.workoutExercise.exercise.id,
                                animate: true,
                                showAxis: isOpen ? true : false,
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
