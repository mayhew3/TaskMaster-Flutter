import 'package:flutter_test/flutter_test.dart';
import 'package:taskmaestro/models/task_list_view.dart';

void main() {
  group('TaskFilters', () {
    test('empty() produces a pass-through filter', () {
      final f = TaskFilters.empty();
      expect(f.areas, isEmpty);
      expect(f.contexts, isEmpty);
      expect(f.dueStatus, isEmpty);
      expect(f.minPriority, null);
      expect(f.maxPriority, null);
      expect(f.minPoints, null);
      expect(f.maxPoints, null);
      expect(f.minDuration, null);
      expect(f.maxDuration, null);
      expect(f.recurrence, RecurrenceFilter.all);
      expect(f.maxAgeDays, null);
      expect(f.ownedByMeOnly, false);
      expect(f.search, '');
    });

    test('rebuild mutates a single axis without touching the rest', () {
      final base = TaskFilters.empty();
      final next = base.rebuild((b) => b
        ..minPriority = 2
        ..maxPriority = 4);
      expect(next.minPriority, 2);
      expect(next.maxPriority, 4);
      // Everything else still at default.
      expect(next.recurrence, RecurrenceFilter.all);
      expect(next.dueStatus, isEmpty);
      // Built-value equality: base unchanged.
      expect(base.minPriority, null);
    });

    test('toJson → fromJson round-trip preserves every field', () {
      final original = TaskFilters((b) => b
        ..areas.replace({'Work', 'Home'})
        ..contexts.replace({'Phone'})
        ..dueStatus.replace({DueStatusBucket.urgent, DueStatusBucket.pastDue})
        ..minPriority = 1
        ..maxPriority = 5
        ..minPoints = 2
        ..maxPoints = 13
        ..minDuration = 15
        ..maxDuration = 240
        ..recurrence = RecurrenceFilter.scheduled
        ..maxAgeDays = 30
        ..ownedByMeOnly = true
        ..search = 'demo');
      final roundTripped = TaskFilters.fromJson(original.toJson());
      expect(roundTripped, original);
    });

    test('fromJson tolerates unknown enum names by falling back to defaults',
        () {
      final f = TaskFilters.fromJson({
        'recurrence': 'martian',
        'dueStatus': ['urgent', 'cosmic'],
      });
      expect(f.recurrence, RecurrenceFilter.all);
      // Unknown bucket is dropped silently; known one survives.
      expect(f.dueStatus, {DueStatusBucket.urgent});
    });

    test('fromJson tolerates wrong types for primitive fields', () {
      final f = TaskFilters.fromJson({
        'minPriority': 'banana',
        'ownedByMeOnly': 'true', // String, not bool
        'search': 42, // int, not String
      });
      expect(f.minPriority, null);
      expect(f.ownedByMeOnly, false);
      expect(f.search, '');
    });
  });

  group('TaskListView', () {
    test('tasksDefault pre-populates dueStatus to hide scheduled + completed',
        () {
      final v = TaskListView.tasksDefault();
      expect(v.groupAxis, TaskGroupAxis.dueStatus);
      // Urgency is the default sort across all surfaces — surfaces what's
      // most pressing first within each due-status bucket.
      expect(v.sortAxis, TaskSortAxis.urgency);
      expect(v.sortDirection, SortDirection.ascending);
      // Whitelist of four "actionable" buckets — matches pre-TM-359's
      // hide-scheduled / hide-completed defaults.
      expect(v.filters.dueStatus, {
        DueStatusBucket.pastDue,
        DueStatusBucket.urgent,
        DueStatusBucket.target,
        DueStatusBucket.normal,
      });
      expect(v.collapsedGroups, isEmpty);
    });

    test('sprintDefault groups by due status + urgency sort', () {
      final v = TaskListView.sprintDefault();
      expect(v.groupAxis, TaskGroupAxis.dueStatus);
      expect(v.sortAxis, TaskSortAxis.urgency);
      expect(v.sortDirection, SortDirection.ascending);
      // Empty filter = no whitelist applied, every bucket visible.
      expect(v.filters.dueStatus, isEmpty);
    });

    test('familyDefault matches tasksDefault (same UX shell)', () {
      expect(TaskListView.familyDefault(), TaskListView.tasksDefault());
    });

    test('planDefault has empty dueStatus (every eligible task visible)',
        () {
      final v = TaskListView.planDefault();
      expect(v.filters.dueStatus, isEmpty);
      expect(v.sortAxis, TaskSortAxis.urgency);
    });

    test('defaultForSurface dispatches correctly', () {
      expect(TaskListView.defaultForSurface(TaskListSurface.tasks),
          TaskListView.tasksDefault());
      expect(TaskListView.defaultForSurface(TaskListSurface.family),
          TaskListView.familyDefault());
      expect(TaskListView.defaultForSurface(TaskListSurface.sprint),
          TaskListView.sprintDefault());
      expect(TaskListView.defaultForSurface(TaskListSurface.plan),
          TaskListView.planDefault());
    });

    test('toJson → fromJson round-trip preserves every field', () {
      final original = TaskListView((b) => b
        ..groupAxis = TaskGroupAxis.area
        ..sortAxis = TaskSortAxis.priority
        ..sortDirection = SortDirection.ascending
        ..filters.replace(TaskFilters((f) => f
          ..areas.add('Work')
          ..minPriority = 3))
        ..collapsedGroups.replace({'due:urgent', 'area:Home'}));
      final roundTripped = TaskListView.fromJson(
        original.toJson(),
        defaultView: TaskListView.tasksDefault(),
      );
      expect(roundTripped, original);
    });

    test('toJsonString → fromJsonString round-trip preserves every field', () {
      final original = TaskListView.sprintDefault().rebuild((b) => b
        ..groupAxis = TaskGroupAxis.priority
        ..collapsedGroups.add('priority:3'));
      final roundTripped = TaskListView.fromJsonString(
        original.toJsonString(),
        defaultView: TaskListView.sprintDefault(),
      );
      expect(roundTripped, original);
    });

    test('fromJson with malformed enum names falls back to defaultView', () {
      final def = TaskListView.tasksDefault();
      final v = TaskListView.fromJson(
        {
          'groupAxis': 'orbital',
          'sortAxis': 'flux',
          'sortDirection': 'sideways',
        },
        defaultView: def,
      );
      expect(v.groupAxis, def.groupAxis);
      expect(v.sortAxis, def.sortAxis);
      expect(v.sortDirection, def.sortDirection);
    });

    test('fromJsonString returns defaultView on parse failure', () {
      final def = TaskListView.tasksDefault();
      expect(TaskListView.fromJsonString('not json', defaultView: def), def);
      expect(TaskListView.fromJsonString('null', defaultView: def), def);
      expect(TaskListView.fromJsonString('[]', defaultView: def), def);
    });

    test('fromJson with missing filters key uses defaultView.filters', () {
      final def = TaskListView.sprintDefault();
      final v = TaskListView.fromJson(
        {'groupAxis': 'none'},
        defaultView: def,
      );
      // Sprint default has empty dueStatus → no filter, every bucket
      // visible (effectively the same UX as the old all-toggles-on).
      expect(v.filters.dueStatus, isEmpty);
    });

    test('rebuild keeps built-value equality semantics', () {
      final a = TaskListView.tasksDefault();
      final b = a.rebuild((b) => b.groupAxis = TaskGroupAxis.area);
      expect(a == b, false);
      final c = a.rebuild((b) => b.groupAxis = TaskGroupAxis.dueStatus);
      expect(a == c, true);
    });
  });
}
