import 'package:mockito/mockito.dart';
import 'package:taskmaster/timezone_helper.dart';
import 'package:timezone/data/latest.dart' as latest;
import 'package:timezone/timezone.dart' as tz;

class MockTimezoneHelper extends Fake implements TimezoneHelper {
  Future<void> configureLocalTimeZone() async {
    latest.initializeTimeZones();
    String timezone = "America/Los_Angeles";
    tz.setLocalLocation(tz.getLocation(timezone));
  }

  tz.TZDateTime getLocalTime(DateTime dateTime) {
    return tz.TZDateTime.from(dateTime, tz.local);
  }
}