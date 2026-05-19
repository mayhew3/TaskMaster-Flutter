import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:taskmaestro/features/shared/persistence/task_list_view_storage.dart';
import 'package:taskmaestro/models/task_list_view.dart';

void main() {
  late SharedPreferences prefs;
  late TaskListViewStorage storage;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    storage = TaskListViewStorage(prefs);
  });

  group('TaskListViewStorage', () {
    test('loadSync returns the surface default when nothing is stored', () {
      expect(storage.loadSync(TaskListSurface.tasks),
          TaskListView.tasksDefault());
      expect(storage.loadSync(TaskListSurface.family),
          TaskListView.familyDefault());
      expect(storage.loadSync(TaskListSurface.sprint),
          TaskListView.sprintDefault());
      expect(storage.loadSync(TaskListSurface.plan),
          TaskListView.planDefault());
    });

    test('save then loadSync round-trips a non-default view', () async {
      final mutated = TaskListView.tasksDefault().rebuild((b) => b
        ..groupAxis = TaskGroupAxis.area
        ..collapsedGroups.add('area:Work'));
      await storage.save(TaskListSurface.tasks, mutated);
      expect(storage.loadSync(TaskListSurface.tasks), mutated);
    });

    test('clear removes the entry and reverts to default on next load',
        () async {
      await storage.save(
        TaskListSurface.tasks,
        TaskListView.tasksDefault()
            .rebuild((b) => b..groupAxis = TaskGroupAxis.area),
      );
      await storage.clear(TaskListSurface.tasks);
      expect(storage.loadSync(TaskListSurface.tasks),
          TaskListView.tasksDefault());
    });

    test('malformed payload falls back to the surface default', () async {
      await prefs.setString(
        TaskListViewStorage.keyFor(TaskListSurface.tasks),
        'not valid json',
      );
      expect(storage.loadSync(TaskListSurface.tasks),
          TaskListView.tasksDefault());
    });

    test('per-surface keys are isolated — saves do not cross-contaminate',
        () async {
      final tasksView = TaskListView.tasksDefault()
          .rebuild((b) => b..groupAxis = TaskGroupAxis.area);
      final familyView = TaskListView.familyDefault()
          .rebuild((b) => b..groupAxis = TaskGroupAxis.priority);
      await storage.save(TaskListSurface.tasks, tasksView);
      await storage.save(TaskListSurface.family, familyView);
      expect(storage.loadSync(TaskListSurface.tasks), tasksView);
      expect(storage.loadSync(TaskListSurface.family), familyView);
    });

    test('save strips the search term — it is session-only (TM-382)',
        () async {
      final searched = TaskListView.tasksDefault().rebuild((b) => b
        ..groupAxis = TaskGroupAxis.area
        ..filters.search = 'invoices');
      await storage.save(TaskListSurface.tasks, searched);
      final loaded = storage.loadSync(TaskListSurface.tasks);
      expect(loaded.filters.search, isEmpty);
      // Every other axis still round-trips.
      expect(loaded, searched.rebuild((b) => b..filters.search = ''));
    });

    test('loadSync drops a search persisted by an older build (TM-382)',
        () async {
      await prefs.setString(
        TaskListViewStorage.keyFor(TaskListSurface.tasks),
        TaskListView.tasksDefault()
            .rebuild((b) => b..filters.search = 'stale')
            .toJsonString(),
      );
      expect(
        storage.loadSync(TaskListSurface.tasks).filters.search,
        isEmpty,
      );
    });

    test('keyFor matches the documented v1 namespace', () {
      expect(
        TaskListViewStorage.keyFor(TaskListSurface.tasks),
        'taskmaestro.listview.v1.tasks',
      );
      expect(
        TaskListViewStorage.keyFor(TaskListSurface.family),
        'taskmaestro.listview.v1.family',
      );
      expect(
        TaskListViewStorage.keyFor(TaskListSurface.sprint),
        'taskmaestro.listview.v1.sprint',
      );
      expect(
        TaskListViewStorage.keyFor(TaskListSurface.plan),
        'taskmaestro.listview.v1.plan',
      );
    });
  });
}
