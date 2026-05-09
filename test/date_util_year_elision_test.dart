import 'package:flutter_test/flutter_test.dart';
import 'package:taskmaestro/date_util.dart';

/// Tests for `DateUtil.formatMonthDayMaybeYearShort` and
/// `formatMonthDayMaybeYearLong` — the year-eliding helpers used by the
/// expanded task card and the dates popup. Same-year dates render
/// compact (e.g. "Apr 18" / "April 18"); other-year dates surface the
/// year so users can tell archived items apart from current ones at a
/// glance.

void main() {
  group('DateUtil.formatMonthDayMaybeYearShort', () {
    test('Same-year date omits the year token', () {
      final thisYear = DateTime.now().year;
      final d = DateTime(thisYear, 4, 18);
      final out = DateUtil.formatMonthDayMaybeYearShort(d);
      expect(out, contains('Apr'));
      expect(out, contains('18'));
      // Year should NOT appear in the rendered string.
      expect(out, isNot(contains('$thisYear')));
    });

    test('Different-year date includes the year token', () {
      final pastYear = DateTime.now().year - 3;
      final d = DateTime(pastYear, 4, 18);
      final out = DateUtil.formatMonthDayMaybeYearShort(d);
      expect(out, contains('Apr'));
      expect(out, contains('18'));
      expect(out, contains('$pastYear'));
    });

    test('UTC input is rendered against local-time year', () {
      // A UTC instant whose local-time year matches the current year
      // should render without a year regardless of how `DateTime.now()`
      // compares to the raw UTC date.
      final thisYear = DateTime.now().year;
      final d = DateTime.utc(thisYear, 4, 18, 12, 0);
      final out = DateUtil.formatMonthDayMaybeYearShort(d);
      expect(out, isNot(contains('$thisYear')));
    });
  });

  group('DateUtil.formatMonthDayMaybeYearLong', () {
    test('Same-year date renders without year (e.g. "April 18")', () {
      final thisYear = DateTime.now().year;
      final d = DateTime(thisYear, 4, 18);
      final out = DateUtil.formatMonthDayMaybeYearLong(d);
      expect(out, contains('April'));
      expect(out, contains('18'));
      expect(out, isNot(contains('$thisYear')));
    });

    test('Different-year date renders WITH year (e.g. "April 18, 2025")',
        () {
      final pastYear = DateTime.now().year - 5;
      final d = DateTime(pastYear, 4, 18);
      final out = DateUtil.formatMonthDayMaybeYearLong(d);
      expect(out, contains('April'));
      expect(out, contains('18'));
      expect(out, contains('$pastYear'));
    });

    test('Future-year date also surfaces the year', () {
      final futureYear = DateTime.now().year + 5;
      final d = DateTime(futureYear, 4, 18);
      final out = DateUtil.formatMonthDayMaybeYearLong(d);
      expect(out, contains('$futureYear'));
    });
  });
}
