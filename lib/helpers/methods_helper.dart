class MethodHelper {
  static String formatDuration(int totalSeconds) {
    const int secondsInMinute = 60;
    const int secondsInHour = 60 * secondsInMinute;
    const int secondsInDay = 24 * secondsInHour;
    const int secondsInMonth = 30 * secondsInDay; // Approximation
    const int secondsInYear = 12 * secondsInMonth; // Approximation

    int years = totalSeconds ~/ secondsInYear;
    totalSeconds %= secondsInYear;

    int months = totalSeconds ~/ secondsInMonth;
    totalSeconds %= secondsInMonth;

    int days = totalSeconds ~/ secondsInDay;
    totalSeconds %= secondsInDay;

    int hours = totalSeconds ~/ secondsInHour;
    totalSeconds %= secondsInHour;

    int minutes = totalSeconds ~/ secondsInMinute;
    int seconds = totalSeconds % secondsInMinute;

    // Build the result dynamically based on non-zero values
    List<String> parts = [];
    if (years > 0) parts.add('${years}y');
    if (months > 0) parts.add('${months}m');
    if (days > 0) parts.add('${days}d');
    if (hours > 0) parts.add('${hours}h');
    if (minutes > 0) parts.add('${minutes}m');
    if (seconds > 0) parts.add('${seconds}s');

    return parts.join('');
  }
}
