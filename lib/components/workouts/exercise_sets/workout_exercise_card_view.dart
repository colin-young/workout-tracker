import 'dart:math';

import 'package:flutter/material.dart';
import 'package:workout_tracker/components/common/ui/chart.dart';
import 'package:workout_tracker/components/common/ui/chart/exercise_chart_type.dart';
import 'package:workout_tracker/components/sets_list_view.dart';
import 'package:workout_tracker/domain/exercise_sets.dart';
import 'package:workout_tracker/utility/relative_date.dart';
import 'package:workout_tracker/utility/set_entry_list_utils.dart';
import 'package:workout_tracker/utility/set_entry_utils.dart';

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
      this.chartHeight = 240,
      this.animationDuration = const Duration(milliseconds: 1000),
      this.chartOpacityBackground = 0.125,
      this.chartType = ExerciseChartType.oneRM});

  final double inset;
  final ExerciseSets workoutExercise;
  final Duration animationDuration;
  final double chartOpacityBackground;
  final int chartHeight;
  final Color detailPanelColor;
  final Color backgroundColor;
  final ExerciseChartType chartType;

  @override
  State<ClosedWorkoutExerciseCard> createState() =>
      _ClosedWorkoutExerciseCardState();
}

class _ClosedWorkoutExerciseCardState extends State<ClosedWorkoutExerciseCard>
    with TickerProviderStateMixin {
  late final chartOpacityBackground = widget.chartOpacityBackground;
  late final chartOpacityRangeSize = 1 - widget.chartOpacityBackground;
  late final chartHeightOpen = widget.chartHeight;
  final chipLinePadding = 8.0;

  late ExerciseChartType chartType;
  late bool showRange = false;
  late bool showTrend = false;

  final chartTypes = {
    ExerciseChartType.oneRM: SetEntryUtils.oneRMEpley,
    ExerciseChartType.totalWeightPerSet: SetEntryUtils.totalWeightPerSet,
    ExerciseChartType.totalWeight: SetEntryUtils.totalWeightPerSet
  };

  final valueAccumulator = {
    ExerciseChartType.oneRM: SetEntryListUtils.average,
    ExerciseChartType.totalWeightPerSet: SetEntryListUtils.average,
    ExerciseChartType.totalWeight: SetEntryListUtils.sum
  };

  final minFunc = {
    ExerciseChartType.oneRM: SetEntryListUtils.min,
    ExerciseChartType.totalWeightPerSet: SetEntryListUtils.min,
    ExerciseChartType.totalWeight: null
  };

  final maxFunc = {
    ExerciseChartType.oneRM: SetEntryListUtils.max,
    ExerciseChartType.totalWeightPerSet: SetEntryListUtils.max,
    ExerciseChartType.totalWeight: null
  };

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
    curve: const Interval(0, 0.75, curve: Curves.fastEaseInToSlowEaseOut),
    reverseCurve:
        const Interval(0.0, 0.75, curve: Curves.fastEaseInToSlowEaseOut)
            .flipped,
  ));

  late final _opacityTween =
      Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(
    parent: _controller,
    curve: colorForwardCurve,
    reverseCurve: colorReverseCurve,
  ));

  @override
  void initState() {
    chartType = widget.chartType;
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
    var textTheme = Theme.of(context).textTheme;
    final subHeadingStyle = textTheme.bodyMedium;
    final headingStyle = textTheme.headlineSmall;
    final setEntryStyle = textTheme.bodyMedium;
    final chipTextStyle = textTheme.bodySmall!;

    const chipsHeight = 24.0;
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
                  shape: ContinuousRectangleBorder(
                      side: BorderSide(
                    color: widget.detailPanelColor,
                    width: 1,
                  )),
                  elevation: 0,
                  margin: EdgeInsets.zero,
                  child: AnimatedBuilder(
                    animation: _expandDetailPanel,
                    builder: (BuildContext context, Widget? child) {
                      return Column(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          SizedBox(
                            height: _expandDetailPanel.value * cardHeightClosed,
                            width: double.infinity,
                          ),
                        ],
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
                  clipBehavior: Clip.hardEdge,
                  elevation: 0,
                  margin: EdgeInsets.zero,
                  child: AnimatedBuilder(
                    key: UniqueKey(),
                    animation: _expandDetailPanel,
                    builder: (BuildContext context, Widget? child) {
                      return Stack(
                        children: [
                          SizedBox(
                            key: UniqueKey(),
                            height: _expandDetailPanel.value * chartHeightOpen +
                                cardHeightClosed +
                                widget.inset / 2,
                            child: Padding(
                              key: UniqueKey(),
                              padding: EdgeInsets.fromLTRB(
                                  widget.inset,
                                  chipsHeight + chipLinePadding,
                                  widget.inset,
                                  chipsHeight + chipLinePadding),
                              child: Opacity(
                                  key: UniqueKey(),
                                  opacity: _opacityTween.value *
                                          chartOpacityRangeSize +
                                      chartOpacityBackground,
                                  child: IgnorePointer(
                                    child: ExerciseSummaryChart(
                                      key: UniqueKey(),
                                      exerciseId:
                                          widget.workoutExercise.exercise.id,
                                      showAxis: isOpen,
                                      showRange: showRange,
                                      showTrend: showTrend,
                                      animation: _opacityTween,
                                      setValueAccumulator:
                                          valueAccumulator[chartType]!,
                                      valueFunc: chartTypes[chartType]!,
                                      minFunc: minFunc[chartType],
                                      maxFunc: maxFunc[chartType],
                                    ),
                                  )),
                            ),
                          ),
                          Positioned.fill(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                ScaleTransition(
                                  scale: _expandDetailPanel,
                                  child: Padding(
                                      padding: EdgeInsets.all(chipLinePadding),
                                      child: Center(
                                        child: SegmentedButton(
                                            segments: ExerciseChartType.values
                                                .map((e) => ButtonSegment<
                                                        ExerciseChartType>(
                                                      value: e,
                                                      label: Text(
                                                        e.label,
                                                        style: chipTextStyle,
                                                      ),
                                                    ))
                                                .toList(),
                                            selected: <ExerciseChartType>{
                                              chartType
                                            },
                                            onSelectionChanged:
                                                (Set<ExerciseChartType>
                                                    newSelection) {
                                              setState(() {
                                                chartType = newSelection.first;
                                              });
                                            }),
                                      )),
                                ),
                                Transform.scale(
                                  scale: _expandDetailPanel.value,
                                  child: Padding(
                                    padding: EdgeInsets.all(
                                        8.0 * _expandDetailPanel.value),
                                    child: ChartFeatureChips(
                                      setRangeState: (value) {
                                        setState(
                                          () {
                                            showRange = value;
                                          },
                                        );
                                      },
                                      setTrendState: (value) {
                                        setState(() {
                                          showTrend = value;
                                        });
                                      },
                                      showRange: showRange,
                                      showTrend: showTrend,
                                      chipTextStyle: chipTextStyle,
                                      hasRange: minFunc[chartType] != null,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
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

class ChartFeatureChips extends StatelessWidget {
  final void Function(bool) setRangeState;
  final void Function(bool) setTrendState;
  final bool showRange;
  final bool showTrend;
  final bool hasRange;
  final TextStyle chipTextStyle;

  const ChartFeatureChips({
    super.key,
    required this.setRangeState,
    required this.setTrendState,
    required this.showRange,
    required this.showTrend,
    required this.chipTextStyle,
    required this.hasRange,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      children: [
        FilterChip(
          label: Text('Range', style: chipTextStyle),
          onSelected: hasRange
              ? (bool value) {
                  setRangeState(value);
                }
              : null,
          selected: showRange,
        ),
        FilterChip(
          label: Text('Trend', style: chipTextStyle),
          onSelected: (bool value) {
            setTrendState(value);
          },
          selected: showTrend,
        ),
      ],
    );
  }
}
