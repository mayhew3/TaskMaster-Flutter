import 'package:flutter_test/flutter_test.dart';
import 'package:taskmaestro/models/task_item.dart';

/// Tests for TM-358 priority scale versioning. Legacy rows (scale version
/// 1) stored priority on a 1–10 scale that the cards halved for a 0–5
/// display. Modern rows (scale version 2) keep priority on a 1–5 scale
/// and render directly.
TaskItem _task({int? priority, int scaleVersion = 1}) {
  return TaskItem((b) => b
    ..docId = 'a'
    ..dateAdded = DateTime.utc(2026, 1, 1)
    ..personDocId = 'p'
    ..name = 'a'
    ..priority = priority
    ..priorityScaleVersion = scaleVersion
    ..offCycle = false
    ..completionDate = null
    ..retired = null);
}

void main() {
  group('TaskItem.displayPriority', () {
    test('null priority returns null regardless of scale version', () {
      expect(_task(priority: null, scaleVersion: 1).displayPriority, isNull);
      expect(_task(priority: null, scaleVersion: 2).displayPriority, isNull);
    });

    test('scale version 2 returns priority unchanged', () {
      for (final p in [1, 2, 3, 4, 5]) {
        expect(_task(priority: p, scaleVersion: 2).displayPriority, p);
      }
    });

    test('scale version 1 halves priority and clamps to 1..5', () {
      // Mirrors the card formula: (p / 2).round().clamp(1, 5).
      // Dart's `num.round()` rounds halves *away from zero*, so 2.5 → 3,
      // 4.5 → 5, etc. (Not banker's rounding.)
      final cases = <int, int>{
        1: 1, // (0.5).round() = 1, clamped at 1 (still 1)
        2: 1,
        3: 2, // 1.5 → 2
        4: 2,
        5: 3, // 2.5 → 3
        6: 3,
        7: 4, // 3.5 → 4
        8: 4,
        9: 5, // 4.5 → 5
        10: 5,
        11: 5, // clamped at 5 in case data went over the legacy ceiling
      };
      cases.forEach((input, expected) {
        expect(_task(priority: input, scaleVersion: 1).displayPriority, expected,
            reason: 'priority=$input on scale 1 should normalize to $expected');
      });
    });

    test('priority of 0 or negative returns null on legacy scale', () {
      expect(_task(priority: 0, scaleVersion: 1).displayPriority, isNull);
      expect(_task(priority: -1, scaleVersion: 1).displayPriority, isNull);
    });

    test('priority of 0 or negative returns null on v2 scale too', () {
      // Symmetric handling: a stored 0 / negative is treated as "unset"
      // regardless of which scale version owns the row. Prior to TM-358
      // the v2 path returned 0 unchanged, which diverged from the legacy
      // path's "null = unset" semantics.
      expect(_task(priority: 0, scaleVersion: 2).displayPriority, isNull);
      expect(_task(priority: -3, scaleVersion: 2).displayPriority, isNull);
    });
  });

  group('TaskItem.createBlueprint', () {
    test('round-trips priorityScaleVersion through the blueprint', () {
      final task = _task(priority: 8, scaleVersion: 1);
      final bp = task.createBlueprint();
      expect(bp.priority, 8);
      expect(bp.priorityScaleVersion, 1);
    });
  });

  group('TaskItem.hasChanges', () {
    test('ignores scale-version-only differences', () {
      // `priorityScaleVersion` is a non-user-editable internal marker. The
      // edit screen's lazy migration bumps the version and rewrites the
      // user-visible `priority` value in the same step, so a "real" change
      // always surfaces through one of the user-editable fields. Surfacing
      // version-only diffs here would make a mid-flight migration look
      // like a pending edit and enable Save spuriously. See
      // `TaskAddEditScreen._initializeTask`.
      final legacy = _task(priority: 4, scaleVersion: 1);
      final migrated = _task(priority: 4, scaleVersion: 2);
      expect(legacy.hasChanges(migrated), isFalse);
    });
  });

  group('default scale version', () {
    test('newly built TaskItems default to scale version 1 (legacy)', () {
      // The built_value `_setDefaults` hook keeps the default conservative
      // so rows hydrated from pre-TM-358 storage / wire formats land on the
      // legacy scale unless the data explicitly says otherwise.
      final t = TaskItem((b) => b
        ..docId = 'a'
        ..dateAdded = DateTime.utc(2026, 1, 1)
        ..name = 'a'
        ..offCycle = false
        ..completionDate = null
        ..retired = null);
      expect(t.priorityScaleVersion, 1);
    });
  });
}
