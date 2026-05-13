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
      expect(f.recurrence, RecurrenceFilter.all);
      expect(f.maxAgeDays, null);
      expect(f.ownedByMeOnly, false);
      expect(f.search, '');
      expect(f.showScheduled, false);
      expect(f.showCompleted, false);
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
      expect(next.showCompleted, false);
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
        ..recurrence = RecurrenceFilter.scheduled
        ..maxAgeDays = 30
        ..ownedByMeOnly = true
        ..search = 'demo'
        ..showScheduled = true
        ..showCompleted = true);
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
        'showCompleted': 'true', // String, not bool
        'search': 42, // int, not String
      });
      expect(f.minPriority, null);
      expect(f.showCompleted, false);
      expect(f.search, '');
    });
  });

  group('TaskListView', () {
    test('tasksDefault matches the documented Tasks-tab baseline', () {
      final v = TaskListView.tasksDefault();
      expect(v.groupAxis, TaskGroupAxis.dueStatus);
      expect(v.sortAxis, TaskSortAxis.dateAdded);
      expect(v.sortDirection, SortDirection.descending);
      expect(v.filters.showCompleted, false);
      expect(v.filters.showScheduled, false);
      expect(v.collapsedGroups, isEmpty);
    });

    test('sprintDefault preserves TM-339 sprint-assignment-order intent', () {
      final v = TaskListView.sprintDefault();
      expect(v.groupAxis, TaskGroupAxis.none);
      // dueStatus sentinel = "use bucket's natural sort"; under groupAxis=none
      // the grouping pipeline falls through to insertion order (sprint
      // assignment).
      expect(v.sortAxis, TaskSortAxis.dueStatus);
      expect(v.filters.showCompleted, true);
      expect(v.filters.showScheduled, true);
    });

    test('familyDefault matches tasksDefault (same UX shell)', () {
      expect(TaskListView.familyDefault(), TaskListView.tasksDefault());
    });

    test('planDefault matches tasksDefault (history overlay is pipeline-side)',
        () {
      expect(TaskListView.planDefault(), TaskListView.tasksDefault());
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
      // Sprint default's showScheduled/showCompleted are both true.
      expect(v.filters.showScheduled, true);
      expect(v.filters.showCompleted, true);
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
