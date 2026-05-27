import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:taskmaestro/core/database/app_database.dart' hide Area, Context;
import 'package:taskmaestro/core/platform/form_factor.dart';
import 'package:taskmaestro/core/providers/auth_providers.dart';
import 'package:taskmaestro/core/providers/database_provider.dart';
import 'package:taskmaestro/features/areas/providers/area_providers.dart';
import 'package:taskmaestro/features/contexts/providers/context_providers.dart';
import 'package:taskmaestro/features/family/providers/family_providers.dart';
import 'package:taskmaestro/features/shared/presentation/wide/docked_view_options_pane.dart';
import 'package:taskmaestro/features/shared/presentation/wide/view_options_summary_bar.dart';
import 'package:taskmaestro/features/shared/providers/navigation_provider.dart';
import 'package:taskmaestro/features/shared/providers/selected_task_providers.dart';
import 'package:taskmaestro/features/shared/providers/task_list_view_providers.dart';
import 'package:taskmaestro/models/area.dart';
import 'package:taskmaestro/models/context.dart';
import 'package:taskmaestro/models/task_list_view.dart';

/// TM-385 — large-size text scaling audit. Each new wide-layout
/// widget is pumped under `TextScaler.linear(1.5)` and verified to
/// render without overflow exceptions. Catches accessibility
/// regressions where a fixed-height container would clip large text.
class _StubAreas extends AreasWithDefaults {
  _StubAreas(this._areas);
  final List<Area> _areas;
  @override
  AsyncValue<List<Area>> build() => AsyncValue.data(_areas);
}

class _StubContexts extends ContextsWithDefaults {
  _StubContexts(this._contexts);
  final List<Context> _contexts;
  @override
  AsyncValue<List<Context>> build() => AsyncValue.data(_contexts);
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  Future<ProviderContainer> pumpWithLargeText(
    WidgetTester tester,
    Widget child, {
    bool initialCollapsed = false,
  }) async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);
    final container = ProviderContainer(overrides: [
      databaseProvider.overrideWithValue(db),
      personDocIdProvider.overrideWith((ref) => 'test-person'),
      currentFamilyDocIdProvider.overrideWith((ref) => null),
      areasWithDefaultsProvider.overrideWith(() => _StubAreas(const [])),
      contextsWithDefaultsProvider.overrideWith(() => _StubContexts(const [])),
    ]);
    addTearDown(container.dispose);

    container.read(activeTabIndexProvider.notifier).setTab(1); // Tasks
    container.read(rightPaneProvider.notifier).setMode(RightPaneMode.viewOptions);
    if (initialCollapsed) {
      container
          .read(taskListViewStateProvider(TaskListSurface.tasks).notifier)
          .setViewOptionsCollapsed(true);
    }

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(textScaler: TextScaler.linear(1.5)),
            child: Scaffold(body: child),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump();
    return container;
  }

  testWidgets('ViewOptionsSummaryBar — no overflow at 1.5x text scale '
      '(TM-385)', (tester) async {
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(1280, 800);
    addTearDown(tester.view.reset);

    await pumpWithLargeText(
      tester,
      const ViewOptionsSummaryBar(surface: TaskListSurface.tasks),
    );

    expect(tester.takeException(), isNull,
        reason: 'summary bar must render without overflow at 1.5x '
            'system text scaling');
  });

  testWidgets('DockedViewOptionsPane handle — no overflow at 1.5x text '
      'scale (TM-385)', (tester) async {
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(1280, 800);
    addTearDown(tester.view.reset);

    await pumpWithLargeText(
      tester,
      const SizedBox(
        width: kViewOptionsHandleWidth,
        child: DockedViewOptionsPane(),
      ),
      initialCollapsed: true,
    );

    expect(tester.takeException(), isNull,
        reason: 'handle must render without overflow at 1.5x text '
            'scaling — rotated label is the most likely failure point');
  });

  testWidgets('DockedViewOptionsPane expanded panel — no overflow at 1.5x '
      'text scale (TM-385)', (tester) async {
    // Generous size: the View Options form was sized for the phone's
    // bottom sheet which already accommodates large text well; the
    // pane just needs to be wide enough not to overflow at 1.5x.
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(1280, 900);
    addTearDown(tester.view.reset);

    await pumpWithLargeText(
      tester,
      const SizedBox(
        width: kViewOptionsExpandedMax,
        child: DockedViewOptionsPane(),
      ),
    );

    // The View Options form has some inherent overflow at narrow
    // widths even at 1x (known visual nit — see the
    // docked_view_options_pane_test comment). At the max width
    // (600dp) the overflow is more controlled but still possible
    // under 1.5x; this assertion catches REGRESSIONS, not the
    // baseline. If this starts failing, restoring the previous
    // layout is the right fix; we don't want NEW widgets to
    // introduce text-scale clips.
    final ex = tester.takeException();
    // Document the contract: an overflow here would be a
    // regression. Accept current state; flag a real failure if the
    // baseline shifts.
    expect(ex, isNull,
        reason: 'expanded panel at max width + 1.5x text must not '
            'overflow; if this fails, audit recently-added widgets '
            'for fixed heights wrapping text');
  });
}
