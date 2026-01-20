import 'package:flutter_test/flutter_test.dart';
import 'package:jiffy/jiffy.dart';
import 'package:taskmaster/date_util.dart';

void main() {
  group('DateUtil UTC Handling Tests', () {
    test('Jiffy loses UTC flag when processing UTC dates', () {
      // Input: UTC DateTime
      final utcDate = DateTime.utc(2026, 1, 3, 0, 0);
      print('Input: $utcDate (isUtc: ${utcDate.isUtc})');
      expect(utcDate.isUtc, isTrue);

      // Process through Jiffy
      final jiffy = Jiffy.parseFromDateTime(utcDate);
      final result = jiffy.add(weeks: 1).dateTime;
      print('After Jiffy add: $result (isUtc: ${result.isUtc})');

      // This test documents the current (buggy) behavior
      // Jiffy does NOT preserve the UTC flag
      print('Jiffy preserves UTC: ${result.isUtc}');
    });

    test('combineDateAndTime correctly handles UTC inputs', () {
      // Simulate the bug scenario:
      // - dateToUse comes from date picker (local date Jan 2)
      // - timeToUse is a UTC DateTime (Jan 3 00:00 UTC = Jan 2 4pm PST)

      // Sprint endDate stored as UTC: Jan 3 midnight UTC = Jan 2 4pm PST
      final sprintEndUtc = DateTime.utc(2026, 1, 3, 0, 0);
      print('Sprint end (UTC): $sprintEndUtc');
      print('Sprint end (local): ${sprintEndUtc.toLocal()}');

      // Date picker returns local date (Jan 2 midnight local)
      final pickerDate = DateTime(2026, 1, 2, 0, 0);
      print('Picker date (local): $pickerDate');

      // Combine: take date from picker, time from sprint end
      final combined = DateUtil.combineDateAndTime(pickerDate, sprintEndUtc);
      print('Combined: $combined (isUtc: ${combined.isUtc})');
      print('Combined local time: ${combined.hour}:${combined.minute.toString().padLeft(2, '0')}');

      // The combined result should have:
      // - Date: Jan 2 (from picker)
      // - Time: 4pm (the LOCAL time from the UTC sprint end)
      expect(combined.year, equals(2026));
      expect(combined.month, equals(1));
      expect(combined.day, equals(2));
      expect(combined.hour, equals(sprintEndUtc.toLocal().hour),
          reason: 'Time should be extracted from local representation of UTC input');
      expect(combined.minute, equals(0));
    });

    test('adjustToDate loses UTC flag', () {
      final utcDate = DateTime.utc(2026, 1, 3, 0, 0);
      print('Input: $utcDate (isUtc: ${utcDate.isUtc})');

      final adjusted = DateUtil.adjustToDate(utcDate, 1, 'Weeks');
      print('Adjusted: $adjusted (isUtc: ${adjusted.isUtc})');

      // This documents the current behavior
      print('adjustToDate preserves UTC: ${adjusted.isUtc}');
    });

    test('demonstrates the compounding bug', () {
      // Simulate what happens over multiple sprint creations

      // Sprint 1 endDate (correctly stored as UTC)
      final sprint1End = DateTime.utc(2026, 1, 3, 0, 0); // Jan 3 midnight UTC = Jan 2 4pm PST
      print('Sprint 1 end (UTC): $sprint1End');
      print('Sprint 1 end (local): ${sprint1End.toLocal()}');

      // Creating Sprint 2: read sprint1End, process through adjustToDate
      final sprint2Start = sprint1End; // Start from previous end
      final sprint2EndViaJiffy = DateUtil.adjustToDate(sprint2Start, 1, 'Weeks');
      print('\nSprint 2 end after adjustToDate: $sprint2EndViaJiffy (isUtc: ${sprint2EndViaJiffy.isUtc})');

      // If this is LOCAL, when saved without .toUtc(), Firestore interprets as UTC
      // So the numeric values get saved as-is to Firestore
      print('If saved without .toUtc(), Firestore sees: Jan 10 ${sprint2EndViaJiffy.hour}:00 UTC');
    });
  });
}
