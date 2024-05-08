import 'package:flutter/material.dart';
import 'package:workout_tracker/components/common/ui/chart.dart';
import 'package:workout_tracker/components/common/ui/wheel_picker/multi_digit_wheel.dart';
import 'package:workout_tracker/domain/set_entry.dart';
import 'package:workout_tracker/utility/constants.dart';
import 'package:workout_tracker/utility/set_entry_list_utils.dart';
import 'package:workout_tracker/utility/set_entry_utils.dart';

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
