extension RelativeDate on DateTime {
  String getRelativeDateString() {
    final DateTime now = DateTime.now();
    final Duration difference = now.difference(this);
    final int days = difference.inDays;
    final int hours = difference.inHours;
    final int minutes = difference.inMinutes;
    String displayValue = '';
    if (days > 15) {
      displayValue = '${difference.inDays ~/ 7} weeks ago';
    } else if (days == 1) {
      displayValue = 'Yesterday';
    } else if (days > 1) {
      displayValue = '$days days ago';
    } else if (hours == 1) {
      displayValue = 'An hour ago';
    } else if (hours >= 12 && now.day != day) {
      displayValue = 'Yesterday';
    } else if (hours > 1) {
      displayValue = '$hours hours ago';
    } else if (minutes == 1) {
      displayValue = 'A minute ago';
    } else if (minutes > 1) {
      displayValue = '$minutes minutes ago';
    } else {
      displayValue = 'Just now';
    }
    return displayValue;
  }
}
