import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:taskmaestro/features/shared/providers/navigation_provider.dart';
import 'package:taskmaestro/features/shared/providers/selected_task_providers.dart';
import 'package:taskmaestro/features/tasks/providers/expanded_task_provider.dart';

/// TM-383: unit tests for the SelectedTask + RightPane notifiers, plus
/// the destination-switch reset contract that lives in ActiveTabIndex
/// .setTab. The destination-switch test (group C in the plan) lives here
/// because it's the same two providers under test — splitting it into a
/// nav_provider_test.dart would mean a second mock-prefs harness for
/// zero coverage benefit.
void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  ProviderContainer createContainer() {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    return container;
  }

  group('SelectedTask', () {
    test('defaults to null', () {
      final c = createContainer();
      expect(c.read(selectedTaskProvider), isNull);
    });

    test('select(docId) sets state', () {
      final c = createContainer();
      c.read(selectedTaskProvider.notifier).select('task-A');
      expect(c.read(selectedTaskProvider), 'task-A');
    });

    test('clear() resets to null', () {
      final c = createContainer();
      c.read(selectedTaskProvider.notifier).select('task-A');
      c.read(selectedTaskProvider.notifier).clear();
      expect(c.read(selectedTaskProvider), isNull);
    });

    test('select(B) after select(A) swaps to B (single-select)', () {
      final c = createContainer();
      final notifier = c.read(selectedTaskProvider.notifier);
      notifier.select('task-A');
      notifier.select('task-B');
      expect(c.read(selectedTaskProvider), 'task-B');
    });

    test('select(same) is a no-op (does not notify a no-change)', () {
      final c = createContainer();
      var notifies = 0;
      c.listen(selectedTaskProvider, (_, __) => notifies++);
      c.read(selectedTaskProvider.notifier).select('task-A');
      expect(notifies, 1);
      c.read(selectedTaskProvider.notifier).select('task-A');
      expect(notifies, 1, reason: 'no state change → no notification');
    });
  });

  group('RightPane', () {
    test('defaults to .empty', () {
      final c = createContainer();
      expect(c.read(rightPaneProvider), RightPaneMode.empty);
    });

    test('setMode(.editor) sets state', () {
      final c = createContainer();
      c.read(rightPaneProvider.notifier).setMode(RightPaneMode.editor);
      expect(c.read(rightPaneProvider), RightPaneMode.editor);
    });

    test('setMode(.viewOptions) sets state', () {
      final c = createContainer();
      c.read(rightPaneProvider.notifier).setMode(RightPaneMode.viewOptions);
      expect(c.read(rightPaneProvider), RightPaneMode.viewOptions);
    });

    test('setMode(same) is a no-op', () {
      final c = createContainer();
      var notifies = 0;
      c.listen(rightPaneProvider, (_, __) => notifies++);
      c.read(rightPaneProvider.notifier).setMode(RightPaneMode.editor);
      expect(notifies, 1);
      c.read(rightPaneProvider.notifier).setMode(RightPaneMode.editor);
      expect(notifies, 1);
    });
  });

  group('destination switch resets selection (TM-383)', () {
    test('setTab clears both selectedTask and rightPane via microtask',
        () async {
      final c = createContainer();
      c.read(selectedTaskProvider.notifier).select('task-A');
      c.read(rightPaneProvider.notifier).setMode(RightPaneMode.editor);

      c.read(activeTabIndexProvider.notifier).setTab(2);
      // setTab defers the clear chain via scheduleMicrotask; drain it.
      await Future<void>.delayed(Duration.zero);

      expect(c.read(selectedTaskProvider), isNull);
      expect(c.read(rightPaneProvider), RightPaneMode.empty);
      expect(c.read(activeTabIndexProvider), 2);
    });

    test(
        'setTab ALSO collapses expandedTaskProvider so it stays in sync '
        'with the selection (TM-383: avoid wide-only desync bug where a '
        'tap on a still-expanded card flips both providers out of phase)',
        () async {
      final c = createContainer();
      c.read(expandedTaskProvider.notifier).toggle('task-A');
      c.read(selectedTaskProvider.notifier).select('task-A');
      expect(c.read(expandedTaskProvider), 'task-A');

      c.read(activeTabIndexProvider.notifier).setTab(1);
      await Future<void>.delayed(Duration.zero);

      expect(c.read(expandedTaskProvider), isNull,
          reason: 'expanded must reset on tab switch alongside selection');
      expect(c.read(selectedTaskProvider), isNull);
    });
  });
}
