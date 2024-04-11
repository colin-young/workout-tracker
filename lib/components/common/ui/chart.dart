import 'package:community_charts_flutter/community_charts_flutter.dart'
    as charts;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workout_tracker/data/repositories/exercise_sets_repository.dart';
import 'package:workout_tracker/domain/set_entry.dart';
import 'package:collection/collection.dart';
import 'package:workout_tracker/utility/set_entry_list_utils.dart';

class ExerciseSummaryChart extends ConsumerWidget {
  final int exerciseId;
  final Animation<double> animation;
  final bool showAxis;
  final bool showRange;
  final bool showTrend;
  final SetEntryValue valueFunc;
  final ValueAccumulator<double, SetEntry> setValueAccumulator;
  final ValueAccumulator<double, SetEntry>? minFunc;
  final ValueAccumulator<double, SetEntry>? maxFunc;

  const ExerciseSummaryChart({
    super.key,
    required this.exerciseId,
    required this.animation,
    required this.showAxis,
    this.showRange = false,
    this.showTrend = false,

    /// A function that accumulates the value of all sets.
    required this.setValueAccumulator,

    /// A function that returns the value of a single set.
    required this.valueFunc,

    /// A function that returns the minimum of all sets.
    this.minFunc,

    /// A function that returns the maximum of all sets.
    this.maxFunc,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sets = ref.watch(
        getAllExerciseSetsByExerciseStreamProvider(exerciseId: exerciseId));

    final exercises = switch (sets) {
      AsyncData(:final value) =>
        groupBy(value.expand((element) => element.sets), (s) {
          return DateTime(
              s.finishedAt.year, s.finishedAt.month, s.finishedAt.day);
        }),
      _ => <DateTime, List<SetEntry>>{}
    };

    final data = exercises.keys
        .map((e) => TimeSeriesSets(
              time: e,
              value: setValueAccumulator(exercises[e], valueFunc),
              min: minFunc != null ? minFunc!(exercises[e], valueFunc) : null,
              max: maxFunc != null ? maxFunc!(exercises[e], valueFunc) : null,
            ))
        .toList();
    final trendData = showTrend
        ? exercises
            .trend(valueFunc, setValueAccumulator, windowSize: 5)
            .keys
            .map((t) => TimeSeriesSets(
                time: t, value: exercises.trend(valueFunc, setValueAccumulator, windowSize: 5)[t]))
            .toList()
        : null;

    return SimpleTimeSeriesChart(
      data: data,
      trend: trendData,
      exerciseId,
      animate: false,
      animation: animation.value,
      showAxis: showAxis,
      showRange: showRange,
    );
  }
}

class SimpleTimeSeriesChart extends ConsumerWidget {
  final int exerciseId;
  final bool? animate;
  final bool showAxis;
  final double animation;
  final List<TimeSeriesSets> data;
  final List<TimeSeriesSets>? trend;
  final bool showRange;

  const SimpleTimeSeriesChart(this.exerciseId,
      {super.key,
      required this.data,
      this.trend,
      this.animate = false,
      this.showAxis = true,
      this.showRange = false,
      this.animation = 1.0});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dataSeries = [
      charts.Series<TimeSeriesSets, DateTime>(
        id: 'Sets',
        colorFn: (_, __) => charts.ColorUtil.fromDartColor(
            Theme.of(context).colorScheme.primary),
        domainFn: (TimeSeriesSets sets, _) => sets.time,
        measureFn: (TimeSeriesSets sets, _) => sets.value,
        measureLowerBoundFn: (TimeSeriesSets sets, _) =>
            showRange ? sets.min : null,
        measureUpperBoundFn: (TimeSeriesSets sets, _) =>
            showRange ? sets.max : null,
        data: data,
      ),
    ];
    final trendSeries = trend != null
        ? [
            charts.Series<TimeSeriesSets, DateTime>(
              id: 'Trend',
              colorFn: (_, __) => charts.ColorUtil.fromDartColor(
                  Theme.of(context).colorScheme.primary.withOpacity(0.5)),
              domainFn: (TimeSeriesSets sets, _) => sets.time,
              measureFn: (TimeSeriesSets sets, _) => sets.value,
              data: trend!,
            )..setAttribute(charts.rendererIdKey, 'trend')
          ]
        : <charts.Series<TimeSeriesSets, DateTime>>[];

