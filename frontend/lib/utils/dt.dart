import 'package:intl/intl.dart';

class Dt {
  static final DateFormat ymd = DateFormat("yyyy-MM-dd");
  static final DateFormat hm = DateFormat("HH:mm");
  static final DateFormat ymdHm = DateFormat("yyyy-MM-dd HH:mm");

  static DateTime startOfDay(DateTime dt) => DateTime(dt.year, dt.month, dt.day);
  static DateTime endOfDay(DateTime dt) =>
      DateTime(dt.year, dt.month, dt.day, 23, 59, 59, 999);

  static DateTime startOfWeek(DateTime dt, {int weekStartsOn = DateTime.monday}) {
    final d = DateTime(dt.year, dt.month, dt.day);
    final diff = (d.weekday - weekStartsOn) % 7;
    return d.subtract(Duration(days: diff));
  }

  static DateTime endOfWeek(DateTime dt, {int weekStartsOn = DateTime.monday}) {
    final start = startOfWeek(dt, weekStartsOn: weekStartsOn);
    return DateTime(start.year, start.month, start.day)
        .add(const Duration(days: 7))
        .subtract(const Duration(milliseconds: 1));
  }
}
