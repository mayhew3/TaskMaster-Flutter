import 'package:built_collection/built_collection.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taskmaestro/features/shared/logic/task_grouping.dart';
import 'package:taskmaestro/models/area.dart';
import 'package:taskmaestro/models/task_context.dart';
import 'package:taskmaestro/models/task_item.dart';
import 'package:taskmaestro/models/task_list_view.dart';

final _now = DateTime.utc(2025, 6, 15, 12);
final _dayAgo = _now.subtract(const Duration(days: 1));
final _hourAgo = _now.subtract(const Duration(hours: 1));
final _hourAhead = _now.add(const Duration(hours: 1));

TaskItem _t({
  String docId = 'a',
  String name = 'Task',
  String? area,
  int? priority,
  int? gamePoints,
  int? duration,
  DateTime? startDate,
  DateTime? targetDate,
  DateTime? urgentDate,
  DateTime? dueDate,
  DateTime? completionDate,
  DateTime? dateAdded,
  List<TaskContext> contexts = const [],
  String? recurrenceDocId,
}) {
  return TaskItem((b) => b
    ..docId = docId
    ..name = name
    ..personDocId = 'p'
    ..area = area
    ..priority = priority
    ..priorityScaleVersion = 2
    ..gamePoints = gamePoints
    ..duration = duration
    ..startDate = startDate
    ..targetDate = targetDate
    ..urgentDate = urgentDate
    ..dueDate = dueDate
    ..completionDate = completionDate
    ..dateAdded = dateAdded ?? _now.subtract(const Duration(days: 30))
    ..contexts = ListBuilder<TaskContext>(contexts)
    ..recurrenceDocId = recurrenceDocId
    ..retired = null
    ..offCycle = false
    ..skipped = false
    ..pendingCompletion = false);
}

TaskContext _ctx(String name) => TaskContext((b) => b..name = name);

Area _area(String name, int sortOrder) => Area((b) => b
  ..docId = 'area-$name'
  ..dateAdded = _now
  ..name = name
  ..sortOrder = sortOrder
  ..personDocId = 'p');

TaskListView _view({
  TaskGroupAxis groupAxis = TaskGroupAxis.dueStatus,
  TaskSortAxis sortAxis = TaskSortAxis.dueStatus,
  SortDirection sortDirection = SortDirection.descending,
  void Function(TaskFiltersBuilder)? filters,
}) {
  final f =
      filters == null ? TaskFilters.empty() : TaskFilters((b) => filters(b));
  return TaskListView((b) => b
    ..groupAxis = groupAxis
    ..sortAxis = sortAxis
    ..sortDirection = sortDirection
    ..filters.replace(f));
}

