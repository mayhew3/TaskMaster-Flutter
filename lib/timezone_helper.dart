import 'package:intl/intl.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_native_timezone/flutter_native_timezone.dart';

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
    String timezone = await FlutterNativeTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timezone));
    _timezoneInitialized = true;
  }

  tz.TZDateTime getLocalTime(DateTime dateTime) {
    if (!_timezoneInitialized) {
      throw new Exception("Cannot get local time before timezone is initialized.");
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