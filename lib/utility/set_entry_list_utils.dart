import 'package:workout_tracker/domain/set_entry.dart';

typedef SetEntryValue = double Function(SetEntry);
typedef ValueAccumulator<T, V> = T? Function(List<V>?, SetEntryValue);

class SetEntryListUtils {
  static ValueAccumulator<double, SetEntry> average = (entry, valueFunc) =>
      entry!.fold(0.0, (prev, se) => valueFunc(se) + prev) / entry.length;

  static ValueAccumulator<double, SetEntry> min =
      (entry, valueFunc) => entry?.fold(double.infinity, (prev, curr) {
            final currRM = valueFunc(curr);

            return currRM < prev! ? currRM : prev;
          });

  static ValueAccumulator<double, SetEntry> max =
      (entry, valueFunc) => entry?.fold(0.0, (prev, curr) {
            final currRM = valueFunc(curr);

            return currRM > prev! ? currRM : prev;
          });

  static ValueAccumulator<double, SetEntry> sum = (entry, valueFunc) =>
      entry?.fold(0.0, (prev, se) => prev! + valueFunc(se));
}

extension ExerciseSetsTrend on Map<DateTime, List<SetEntry>>? {
  Map<DateTime, double?> trend(SetEntryValue valueFunc, ValueAccumulator<double, SetEntry> setValueAccumulator, {int windowSize = 5}) =>
      this!.keys.fold(
          (window: <double>[], index: 0, trend: <DateTime, double?>{}), (({
                List<double> window,
                int index,
                Map<DateTime, double?> trend
              }) prev,
              curr) {
        var currWindow = <double>[
          ...prev.window.skip(prev.index > windowSize ? 1 : 0),
          setValueAccumulator(this?[curr], valueFunc) ?? 0
        ];

        return (
          window: currWindow,
          index: prev.index + 1,
          trend: <DateTime, double?>{
            ...prev.trend,
            curr: (prev.index >= windowSize)
                ? currWindow.fold(0.0, (p, c) => p + c) / windowSize
                : null
          }
        );
      }).trend;
}
