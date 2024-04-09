import 'package:community_charts_flutter/community_charts_flutter.dart'
    as charts;
import 'package:community_charts_flutter/community_charts_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workout_tracker/data/repositories/exercise_sets_repository.dart';
import 'package:workout_tracker/domain/set_entry.dart';
import 'package:collection/collection.dart';
import 'dart:developer' as developer;

class SimpleTimeSeriesChart extends ConsumerWidget {
  final int exerciseId;
  final bool? animate;
  final bool showAxis;
  final double animation;

  const SimpleTimeSeriesChart(this.exerciseId,
      {super.key,
      this.animate = true,
      this.showAxis = true,
      this.animation = 1.0});

  double? average(List<SetEntry>? e, double Function(SetEntry) valueFunc) =>
      e != null
          ? e.fold(0.0, (prev, se) => valueFunc(se) + prev) / e.length
          : null;

  double? min(List<SetEntry>? e, double Function(SetEntry) valueFunc) =>
      e?.fold(double.infinity, (prev, curr) {
        final currRM = valueFunc(curr);

        return currRM < prev! ? currRM : prev;
      });

  double? max(List<SetEntry>? e, double Function(SetEntry) valueFunc) =>
      e?.fold(0.0, (prev, curr) {
        final currRM = valueFunc(curr);

        return currRM > prev! ? currRM : prev;
      });

  double oneRMEpley(SetEntry se) => se.weight * (1.0 + se.reps / 30.0);

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
              value: average(exercises[e], oneRMEpley),
              min: min(exercises[e], oneRMEpley),
              max: max(exercises[e], oneRMEpley),
            ))
        .toList();
    final dataSeries = [
      charts.Series<TimeSeriesSets, DateTime>(
        id: 'Sets',
        colorFn: (_, __) =>
            ColorUtil.fromDartColor(Theme.of(context).colorScheme.primary),
        domainFn: (TimeSeriesSets sets, _) => sets.time,
        measureFn: (TimeSeriesSets sets, _) => sets.value,
        data: data,
      ),
    ];
    final rangeSeries = [
      charts.Series<TimeSeriesSets, DateTime>(
        id: 'Max',
        colorFn: (_, __) => ColorUtil.fromDartColor(showAxis
            ? Theme.of(context).colorScheme.onBackground
            : Colors.transparent),
        domainFn: (TimeSeriesSets sets, _) => sets.time,
        measureFn: (TimeSeriesSets sets, _) => sets.max! - sets.min!,
        data: data,
      )..setAttribute(charts.rendererIdKey, 'rangeCap'),
      charts.Series<TimeSeriesSets, DateTime>(
        id: 'Min',
        colorFn: (_, __) => ColorUtil.fromDartColor(showAxis
            ? Theme.of(context).colorScheme.onBackground
            : Colors.transparent),
        domainFn: (TimeSeriesSets sets, _) => sets.time,
        measureFn: (TimeSeriesSets sets, _) => sets.min,
        data: data,
      )..setAttribute(charts.rendererIdKey, 'rangeCap'),
      charts.Series<TimeSeriesSets, DateTime>(
        id: 'MaxBar',
        colorFn: (_, __) => ColorUtil.fromDartColor(
            Theme.of(context).colorScheme.onBackground.withOpacity(animation)),
        domainFn: (TimeSeriesSets sets, _) => sets.time,
        measureFn: (TimeSeriesSets sets, _) => sets.max! - sets.min!,
        data: data,
      )..setAttribute(charts.rendererIdKey, 'rangeBar'),
      charts.Series<TimeSeriesSets, DateTime>(
        id: 'MinBar',
        colorFn: (_, __) => ColorUtil.fromDartColor(Colors.transparent),
        domainFn: (TimeSeriesSets sets, _) => sets.time,
        measureFn: (TimeSeriesSets sets, _) => sets.min,
        data: data,
      )..setAttribute(charts.rendererIdKey, 'rangeBar'),
    ];

    final series = [...dataSeries, ...rangeSeries];

    return IgnorePointer(
      child: charts.TimeSeriesChart(
        series,
        animate: animate,
        animationDuration: const Duration(milliseconds: 100),
        dateTimeFactory: const charts.LocalDateTimeFactory(),
        domainAxis: charts.EndPointsTimeAxisSpec(
            renderSpec: charts.SmallTickRendererSpec(
                lineStyle: charts.LineStyleSpec(
          color: ColorUtil.fromDartColor(Theme.of(context)
              .colorScheme
              .onBackground
              .withOpacity(animation)),
        ))),
        primaryMeasureAxis: charts.NumericAxisSpec(
          renderSpec: charts.SmallTickRendererSpec(
              lineStyle: charts.LineStyleSpec(
            color: ColorUtil.fromDartColor(Theme.of(context)
                .colorScheme
                .onBackground
                .withOpacity(animation)),
          )),
        ),
        customSeriesRenderers: [
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
      ),
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
