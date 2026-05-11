import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:intl/intl.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class TimezoneHelper {
  bool _timezoneInitialized = false;

  static Future<TimezoneHelper> createLocal() async {
    var timezoneHelper = TimezoneHelper();
    await timezoneHelper.configureLocalTimeZone();
    return timezoneHelper;
  }

  bool get timezoneInitialized => _timezoneInitialized;

  Future<void> configureLocalTimeZone() async {
    tz.initializeTimeZones();
    // TM-361: flutter_timezone 5.x changed `getLocalTimezone()` to return
    // a `TimezoneInfo` object instead of a raw String. We want the IANA
    // identifier for tz.getLocation().
    final info = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(info.identifier));
    _timezoneInitialized = true;
  }

  tz.TZDateTime getLocalTime(DateTime dateTime) {
    if (!_timezoneInitialized) {
      throw Exception('Cannot get local time before timezone is initialized.');
    }
    return tz.TZDateTime.from(dateTime, tz.local);
  }

  String getFormattedLocalTime(DateTime dateTime, String format) {
    return getFormattedLocalTimeFromFormat(dateTime, DateFormat(format));
  }

  String getFormattedLocalTimeFromFormat(DateTime dateTime, DateFormat dateFormat) {
    return dateFormat.format(getLocalTime(dateTime));
  }
}