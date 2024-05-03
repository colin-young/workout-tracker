enum ExerciseChartType {
  oneRM(label: '1 RM'),
  totalWeight(label: 'Total weight'),
  totalWeightPerSet(label: 'Weight per set');

  const ExerciseChartType({required this.label});

  final String label;
}
