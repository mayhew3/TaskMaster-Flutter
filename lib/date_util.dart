
import 'package:jiffy/jiffy.dart';

class DateUtil {

  static DateTime adjustToDate(DateTime dateTime, int recurNumber, String recurUnit) {
    if (dateTime == null) {
      return null;
    }
    switch (recurUnit) {
      case 'Days': return Jiffy(dateTime).add(days: recurNumber);
      case 'Weeks': return Jiffy(dateTime).add(weeks: recurNumber);
      case 'Months': return Jiffy(dateTime).add(months: recurNumber);
      case 'Years': return Jiffy(dateTime).add(years: recurNumber);
      default: return null;
    }
  }

}