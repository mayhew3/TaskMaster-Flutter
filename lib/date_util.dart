
import 'package:intl/intl.dart';
import 'package:jiffy/jiffy.dart';

class DateUtil {

  static String formatShortMaybeHidingYear(DateTime? dateTime) {
    if (dateTime == null) {
      return 'N/A';
    }
    int thisYear = DateTime.now().year;

    DateFormat dateFormat = dateTime.year == thisYear ?
                          DateFormat('M/d') :
                          DateFormat('M/d/yyyy');
    return dateFormat.format(dateTime);
  }

  static String formatMediumMaybeHidingYear(DateTime? dateTime) {
    if (dateTime == null) {
      return 'N/A';
    }
    int thisYear = DateTime.now().year;

    DateFormat dateFormat = dateTime.year == thisYear ?
                          DateFormat('EEE MMM d') :
                          DateFormat('EEE MMM d yyyy');
    return dateFormat.format(dateTime);
  }

  static DateTime adjustToDate(DateTime dateTime, int recurNumber, String recurUnit) {
    switch (recurUnit) {
      case 'Days': return Jiffy(dateTime).add(days: recurNumber).dateTime;
      case 'Weeks': return Jiffy(dateTime).add(weeks: recurNumber).dateTime;
      case 'Months': return Jiffy(dateTime).add(months: recurNumber).dateTime;
      case 'Years': return Jiffy(dateTime).add(years: recurNumber).dateTime;
      default: throw new Exception('Unknown recur_unit');
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