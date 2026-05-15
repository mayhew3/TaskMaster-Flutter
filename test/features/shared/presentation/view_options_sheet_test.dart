import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:taskmaestro/features/areas/providers/area_providers.dart';
import 'package:taskmaestro/features/contexts/providers/context_providers.dart';
import 'package:taskmaestro/features/shared/presentation/view_options_sheet.dart';
import 'package:taskmaestro/features/shared/providers/shared_preferences_provider.dart';
import 'package:taskmaestro/features/shared/providers/task_list_view_providers.dart';
import 'package:taskmaestro/models/context.dart' as ctx_model;
import 'package:taskmaestro/models/task_list_view.dart';

ProviderScope _scope({
  required Widget child,
  required SharedPreferences prefs,
}) {
  return ProviderScope(
    overrides: [
      sharedPreferencesProvider.overrideWith((_) async => prefs),
      areasProvider.overrideWith((ref) => Stream.value(const [])),
      contextsProvider
          .overrideWith((ref) => Stream.value(const <ctx_model.Context>[])),
    ],
    child: MaterialApp(
      theme: ThemeData.dark(),
      home: Builder(
        builder: (context) => Scaffold(
          body: Center(child: child),
        ),
      ),
    ),
  );
}

void main() {
  late SharedPreferences prefs;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
  });

  Widget _openButton(TaskListSurface surface) {
    return Builder(
      builder: (context) => ElevatedButton(
        onPressed: () => ViewOptionsSheet.show(context, surface: surface),
        child: const Text('Open'),
      ),
    );
  }

  testWidgets('pumps the sheet for each surface without throwing',
      (tester) async {
    for (final surface in TaskListSurface.values) {
      await tester.pumpWidget(_scope(
        prefs: prefs,
        child: _openButton(surface),
      ));
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      expect(find.text('View options'), findsOneWidget,
          reason: 'sheet did not open for $surface');
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Apply Changes'), findsOneWidget);
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
    }
  });

  testWidgets('Apply Changes commits group-axis selection; Cancel discards',
      (tester) async {
    final container = ProviderContainer(overrides: [
      sharedPreferencesProvider.overrideWith((_) async => prefs),
      areasProvider.overrideWith((ref) => Stream.value(const [])),
      contextsProvider
          .overrideWith((ref) => Stream.value(const <ctx_model.Context>[])),
    ]);
    addTearDown(container.dispose);

    await tester.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        theme: ThemeData.dark(),
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(child: _openButton(TaskListSurface.tasks)),
          ),
        ),
      ),
    ));
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    final initial =
        container.read(taskListViewStateProvider(TaskListSurface.tasks));
    expect(initial.groupAxis, TaskGroupAxis.dueStatus);

    // Change the Group dropdown to "Area" by tapping it then the option.
    // The Group dropdown is the first DropdownButton<TaskGroupAxis>.
    await tester.tap(find.byType(DropdownButton<TaskGroupAxis>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Area').last);
    await tester.pumpAndSettle();

    // Saved state hasn't moved yet — working copy only.
    expect(
      container
          .read(taskListViewStateProvider(TaskListSurface.tasks))
          .groupAxis,
      TaskGroupAxis.dueStatus,
    );

    // Apply commits.
    await tester.tap(find.text('Apply Changes'));
    await tester.pumpAndSettle();
    expect(
      container
          .read(taskListViewStateProvider(TaskListSurface.tasks))
          .groupAxis,
      TaskGroupAxis.area,
    );

    // Reopen + change + Cancel → no commit.
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(DropdownButton<TaskGroupAxis>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Priority').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(
      container
          .read(taskListViewStateProvider(TaskListSurface.tasks))
          .groupAxis,
      TaskGroupAxis.area,
      reason: 'Cancel must not commit working-copy changes',
    );
  });

  testWidgets(
      'Apply blocks with validation banner when a multi-select is '
      'accidentally cleared (individual unchecks, not Deselect All)',
      (tester) async {
    // Reach the failing state: open Due Status multi-select on Tasks
    // surface, individually untick every chip (saved default is the
    // 4 actionable buckets, !=  empty), Done — leaves the working
    // copy with empty dueStatus and _dueStatusDeselectedAll = false,
    // which the validation rule treats as "accidentally empty" since
    // working != default. Apply must be disabled + banner visible.
    final container = ProviderContainer(overrides: [
      sharedPreferencesProvider.overrideWith((_) async => prefs),
      areasProvider.overrideWith((ref) => Stream.value(const [])),
      contextsProvider
          .overrideWith((ref) => Stream.value(const <ctx_model.Context>[])),
    ]);
    addTearDown(container.dispose);

    await tester.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        theme: ThemeData.dark(),
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(child: _openButton(TaskListSurface.tasks)),
          ),
        ),
      ),
    ));
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    // Open the Due Status multi-select modal. The dropdown summary
    // reads "4 selected" (Tasks-surface default whitelists 4 of the 6
    // due-status buckets), so find by that text.
    await tester.tap(find.widgetWithText(InkWell, '4 selected'));
    await tester.pumpAndSettle();

    // Untick each of the 4 actionable buckets individually.
    for (final label in ['Past Due', 'Urgent', 'Target', 'Tasks']) {
      await tester.tap(find.text(label));
      await tester.pumpAndSettle();
    }

    // Close the modal via Done.
    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();

    // Validation banner is visible.
    expect(
        find.textContaining('Select at least one option for Due status'),
        findsOneWidget,
        reason: 'Validation banner must surface when a multi-select '
            'is accidentally emptied.');

    // Apply Changes is disabled (FilledButton with onPressed == null).
    final applyButton = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'Apply Changes'),
    );
    expect(applyButton.onPressed, isNull,
        reason: 'Apply must be gated while the working copy has '
            'accidentally-empty multi-selects.');
  });

  testWidgets('Owned by me only toggle only appears on the Family surface',
      (tester) async {
    await tester.pumpWidget(_scope(
      prefs: prefs,
      child: _openButton(TaskListSurface.tasks),
    ));
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    expect(find.text('Owned by me only'), findsNothing);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    await tester.pumpWidget(_scope(
      prefs: prefs,
      child: _openButton(TaskListSurface.family),
    ));
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    expect(find.text('Owned by me only'), findsOneWidget);
  });
}
