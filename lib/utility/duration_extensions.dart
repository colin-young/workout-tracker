extension DurationExtensions on Duration {
  String getDurationString() {
    return '$inMinutes:${inSeconds - inMinutes * 60}'; // NON-NLS
  }
}