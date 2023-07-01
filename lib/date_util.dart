
import 'package:intl/intl.dart';
import 'package:jiffy/jiffy.dart';
import 'package:taskmaster/timezone_helper.dart';

class DateUtil {

  static TimezoneHelper timezoneHelper = new TimezoneHelper();

  static bool isSameDay(DateTime dateTime1, DateTime dateTime2) {
    var dateFormat = DateFormat.MMMd();
    var formattedDate1 = timezoneHelper.getFormattedLocalTimeFromFormat(dateTime1, dateFormat);
    var formattedDate2 = timezoneHelper.getFormattedLocalTimeFromFormat(dateTime2, dateFormat);
    return formattedDate1 == formattedDate2;
  }

  static String formatShortMaybeHidingYear(DateTime? dateTime) {
    if (dateTime == null) {
      return 'N/A';
    }
    int thisYear = DateTime.now().year;
    var localTime = timezoneHelper.getLocalTime(dateTime);

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
    int thisYear = DateTime.now().year;
    var localTime = timezoneHelper.getLocalTime(dateTime);

    DateFormat dateFormat = localTime.year == thisYear ?
                          DateFormat('EEE MMM d') :
                          DateFormat('EEE MMM d yyyy');
    return dateFormat.format(localTime);
  }

  static DateTime adjustToDate(DateTime dateTime, int recurNumber, String recurUnit) {
    switch (recurUnit) {
      case 'Days': return Jiffy(dateTime).add(days: recurNumber).dateTime;
      case 'Weeks': return Jiffy(dateTime).add(weeks: recurNumber).dateTime;
      case 'Months': return Jiffy(dateTime).add(months: recurNumber).dateTime;
      case 'Years': return Jiffy(dateTime).add(years: recurNumber).dateTime;
      default: throw new Exception('Unknown recur_unit: ' + recurUnit);
    }
  }

  static DateTime combineDateAndTime(DateTime dateToUse, DateTime timeToUse) {
    return new DateTime(dateToUse.year, dateToUse.month, dateToUse.day, timeToUse.hour, timeToUse.minute);
  }

  static DateTime withoutMillis(DateTime originalDate) {
    return Jiffy(originalDate).startOf(Units.SECOND).dateTime;
  }

  static DateTime withoutSeconds(DateTime originalDate) {
    return Jiffy(originalDate).startOf(Units.MINUTE).dateTime;
  }

}