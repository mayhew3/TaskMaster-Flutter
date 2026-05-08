import 'package:flutter_test/flutter_test.dart';
import 'package:taskmaestro/features/shared/presentation/widgets/date_timeline_popup.dart';
import 'package:taskmaestro/models/task_date_type.dart';

/// Tests for `defaultDateForNewType`. The algorithm should pick a date
/// that respects the chronological-order constraint regardless of which
/// type was added first. Specifically, the user-reported regression in
/// TM-358 was: adding Start when Target/Urgent/Due already existed
/// placed Start after all three (violating Start ≤ Target etc.).
DateTime _at9am(int year, int month, int day) =>
    DateTime(year, month, day, 9);

Map<TaskDateType, DateTime?> _dates({
  DateTime? start,
  DateTime? target,
  DateTime? urgent,
  DateTime? due,
}) {
  return {
    TaskDateTypes.start: start,
    TaskDateTypes.target: target,
    TaskDateTypes.urgent: urgent,
    TaskDateTypes.due: due,
  };
}

void main() {
  group('defaultDateForNewType', () {
    group('only lower bound — adding a later type', () {
      test('Target with Start at May 1 → May 6 (lower + 5 days)', () {
        final result = defaultDateForNewType(
          type: TaskDateTypes.target,
          dates: _dates(start: _at9am(2026, 5, 1)),
        );
        expect(result, _at9am(2026, 5, 6));
      });

      test('Due with Urgent at May 14 → May 19', () {
        final result = defaultDateForNewType(
          type: TaskDateTypes.due,
          dates: _dates(urgent: _at9am(2026, 5, 14)),
        );
        expect(result, _at9am(2026, 5, 19));
      });

      test('Due uses the LATEST earlier date as lower bound, not earliest',
          () {
        // Multiple earlier types set; lower = latest of them = Urgent (May 14).
        final result = defaultDateForNewType(
          type: TaskDateTypes.due,
          dates: _dates(
            start: _at9am(2026, 5, 1),
            urgent: _at9am(2026, 5, 14),
          ),
        );
        expect(result, _at9am(2026, 5, 19));
      });
    });

    group('only upper bound — adding an earlier type', () {
      test('Start with Target at May 6 → May 1 (upper − 5 days)', () {
        final result = defaultDateForNewType(
          type: TaskDateTypes.start,
          dates: _dates(target: _at9am(2026, 5, 6)),
        );
        expect(result, _at9am(2026, 5, 1));
      });

      test(
          'Start with Target at May 3 → Apr 28 (upper − 5 days, crosses month)',
          () {
        final result = defaultDateForNewType(
          type: TaskDateTypes.start,
          dates: _dates(target: _at9am(2026, 5, 3)),
        );
        expect(result, _at9am(2026, 4, 28));
      });

      test(
          'TM-358 user bug: adding Start when Target+Urgent+Due exist '
          'lands Start before the EARLIEST later type', () {
        // Target=May 6, Urgent=May 14, Due=May 21. New Start should land
        // 5 days before May 6 (earliest later) = May 1, NOT after May 21.
        final result = defaultDateForNewType(
          type: TaskDateTypes.start,
          dates: _dates(
            target: _at9am(2026, 5, 6),
            urgent: _at9am(2026, 5, 14),
            due: _at9am(2026, 5, 21),
          ),
        );
        expect(result, _at9am(2026, 5, 1),
            reason:
                'Adding Start when later types exist must place it before the earliest of them — the old offset-based heuristic put it after Due.');
      });

      test('Urgent with Due at May 21 → May 16', () {
        final result = defaultDateForNewType(
          type: TaskDateTypes.urgent,
          dates: _dates(due: _at9am(2026, 5, 21)),
        );
        expect(result, _at9am(2026, 5, 16));
      });
    });

    group('both bounds — adding a middle type', () {
      test('Target between Start (May 1) and Due (May 21) → midpoint May 11',
          () {
        // Days diff = 20, midpoint = lower + 10 = May 11.
        final result = defaultDateForNewType(
          type: TaskDateTypes.target,
          dates: _dates(
            start: _at9am(2026, 5, 1),
            due: _at9am(2026, 5, 21),
          ),
        );
        expect(result, _at9am(2026, 5, 11));
      });

      test(
          'Urgent between Start (May 1) and Due (May 14) → midpoint truncates '
          'toward lower (May 7, not May 8)', () {
        // Days diff = 13, midpoint = lower + (13 ~/ 2) = lower + 6 = May 7.
        final result = defaultDateForNewType(
          type: TaskDateTypes.urgent,
          dates: _dates(
            start: _at9am(2026, 5, 1),
            due: _at9am(2026, 5, 14),
          ),
        );
        expect(result, _at9am(2026, 5, 7));
      });

      test('lower and upper on the same day → that same day', () {
        final result = defaultDateForNewType(
          type: TaskDateTypes.target,
          dates: _dates(
            start: _at9am(2026, 5, 8),
            due: _at9am(2026, 5, 8),
          ),
        );
        expect(result, _at9am(2026, 5, 8));
      });

      test('uses LATEST lower and EARLIEST upper when multiple are set', () {
        // For Urgent: lower = max(Start=May 1, Target=May 5) = May 5;
        // upper = Due (May 11); midpoint = May 5 + 3 = May 8.
        final result = defaultDateForNewType(
          type: TaskDateTypes.urgent,
          dates: _dates(
            start: _at9am(2026, 5, 1),
            target: _at9am(2026, 5, 5),
            due: _at9am(2026, 5, 11),
          ),
        );
        expect(result, _at9am(2026, 5, 8));
      });
    });

    group('no bounds — empty dates map', () {
      test('falls back to the supplied "today" provider, normalized to 9 AM',
          () {
        final fakeToday = DateTime(2026, 5, 7, 14, 35); // arbitrary time
        final result = defaultDateForNewType(
          type: TaskDateTypes.start,
          dates: _dates(),
          todayProvider: () => fakeToday,
        );
        expect(result, _at9am(2026, 5, 7));
      });

      test('default todayProvider is DateTime.now (smoke check)', () {
        // Without an override, `DateTime.now()` is the fallback. We assert
        // on a non-time-sensitive property (the 9 AM normalization) so this
        // test isn't subject to year-boundary flakes if the clock ticks
        // over between the call and the comparison. The deterministic
        // year/month/day behavior is already covered by the
        // injected-todayProvider test above.
        final result = defaultDateForNewType(
          type: TaskDateTypes.start,
          dates: _dates(),
        );
        expect(result.hour, 9);
      });
    });

    test('output is always at exactly 9:00:00.000', () {
      final result = defaultDateForNewType(
        type: TaskDateTypes.target,
        dates: _dates(start: DateTime(2026, 5, 1, 16, 47, 33)),
      );
      expect(result.hour, 9);
      expect(result.minute, 0);
      expect(result.second, 0);
      expect(result.millisecond, 0);
    });
  });
}