    final rangeSeries = [
      charts.Series<TimeSeriesSets, DateTime>(
        id: 'Max',
        colorFn: (_, __) => charts.ColorUtil.fromDartColor(showAxis
            ? Theme.of(context).colorScheme.onBackground
            : Colors.transparent),
        domainFn: (TimeSeriesSets sets, _) => sets.time,
        measureFn: (TimeSeriesSets sets, _) => sets.max! - sets.min!,
        labelAccessorFn: (TimeSeriesSets sets, _) => '${sets.max! - sets.min!}',
        data: data,
      )..setAttribute(charts.rendererIdKey, 'rangeCap'),
      charts.Series<TimeSeriesSets, DateTime>(
        id: 'Min',
        colorFn: (_, __) => charts.ColorUtil.fromDartColor(showAxis
            ? Theme.of(context).colorScheme.onBackground
            : Colors.transparent),
        domainFn: (TimeSeriesSets sets, _) => sets.time,
        measureFn: (TimeSeriesSets sets, _) => sets.min,
        data: data,
      )..setAttribute(charts.rendererIdKey, 'rangeCap'),
      charts.Series<TimeSeriesSets, DateTime>(
        id: 'MaxBar',
        colorFn: (_, __) => charts.ColorUtil.fromDartColor(
            Theme.of(context).colorScheme.onBackground.withOpacity(animation)),
        domainFn: (TimeSeriesSets sets, _) => sets.time,
        measureFn: (TimeSeriesSets sets, _) => sets.max! - sets.min!,
        data: data,
      )..setAttribute(charts.rendererIdKey, 'rangeBar'),
      charts.Series<TimeSeriesSets, DateTime>(
        id: 'MinBar',
        colorFn: (_, __) => charts.ColorUtil.fromDartColor(Colors.transparent),
        domainFn: (TimeSeriesSets sets, _) => sets.time,
        measureFn: (TimeSeriesSets sets, _) => sets.min,
        data: data,
      )..setAttribute(charts.rendererIdKey, 'rangeBar'),
    ];

    final series =
        // showRange
        // ? [...dataSeries, ...rangeSeries]
        [...dataSeries, ...trendSeries];

    return charts.TimeSeriesChart(
      series,
      animate: animate,
      animationDuration: const Duration(milliseconds: 100),
      dateTimeFactory: const charts.LocalDateTimeFactory(),
      domainAxis: charts.EndPointsTimeAxisSpec(
        renderSpec: charts.SmallTickRendererSpec(
            lineStyle: charts.LineStyleSpec(
              color: charts.ColorUtil.fromDartColor(Theme.of(context)
                  .colorScheme
                  .onBackground
                  .withOpacity(animation)),
            ),
            labelStyle: charts.TextStyleSpec(
                color: charts.ColorUtil.fromDartColor(Theme.of(context)
                    .colorScheme
                    .onBackground
                    .withOpacity(animation)))),
      ),
      primaryMeasureAxis: charts.NumericAxisSpec(
        renderSpec: charts.GridlineRendererSpec(
            lineStyle: charts.LineStyleSpec(
              color: charts.ColorUtil.fromDartColor(Theme.of(context)
                  .colorScheme
                  .onBackground
                  .withOpacity(animation * 0.25)),
            ),
            labelStyle: charts.TextStyleSpec(
                color: charts.ColorUtil.fromDartColor(Theme.of(context)
                    .colorScheme
                    .onBackground
                    .withOpacity(animation)))),
      ),
      customSeriesRenderers: [
        charts.LineRendererConfig(
            customRendererId: 'trend',
            dashPattern: [4, 4],
            strokeWidthPx: animation * 2),
        charts.BarRendererConfig(
          customRendererId: 'rangeBar',
          groupingType: charts.BarGroupingType.stacked,
          maxBarWidthPx: 2,
        ),
        charts.BarTargetLineRendererConfig(
          customRendererId: 'rangeCap',
          groupingType: charts.BarGroupingType.stacked,
          strokeWidthPx: 2,
          maxBarWidthPx: 6,
          roundEndCaps: false,
        ),
      ],
    );
  }
}

class TimeSeriesSets {
  final DateTime time;
  final double? value;
  final double? min;
  final double? max;

  TimeSeriesSets({required this.time, this.value, this.min, this.max});
}
