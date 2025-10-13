import 'package:mockito/mockito.dart';
import 'package:taskmaster/timezone_helper.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:intl/intl.dart';

class MockTimezoneHelper extends Fake implements TimezoneHelper {
  MockTimezoneHelper() {
    // Initialize timezone data synchronously in constructor
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('America/Los_Angeles'));
  }

  @override
  bool get timezoneInitialized => true;

  @override
  Future<void> configureLocalTimeZone() async {
    // Already initialized in constructor
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