enum ExerciseChartType {
  oneRM(label: '1 RM'),
  totalWeight(label: 'Total Weight'),
  totalWeightPerSet(label: 'Weight Per Set');

  const ExerciseChartType({required this.label});

  final String label;
}
