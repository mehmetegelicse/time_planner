class TimePlannerDateTime {

  int day;

  /// Task will be begin at this hour
  int hour;

  /// Task will be begin at this minutes
  int minutes;

  TimePlannerDateTime({
    required this.day,
    required this.hour,
    required this.minutes,
  });

  bool isAfter(TimePlannerDateTime other) {
    return day > other.day || (day == other.day && hour > other.hour) ||
        (day == other.day && hour == other.hour && minutes > other.minutes);
  }

  bool isBefore(TimePlannerDateTime other) {
    return day < other.day || (day == other.day && hour < other.hour) ||
        (day == other.day && hour == other.hour && minutes < other.minutes);
  }

  bool isBeforeInDay(TimePlannerDateTime other) {
    return hour < other.hour || (hour == other.hour && minutes < other.minutes);
  }

  bool isAfterInDay(TimePlannerDateTime other) {
    return hour > other.hour || (hour == other.hour && minutes > other.minutes);
  }
}
