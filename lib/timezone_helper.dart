import 'package:intl/intl.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_native_timezone/flutter_native_timezone.dart';

class TimezoneHelper {
  Future<void> configureLocalTimeZone() async {
    tz.initializeTimeZones();
    String timezone = await FlutterNativeTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timezone));
  }

  tz.TZDateTime getLocalTime(DateTime dateTime) {
    return tz.TZDateTime.from(dateTime, tz.local);
  }

  String getFormattedLocalTime(DateTime dateTime, String format) {
    return getFormattedLocalTimeFromFormat(dateTime, DateFormat(format));
  }

  String getFormattedLocalTimeFromFormat(DateTime dateTime, DateFormat dateFormat) {
    return dateFormat.format(getLocalTime(dateTime));
  }
}