void main() {
  group('groupAndSortTasks — filter axis', () {
    test('empty filter is a pass-through', () {
      final tasks = [
        _t(docId: 'a', name: 'One'),
        _t(docId: 'b', name: 'Two'),
      ];
      final result = groupAndSortTasks(
          tasks: tasks, view: _view(groupAxis: TaskGroupAxis.none), now: _now);
      expect(result.single.tasks.length, 2);
    });

    test('areas filter limits to selected names; null area maps to ""', () {
      final tasks = [
        _t(docId: 'a', area: 'Work'),
        _t(docId: 'b', area: 'Home'),
        _t(docId: 'c', area: null),
      ];
      // Selecting only "Work" excludes Home and null.
      final r1 = groupAndSortTasks(
        tasks: tasks,
        now: _now,
        view: _view(
          groupAxis: TaskGroupAxis.none,
          filters: (b) => b.areas.add('Work'),
        ),
      );
      expect(r1.single.tasks.map((t) => t.docId), ['a']);
    });

    test('contexts filter is OR across the task\'s contexts', () {
      final tasks = [
        _t(docId: 'a', contexts: [_ctx('Phone'), _ctx('Computer')]),
        _t(docId: 'b', contexts: [_ctx('Errand')]),
        _t(docId: 'c'),
      ];
      final r = groupAndSortTasks(
        tasks: tasks,
        now: _now,
        view: _view(
          groupAxis: TaskGroupAxis.none,
          filters: (b) => b.contexts.add('Phone'),
        ),
      );
      expect(r.single.tasks.map((t) => t.docId), ['a']);
    });

    test('priority bounds are inclusive; null priority always excluded', () {
      final tasks = [
        _t(docId: 'a', priority: 1),
        _t(docId: 'b', priority: 3),
        _t(docId: 'c', priority: 5),
        _t(docId: 'd', priority: null),
      ];
      final r = groupAndSortTasks(
        tasks: tasks,
        now: _now,
        view: _view(
          groupAxis: TaskGroupAxis.none,
          filters: (b) => b
            ..minPriority = 2
            ..maxPriority = 4,
        ),
      );
      expect(r.single.tasks.map((t) => t.docId), ['b']);
    });

    test('points bounds work the same way as priority', () {
      final tasks = [
        _t(docId: 'a', gamePoints: 1),
        _t(docId: 'b', gamePoints: 5),
        _t(docId: 'c', gamePoints: 13),
        _t(docId: 'd', gamePoints: null),
      ];
      final r = groupAndSortTasks(
        tasks: tasks,
        now: _now,
        view: _view(
          groupAxis: TaskGroupAxis.none,
          filters: (b) => b
            ..minPoints = 2
            ..maxPoints = 8,
        ),
      );
      expect(r.single.tasks.map((t) => t.docId), ['b']);
    });

    test('recurrence filter — all/scheduled/completed/none', () {
      final tasks = [
        _t(docId: 'a', recurrenceDocId: 'r1'),
        _t(docId: 'b', recurrenceDocId: 'r2', completionDate: _hourAgo),
        _t(docId: 'c'), // no recurrence
      ];
      // scheduled: recurrenceDocId != null AND completionDate == null
      final r1 = groupAndSortTasks(
        tasks: tasks,
        now: _now,
        view: _view(
          groupAxis: TaskGroupAxis.none,
          filters: (b) => b..recurrence = RecurrenceFilter.scheduled,
        ),
      );
      expect(r1.single.tasks.map((t) => t.docId), ['a']);

      // completed: recurrence + done
      final r2 = groupAndSortTasks(
        tasks: tasks,
        now: _now,
        view: _view(
          groupAxis: TaskGroupAxis.none,
          filters: (b) => b..recurrence = RecurrenceFilter.completed,
        ),
      );
      expect(r2.single.tasks.map((t) => t.docId), ['b']);

      // none: no recurrence
      final r3 = groupAndSortTasks(
        tasks: tasks,
        now: _now,
        view: _view(
          groupAxis: TaskGroupAxis.none,
          filters: (b) => b..recurrence = RecurrenceFilter.none,
        ),
      );
      expect(r3.single.tasks.map((t) => t.docId), ['c']);
    });

    test('maxAgeDays cuts off tasks older than the threshold', () {
      final tasks = [
        _t(docId: 'a', dateAdded: _now.subtract(const Duration(days: 5))),
        _t(docId: 'b', dateAdded: _now.subtract(const Duration(days: 60))),
      ];
      final r = groupAndSortTasks(
        tasks: tasks,
        now: _now,
        view: _view(
          groupAxis: TaskGroupAxis.none,
          filters: (b) => b..maxAgeDays = 30,
        ),
      );
      expect(r.single.tasks.map((t) => t.docId), ['a']);
    });

    test('dueStatus whitelist excluding scheduled hides future-startDate tasks',
        () {
      final tasks = [
        _t(docId: 'a', startDate: _hourAhead),
        _t(docId: 'b'),
      ];
      final r = groupAndSortTasks(
        tasks: tasks,
        now: _now,
        view: _view(
          groupAxis: TaskGroupAxis.none,
          filters: (b) => b
            ..dueStatus.replace(const {
              DueStatusBucket.pastDue,
              DueStatusBucket.urgent,
              DueStatusBucket.target,
              DueStatusBucket.normal,
              DueStatusBucket.completed,
            }),
        ),
      );
      expect(r.single.tasks.map((t) => t.docId), ['b']);
    });

    test('dueStatus whitelist excluding completed hides completed tasks',
        () {
      final tasks = [
        _t(docId: 'a', completionDate: _hourAgo),
        _t(docId: 'b'),
      ];
      final r = groupAndSortTasks(
        tasks: tasks,
        now: _now,
        view: _view(
          groupAxis: TaskGroupAxis.none,
          filters: (b) => b
            ..dueStatus.replace(const {
              DueStatusBucket.pastDue,
              DueStatusBucket.urgent,
              DueStatusBucket.target,
              DueStatusBucket.normal,
              DueStatusBucket.scheduled,
            }),
        ),
      );
      expect(r.single.tasks.map((t) => t.docId), ['b']);
    });

    test('search is case-insensitive and matches a substring of name', () {
      final tasks = [
        _t(docId: 'a', name: 'Refill medication'),
        _t(docId: 'b', name: 'Spill cleanup'),
        _t(docId: 'c', name: 'Wash car'),
      ];
      final r = groupAndSortTasks(
        tasks: tasks,
        now: _now,
        view: _view(
          groupAxis: TaskGroupAxis.none,
          filters: (b) => b..search = 'ILL',
        ),
      );
      expect(r.single.tasks.map((t) => t.docId), ['a', 'b']);
    });
  });

  group('groupAndSortTasks — dueStatus group axis', () {
    test('canonical 6-bucket layout matches pre-TM-359 behavior', () {
      final tasks = [
        _t(docId: 'pd', dueDate: _dayAgo),
        _t(docId: 'urg', urgentDate: _dayAgo),
        _t(docId: 'tgt', targetDate: _dayAgo),
        _t(docId: 'normal'),
        _t(docId: 'sched', startDate: _hourAhead),
        _t(docId: 'done', completionDate: _hourAgo),
      ];
      final r = groupAndSortTasks(
        tasks: tasks,
        now: _now,
        view: _view(),
      );
      expect(r.map((g) => g.key), [
        'due:pastDue',
        'due:urgent',
        'due:target',
        'due:normal',
        'due:scheduled',
        'due:completed',
      ]);
    });

    test('empty buckets are stripped from the output', () {
      final tasks = [
        _t(docId: 'a', dueDate: _dayAgo),
        _t(docId: 'b'),
      ];
      final r = groupAndSortTasks(
        tasks: tasks,
        now: _now,
        view: _view(),
      );
      expect(r.map((g) => g.key), ['due:pastDue', 'due:normal']);
    });

    test('recently-completed bypass: completed task stays in pre-completion '
        'bucket when its docId is in recentlyCompletedDocIds', () {
      final tasks = [
        _t(
          docId: 'a',
          dueDate: _dayAgo,
          completionDate: _hourAgo,
        ),
      ];
      // Without bypass, task goes to Completed.
      final r1 = groupAndSortTasks(
        tasks: tasks,
        now: _now,
        view: _view(),
      );
      expect(r1.single.key, 'due:completed');

      // With bypass, task stays in Past Due.
      final r2 = groupAndSortTasks(
        tasks: tasks,
        now: _now,
        view: _view(),
        recentlyCompletedDocIds: {'a'},
      );
      expect(r2.single.key, 'due:pastDue');
    });

    test('recently-completed bypasses a dueStatus whitelist that excludes '
        'completed', () {
      final tasks = [
        _t(docId: 'a', completionDate: _hourAgo),
      ];
      // dueStatus excludes completed, so a non-bypassed completed task
      // would be hidden. The recently-completed bypass routes the filter
      // check through the pre-completion bucket (normal), which IS in
      // the whitelist.
      final r = groupAndSortTasks(
        tasks: tasks,
        now: _now,
        view: _view(
          filters: (b) => b
            ..dueStatus.replace(const {
              DueStatusBucket.pastDue,
              DueStatusBucket.urgent,
              DueStatusBucket.target,
              DueStatusBucket.normal,
              DueStatusBucket.scheduled,
            }),
        ),
        recentlyCompletedDocIds: {'a'},
      );
      expect(r.single.tasks.map((t) => t.docId), ['a']);
      expect(r.single.key, 'due:normal');
    });

    test('default within-bucket sort: Scheduled ascends by startDate; '
        'Completed descends by completionDate', () {
      final earlierStart = _now.add(const Duration(hours: 1));
      final laterStart = _now.add(const Duration(hours: 5));
      final earlierDone = _now.subtract(const Duration(hours: 5));
      final laterDone = _now.subtract(const Duration(hours: 1));
      final tasks = [
        _t(docId: 'sB', startDate: laterStart),
        _t(docId: 'sA', startDate: earlierStart),
        _t(docId: 'dA', completionDate: earlierDone),
        _t(docId: 'dB', completionDate: laterDone),
      ];
      final r = groupAndSortTasks(
        tasks: tasks,
        now: _now,
        view: _view(),
      );
      final sched = r.firstWhere((g) => g.key == 'due:scheduled');
      expect(sched.tasks.map((t) => t.docId), ['sA', 'sB']);
      final done = r.firstWhere((g) => g.key == 'due:completed');
      expect(done.tasks.map((t) => t.docId), ['dB', 'dA']);
    });
  });

  group('groupAndSortTasks — non-dueStatus group axes', () {
    test('none axis returns a single bucket with empty displayName', () {
      final r = groupAndSortTasks(
        tasks: [_t(docId: 'a'), _t(docId: 'b')],
        now: _now,
        view: _view(groupAxis: TaskGroupAxis.none),
      );
      expect(r.single.key, 'all');
      expect(r.single.displayName, '');
      expect(r.single.tasks.length, 2);
    });

    test('priority axis: 1..5 buckets ascending, No priority last', () {
      final tasks = [
        _t(docId: 'p3', priority: 3),
        _t(docId: 'pNo', priority: null),
        _t(docId: 'p1', priority: 1),
        _t(docId: 'p5', priority: 5),
      ];
      final r = groupAndSortTasks(
        tasks: tasks,
        now: _now,
        view: _view(groupAxis: TaskGroupAxis.priority),
      );
      expect(r.map((g) => g.key),
          ['priority:1', 'priority:3', 'priority:5', 'priority:none']);
    });

    test('area axis: ordered by Area.sortOrder; ghost names alphabetical; '
        'No area last', () {
      final areas = [_area('Work', 1), _area('Home', 2)];
      final tasks = [
        _t(docId: 'a', area: 'Home'),
        _t(docId: 'b', area: 'Work'),
        _t(docId: 'c', area: 'Ghost'), // not in areas list
        _t(docId: 'd', area: null),
      ];
      final r = groupAndSortTasks(
        tasks: tasks,
        now: _now,
        view: _view(groupAxis: TaskGroupAxis.area),
        areas: areas,
      );
      expect(r.map((g) => g.key),
          ['area:Work', 'area:Home', 'area:Ghost', 'area:none']);
    });

    test('points axis: Fibonacci buckets + Other + None', () {
      final tasks = [
        _t(docId: 'p1', gamePoints: 1),
        _t(docId: 'p5', gamePoints: 5),
        _t(docId: 'pOther', gamePoints: 7),
        _t(docId: 'pNone'),
      ];
      final r = groupAndSortTasks(
        tasks: tasks,
        now: _now,
        view: _view(groupAxis: TaskGroupAxis.points),
      );
      expect(r.map((g) => g.key),
          ['points:1', 'points:5', 'points:other', 'points:none']);
    });

    test('duration axis: closest bucket assignment', () {
      final tasks = [
        _t(docId: 'd5', duration: 5),
        _t(docId: 'd45', duration: 45), // closest to 30 vs 60? 45-30=15, 60-45=15 → 30 (first match wins)
        _t(docId: 'd61', duration: 61), // closest to 60
        _t(docId: 'dNone'),
      ];
      final r = groupAndSortTasks(
        tasks: tasks,
        now: _now,
        view: _view(groupAxis: TaskGroupAxis.duration),
      );
      // First-match tie-break for 45 → bucket 30m (15-distance from both 30 and 60)
      expect(r.map((g) => g.key), [
        'duration:5',
        'duration:30',
        'duration:60',
        'duration:none',
      ]);
    });
  });

  group('groupAndSortTasks — sort axis (non-dueStatus group)', () {
    test('dateAdded ascending vs descending', () {
      final older = _now.subtract(const Duration(days: 60));
      final newer = _now.subtract(const Duration(days: 1));
      final tasks = [
        _t(docId: 'newer', dateAdded: newer),
        _t(docId: 'older', dateAdded: older),
      ];
      final asc = groupAndSortTasks(
        tasks: tasks,
        now: _now,
        view: _view(
          groupAxis: TaskGroupAxis.none,
          sortAxis: TaskSortAxis.dateAdded,
          sortDirection: SortDirection.ascending,
        ),
      );
      expect(asc.single.tasks.map((t) => t.docId), ['older', 'newer']);
      final desc = groupAndSortTasks(
        tasks: tasks,
        now: _now,
        view: _view(
          groupAxis: TaskGroupAxis.none,
          sortAxis: TaskSortAxis.dateAdded,
          sortDirection: SortDirection.descending,
        ),
      );
      expect(desc.single.tasks.map((t) => t.docId), ['newer', 'older']);
    });

    test('priority sort puts nulls last regardless of direction', () {
      final tasks = [
        _t(docId: 'p3', priority: 3),
        _t(docId: 'pNo', priority: null),
        _t(docId: 'p1', priority: 1),
      ];
      final asc = groupAndSortTasks(
        tasks: tasks,
        now: _now,
        view: _view(
          groupAxis: TaskGroupAxis.none,
          sortAxis: TaskSortAxis.priority,
          sortDirection: SortDirection.ascending,
        ),
      );
      expect(asc.single.tasks.map((t) => t.docId), ['p1', 'p3', 'pNo']);
      final desc = groupAndSortTasks(
        tasks: tasks,
        now: _now,
        view: _view(
          groupAxis: TaskGroupAxis.none,
          sortAxis: TaskSortAxis.priority,
          sortDirection: SortDirection.descending,
        ),
      );
      expect(desc.single.tasks.map((t) => t.docId), ['p3', 'p1', 'pNo']);
    });

    test('efficiency = gamePoints / duration; null when either missing', () {
      // a: 6/2 = 3; b: 8/4 = 2; c: null/4 = null
      final tasks = [
        _t(docId: 'b', gamePoints: 8, duration: 4),
        _t(docId: 'a', gamePoints: 6, duration: 2),
        _t(docId: 'c', duration: 4),
      ];
      final r = groupAndSortTasks(
        tasks: tasks,
        now: _now,
        view: _view(
          groupAxis: TaskGroupAxis.none,
          sortAxis: TaskSortAxis.efficiency,
          sortDirection: SortDirection.descending,
        ),
      );
      expect(r.single.tasks.map((t) => t.docId), ['a', 'b', 'c']);
    });

    test('sortAxis=dueStatus + non-dueStatus group axis degrades to dateAdded',
        () {
      final older = _now.subtract(const Duration(days: 60));
      final newer = _now.subtract(const Duration(days: 1));
      final tasks = [
        _t(docId: 'newer', area: 'Work', dateAdded: newer),
        _t(docId: 'older', area: 'Work', dateAdded: older),
      ];
      final r = groupAndSortTasks(
        tasks: tasks,
        now: _now,
        view: _view(
          groupAxis: TaskGroupAxis.area,
          sortAxis: TaskSortAxis.dueStatus,
          sortDirection: SortDirection.descending,
        ),
        areas: [_area('Work', 1)],
      );
      expect(r.single.tasks.map((t) => t.docId), ['newer', 'older']);
    });
  });

  group('groupAndSortTasks — group keys are stable across axis flips', () {
    test('a docId\'s collapsed-group key under dueStatus and area axes are '
        'distinct, so collapsing one doesn\'t collapse the other', () {
      final t = _t(docId: 'a', urgentDate: _dayAgo, area: 'Work');
      final byDue = groupAndSortTasks(
        tasks: [t],
        now: _now,
        view: _view(),
      );
      final byArea = groupAndSortTasks(
        tasks: [t],
        now: _now,
        view: _view(groupAxis: TaskGroupAxis.area),
        areas: [_area('Work', 1)],
      );
      expect(byDue.single.key, 'due:urgent');
      expect(byArea.single.key, 'area:Work');
      expect(byDue.single.key == byArea.single.key, isFalse);
    });
  });
}
