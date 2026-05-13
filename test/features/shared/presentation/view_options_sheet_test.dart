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

Future<Widget> _wrap({
  required TaskListSurface surface,
  required SharedPreferences prefs,
}) async {
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
          body: Center(
            child: ElevatedButton(
              onPressed: () =>
                  ViewOptionsSheet.show(context, surface: surface),
              child: const Text('Open'),
            ),
          ),
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

  testWidgets('pumps the sheet for each surface without throwing',
      (tester) async {
    for (final surface in TaskListSurface.values) {
      await tester.pumpWidget(
          await _wrap(surface: surface, prefs: prefs));
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      expect(find.text('View options'), findsOneWidget,
          reason: 'sheet did not open for $surface');
      await tester.tap(find.text('Done'));
      await tester.pumpAndSettle();
    }
  });

  testWidgets('changing group axis writes through the notifier',
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
            body: Center(
              child: ElevatedButton(
                onPressed: () => ViewOptionsSheet.show(context,
                    surface: TaskListSurface.tasks),
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      ),
    ));
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    // Initial state: groupAxis = dueStatus (Tasks default).
    expect(
      container.read(taskListViewStateProvider(TaskListSurface.tasks))
          .groupAxis,
      TaskGroupAxis.dueStatus,
    );

    // Tap the "Area" chip in the Group section. Both Group and Sort
    // sections offer an "Area" axis; Group is rendered above Sort so
    // `.first` picks the Group chip.
    await tester.tap(find.widgetWithText(ChoiceChip, 'Area').first);
    await tester.pumpAndSettle();
    expect(
      container.read(taskListViewStateProvider(TaskListSurface.tasks))
          .groupAxis,
      TaskGroupAxis.area,
    );
  });

  testWidgets('Owned-by-me toggle only appears on the Family surface',
      (tester) async {
    // Tasks surface — no Owned switch.
    await tester.pumpWidget(
        await _wrap(surface: TaskListSurface.tasks, prefs: prefs));
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    expect(find.text('Owned by me only'), findsNothing);
    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();

    // Family surface — Owned switch present.
    await tester.pumpWidget(
        await _wrap(surface: TaskListSurface.family, prefs: prefs));
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    expect(find.text('Owned by me only'), findsOneWidget);
  });
}
