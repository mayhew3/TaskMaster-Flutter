import 'package:mockito/mockito.dart';
import 'package:taskmaster/timezone_helper.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:intl/intl.dart';

class MockTimezoneHelper extends Fake implements TimezoneHelper {
  @override
  Future<void> configureLocalTimeZone() async {
    tz.initializeTimeZones();
    String timezone = 'America/Los_Angeles';
    tz.setLocalLocation(tz.getLocation(timezone));
  }

  @override
  tz.TZDateTime getLocalTime(DateTime dateTime) {
    return tz.TZDateTime.from(dateTime, tz.local);
  }

  @override
  String getFormattedLocalTime(DateTime dateTime, String format) {
    return getFormattedLocalTimeFromFormat(dateTime, DateFormat(format));
  }

  @override
  String getFormattedLocalTimeFromFormat(DateTime dateTime, DateFormat dateFormat) {
    return dateFormat.format(getLocalTime(dateTime));
  }
}