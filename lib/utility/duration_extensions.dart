extension DurationExtensions on Duration {
  String getDurationString() {
    return '$inMinutes:${(inSeconds - inMinutes * 60).toString().padLeft(2, '0')}';
  }
}