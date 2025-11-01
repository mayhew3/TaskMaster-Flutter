
import 'package:intl/intl.dart';
import 'package:jiffy/jiffy.dart';

class DateUtil {

  static bool isSameDay(DateTime dateTime1, DateTime dateTime2) {
    var dateFormat = DateFormat.MMMd();
    var formattedDate1 = dateFormat.format(dateTime1.toLocal());
    var formattedDate2 = dateFormat.format(dateTime2.toLocal());
    return formattedDate1 == formattedDate2;
  }

  static String formatShortMaybeHidingYear(DateTime? dateTime) {
    if (dateTime == null) {
      return 'N/A';
    }
    int thisYear = DateTime.timestamp().year;
    var localTime = dateTime.toLocal();

    DateFormat dateFormat = localTime.year == thisYear ?
                          DateFormat('M/d') :
                          DateFormat('M/d/yyyy');
    return dateFormat.format(localTime);
  }

  static DateTime maxDate(Iterable<DateTime> dateTimes) {
    return dateTimes.reduce((a, b) => a.isAfter(b) ? a : b);
  }

  static String formatMediumMaybeHidingYear(DateTime? dateTime) {
    if (dateTime == null) {
      return 'N/A';
    }
    int thisYear = DateTime.timestamp().year;
    var localTime = dateTime.toLocal();

    DateFormat dateFormat = localTime.year == thisYear ?
                          DateFormat('EEE MMM d') :
                          DateFormat('EEE MMM d yyyy');
    return dateFormat.format(localTime);
  }

  static DateTime adjustToDate(DateTime dateTime, int recurNumber, String recurUnit) {
    switch (recurUnit) {
      case 'Days': return Jiffy.parseFromDateTime(dateTime).add(days: recurNumber).dateTime;
      case 'Weeks': return Jiffy.parseFromDateTime(dateTime).add(weeks: recurNumber).dateTime;
      case 'Months': return Jiffy.parseFromDateTime(dateTime).add(months: recurNumber).dateTime;
      case 'Years': return Jiffy.parseFromDateTime(dateTime).add(years: recurNumber).dateTime;
      default: throw Exception('Unknown recur_unit: $recurUnit');
    }
  }

  static DateTime combineDateAndTime(DateTime dateToUse, DateTime timeToUse) {
    return DateTime(dateToUse.year, dateToUse.month, dateToUse.day, timeToUse.hour, timeToUse.minute);
  }

  static DateTime withoutMillis(DateTime originalDate) {
    return Jiffy.parseFromDateTime(originalDate).startOf(Unit.second).dateTime;
  }

  static DateTime withoutSeconds(DateTime originalDate) {
    return Jiffy.parseFromDateTime(originalDate).startOf(Unit.minute).dateTime;
  }

  static DateTime nowUtcWithoutMillis() {
    return withoutMillis(DateTime.now().toUtc());
  }

}