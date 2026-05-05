import 'package:flutter_test/flutter_test.dart';
import 'package:taskmaestro/helpers/recurrence_formatter.dart';

void main() {
  group('RecurrenceFormatter.format', () {
    test('returns null when recurNumber is missing', () {
      expect(
        RecurrenceFormatter.format(recurNumber: null, recurUnit: 'Weeks'),
        isNull,
      );
    });

    test('returns null when recurUnit is missing or empty', () {
      expect(
        RecurrenceFormatter.format(recurNumber: 2, recurUnit: null),
        isNull,
      );
      expect(
        RecurrenceFormatter.format(recurNumber: 2, recurUnit: ''),
        isNull,
      );
    });

    test('returns null for non-positive recurNumber', () {
      expect(
        RecurrenceFormatter.format(recurNumber: 0, recurUnit: 'Weeks'),
        isNull,
      );
      expect(
        RecurrenceFormatter.format(recurNumber: -1, recurUnit: 'Weeks'),
        isNull,
      );
    });

    test('returns null for unrecognised units', () {
      expect(
        RecurrenceFormatter.format(recurNumber: 1, recurUnit: 'Decades'),
        isNull,
      );
    });

    test('singular form when recurNumber == 1', () {
      expect(
        RecurrenceFormatter.format(recurNumber: 1, recurUnit: 'Days'),
        'Every day',
      );
      expect(
        RecurrenceFormatter.format(recurNumber: 1, recurUnit: 'Weeks'),
        'Every week',
      );
      expect(
        RecurrenceFormatter.format(recurNumber: 1, recurUnit: 'Months'),
        'Every month',
      );
      expect(
        RecurrenceFormatter.format(recurNumber: 1, recurUnit: 'Years'),
        'Every year',
      );
    });

    test('plural form when recurNumber > 1', () {
      expect(
        RecurrenceFormatter.format(recurNumber: 3, recurUnit: 'Weeks'),
        'Every 3 weeks',
      );
      expect(
        RecurrenceFormatter.format(recurNumber: 14, recurUnit: 'Days'),
        'Every 14 days',
      );
    });

    test('appends "(after completion)" when recurWait is true', () {
      expect(
        RecurrenceFormatter.format(
          recurNumber: 3,
          recurUnit: 'Weeks',
          recurWait: true,
        ),
        'Every 3 weeks (after completion)',
      );
    });

    test('omits suffix when recurWait is false or null', () {
      expect(
        RecurrenceFormatter.format(
          recurNumber: 2,
          recurUnit: 'Months',
          recurWait: false,
        ),
        'Every 2 months',
      );
      expect(
        RecurrenceFormatter.format(recurNumber: 2, recurUnit: 'Months'),
        'Every 2 months',
      );
    });

    test('accepts singular and lowercased units', () {
      expect(
        RecurrenceFormatter.format(recurNumber: 2, recurUnit: 'day'),
        'Every 2 days',
      );
      expect(
        RecurrenceFormatter.format(recurNumber: 1, recurUnit: 'WEEK'),
        'Every week',
      );
    });
  });
}
