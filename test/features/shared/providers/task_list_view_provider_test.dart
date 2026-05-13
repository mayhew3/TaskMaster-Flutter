import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:taskmaestro/features/shared/providers/shared_preferences_provider.dart';
import 'package:taskmaestro/features/shared/providers/task_list_view_providers.dart';
import 'package:taskmaestro/models/task_list_view.dart';

void main() {
  late SharedPreferences prefs;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
  });

  ProviderContainer createContainer() {
    final container = ProviderContainer(overrides: [
      sharedPreferencesProvider.overrideWith((_) async => prefs),
    ]);
    addTearDown(container.dispose);
    return container;
  }

  group('taskListViewStateProvider', () {
    test('build returns the surface default when nothing is stored', () {
      final container = createContainer();
      expect(
        container.read(taskListViewStateProvider(TaskListSurface.tasks)),
        TaskListView.tasksDefault(),
      );
      expect(
        container.read(taskListViewStateProvider(TaskListSurface.sprint)),
        TaskListView.sprintDefault(),
      );
    });

    test('setGroupAxis updates state and persists across containers',
        () async {
      final container = createContainer();
      container
          .read(taskListViewStateProvider(TaskListSurface.tasks).notifier)
          .setGroupAxis(TaskGroupAxis.area);
      expect(
        container
            .read(taskListViewStateProvider(TaskListSurface.tasks))
            .groupAxis,
        TaskGroupAxis.area,
      );
      // Flush microtasks so storage init runs and persists the mutation
      // (the build started before SharedPreferences resolved, so the
      // notifier defers its first storage write to the microtask).
      await Future<void>.value();
      await Future<void>.value();

      // Recreate the container; the new TaskListViewState build() loads
      // from storage. Flush microtasks again so the async init resolves.
      final container2 = createContainer();
      container2.read(taskListViewStateProvider(TaskListSurface.tasks));
      await Future<void>.value();
      await Future<void>.value();
      expect(
        container2
            .read(taskListViewStateProvider(TaskListSurface.tasks))
            .groupAxis,
        TaskGroupAxis.area,
      );
    });

    test('setSortAxis / setSortDirection / toggleSortDirection round-trip',
        () {
      final container = createContainer();
      final notifier = container
          .read(taskListViewStateProvider(TaskListSurface.tasks).notifier);
      notifier.setSortAxis(TaskSortAxis.priority);
      notifier.setSortDirection(SortDirection.ascending);
      var view =
          container.read(taskListViewStateProvider(TaskListSurface.tasks));
      expect(view.sortAxis, TaskSortAxis.priority);
      expect(view.sortDirection, SortDirection.ascending);

      notifier.toggleSortDirection();
      view = container.read(taskListViewStateProvider(TaskListSurface.tasks));
      expect(view.sortDirection, SortDirection.descending);
    });

    test('setFilters replaces the filter object wholesale', () {
      final container = createContainer();
      final notifier = container
          .read(taskListViewStateProvider(TaskListSurface.tasks).notifier);
      final updated = TaskFilters.empty().rebuild((b) => b
        ..minPriority = 3
        ..dueStatus.add(DueStatusBucket.completed));
      notifier.setFilters(updated);
      expect(
        container
            .read(taskListViewStateProvider(TaskListSurface.tasks))
            .filters,
        updated,
      );
    });

    test('setSearch writes only the search axis', () {
      final container = createContainer();
      final notifier = container
          .read(taskListViewStateProvider(TaskListSurface.tasks).notifier);
      notifier.setSearch('demo');
      final view =
          container.read(taskListViewStateProvider(TaskListSurface.tasks));
      expect(view.filters.search, 'demo');
      // Other filter axes still at the surface default.
      expect(view.filters.minPriority, null);
      expect(view.filters.dueStatus, TaskListView.tasksDefault().filters.dueStatus);
    });

    test('toggleGroupCollapsed flips group-key membership', () {
      final container = createContainer();
      final notifier = container
          .read(taskListViewStateProvider(TaskListSurface.tasks).notifier);
      notifier.toggleGroupCollapsed('due:urgent');
      expect(
        container
            .read(taskListViewStateProvider(TaskListSurface.tasks))
            .collapsedGroups,
        {'due:urgent'},
      );
      notifier.toggleGroupCollapsed('due:urgent');
      expect(
        container
            .read(taskListViewStateProvider(TaskListSurface.tasks))
            .collapsedGroups,
        isEmpty,
      );
    });

    test('collapseAll replaces the collapsed set; expandAll clears it', () {
      final container = createContainer();
      final notifier = container
          .read(taskListViewStateProvider(TaskListSurface.tasks).notifier);
      notifier.collapseAll(['due:urgent', 'due:pastDue']);
      expect(
        container
            .read(taskListViewStateProvider(TaskListSurface.tasks))
            .collapsedGroups,
        {'due:urgent', 'due:pastDue'},
      );
      notifier.expandAll();
      expect(
        container
            .read(taskListViewStateProvider(TaskListSurface.tasks))
            .collapsedGroups,
        isEmpty,
      );
    });

    test('reset restores the surface default and clears storage', () async {
      final container = createContainer();
      final notifier = container
          .read(taskListViewStateProvider(TaskListSurface.tasks).notifier);
      notifier.setGroupAxis(TaskGroupAxis.area);
      await Future<void>.value();
      await Future<void>.value();
      notifier.reset();
      await Future<void>.value();
      expect(
        container.read(taskListViewStateProvider(TaskListSurface.tasks)),
        TaskListView.tasksDefault(),
      );
      // New container should also see the default — storage cleared.
      final container2 = createContainer();
      container2.read(taskListViewStateProvider(TaskListSurface.tasks));
      await Future<void>.value();
      await Future<void>.value();
      expect(
        container2.read(taskListViewStateProvider(TaskListSurface.tasks)),
        TaskListView.tasksDefault(),
      );
    });

    test('each surface holds independent state', () {
      final container = createContainer();
      container
          .read(taskListViewStateProvider(TaskListSurface.tasks).notifier)
          .setGroupAxis(TaskGroupAxis.area);
      container
          .read(taskListViewStateProvider(TaskListSurface.sprint).notifier)
          .setGroupAxis(TaskGroupAxis.priority);

      expect(
        container
            .read(taskListViewStateProvider(TaskListSurface.tasks))
            .groupAxis,
        TaskGroupAxis.area,
      );
      expect(
        container
            .read(taskListViewStateProvider(TaskListSurface.sprint))
            .groupAxis,
        TaskGroupAxis.priority,
      );
      // Family and plan untouched.
      expect(
        container
            .read(taskListViewStateProvider(TaskListSurface.family)),
        TaskListView.familyDefault(),
      );
    });

    test('no-op mutators do not emit new state', () {
      final container = createContainer();
      final notifier = container
          .read(taskListViewStateProvider(TaskListSurface.tasks).notifier);
      final firstRef =
          container.read(taskListViewStateProvider(TaskListSurface.tasks));
      // Setting the same axis it already had should not emit.
      notifier.setGroupAxis(firstRef.groupAxis);
      final secondRef =
          container.read(taskListViewStateProvider(TaskListSurface.tasks));
      expect(identical(firstRef, secondRef), isTrue);
    });

    test('flutter_test_config seeds an empty mock store; getInstance resolves',
        () async {
      // The global `test/flutter_test_config.dart` calls
      // `SharedPreferences.setMockInitialValues({})` before every test
      // file, so the provider resolves to an empty in-memory instance
      // without needing an explicit override.
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final prefs = await container.read(sharedPreferencesProvider.future);
      // Empty store: no keys.
      expect(prefs.getKeys(), isEmpty);
    });
  });
}
