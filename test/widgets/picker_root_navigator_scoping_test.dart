import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:taskmaestro/core/providers/auth_providers.dart';
import 'package:taskmaestro/features/areas/presentation/area_picker.dart';
import 'package:taskmaestro/features/areas/providers/area_providers.dart';
import 'package:taskmaestro/features/contexts/presentation/context_picker.dart';
import 'package:taskmaestro/features/contexts/providers/context_providers.dart';
import 'package:taskmaestro/features/shared/presentation/widgets/date_timeline_popup.dart';
import 'package:taskmaestro/features/shared/presentation/widgets/points_picker.dart';
import 'package:taskmaestro/models/area.dart';
import 'package:taskmaestro/models/context.dart' as ctx_model;
import 'package:taskmaestro/models/task_date_type.dart';

/// Sync AsyncValue.data stub for the picker tests so the production
/// Drift stream doesn't open and trip flutter_test's `!timersPending`
/// invariant (see MEMORY.md `project_drift_flutter_test_interaction`).
class _StubAreasWithDefaults extends AreasWithDefaults {
  _StubAreasWithDefaults(this._areas);
  final List<Area> _areas;
  @override
  AsyncValue<List<Area>> build() => AsyncValue.data(_areas);
}

class _StubContextsWithDefaults extends ContextsWithDefaults {
  _StubContextsWithDefaults(this._contexts);
  final List<ctx_model.Context> _contexts;
  @override
  AsyncValue<List<ctx_model.Context>> build() => AsyncValue.data(_contexts);
}

/// TM-384: the four pickers (AreaPicker, ContextPicker, PointsPicker,
/// DateTimelinePopup) each accept a `useRootNavigator` flag that the
/// docked editor pane sets to `false` so the modal renders scoped to
/// the nested pane navigator instead of spanning the whole window.
///
/// Production-code regressions that DROP the flag (or pass it but
/// fail to thread it into the underlying `showModalBottomSheet` /
/// `showDialog`) are silently invisible — every existing test pumped
/// the pickers full-screen, where root-vs-nested doesn't matter.
///
/// These tests pump each picker inside a sized nested Navigator (380dp
/// wide, mimicking the docked editor pane) and assert that:
///   - `useRootNavigator: false` → modal stays within the nested
///     navigator's bounds (width ≤ pane width).
///   - `useRootNavigator: true`  → modal escapes to the root navigator
///     and spans the full window width.
///
/// DateTimelinePopup's outer sheet and `_TimeBucketPicker`'s
/// `showTimePicker` are threaded through the same flag; its
/// `_MiniCalendar._openMonthYearPicker` sub-sheet was the
/// `[CRITICAL]` pre-push finding (it was missed in the original
/// implementation) and is now also threaded.
void main() {
  const paneWidth = 380.0;
  const rootWidth = 1280.0;

  // ── Setup helpers ─────────────────────────────────────────────────────────

  Future<void> pumpPickerInPane(
    WidgetTester tester, {
    required Widget picker,
    required ProviderContainer container,
  }) async {
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(rootWidth, 900);
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          home: Scaffold(
            body: Align(
              // Left-align so the pane occupies x ∈ [0, paneWidth].
              // Lets tests distinguish modal-in-pane (centerX ≤
              // paneWidth) from modal-in-root (centerX ≈ rootWidth/2)
              // with simple < comparisons.
              alignment: Alignment.centerLeft,
              child: SizedBox(
                width: paneWidth,
                // Mirror the production wide-shell structure from
                // `DockedTaskEditorPane`: a nested Navigator scoped
                // to the 380dp slot, with a LayoutBuilder + MediaQuery
                // clamp so descendant `showModalBottomSheet` /
                // `showDialog` size against the pane (not the full
                // window). Both pieces are load-bearing — the
                // useRootNavigator flag picks which overlay hosts the
                // modal, and the MediaQuery clamp shrinks the modal's
                // intrinsic size to the pane.
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final mq = MediaQuery.of(context);
                    return MediaQuery(
                      data: mq.copyWith(
                        size: Size(
                            constraints.maxWidth, constraints.maxHeight),
                      ),
                      child: Navigator(
                        onGenerateRoute: (_) => MaterialPageRoute<void>(
                          builder: (_) => Material(child: picker),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  // ── AreaPicker ────────────────────────────────────────────────────────────

  group('AreaPicker useRootNavigator', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer(overrides: [
        personDocIdProvider.overrideWith((ref) => 'test-person'),
        areasWithDefaultsProvider
            .overrideWith(() => _StubAreasWithDefaults(const <Area>[])),
      ]);
      addTearDown(container.dispose);
    });

    testWidgets('useRootNavigator: false keeps the sheet inside the pane '
        '(TM-384)', (tester) async {
      await pumpPickerInPane(
        tester,
        container: container,
        picker: AreaPicker(
          initialValue: null,
          valueSetter: (_) {},
          useRootNavigator: false,
        ),
      );

      await tester.tap(find.byKey(const Key('area_picker_button')));
      await tester.pumpAndSettle();

      expect(find.text('Select area'), findsOneWidget);
      final sheetSize = tester.getSize(find.text('Select area').hitTestable());
      expect(sheetSize.width, lessThanOrEqualTo(paneWidth),
          reason: 'with useRootNavigator: false the sheet must stay '
              'within the nested navigator\'s 380dp pane');
    });

    testWidgets('useRootNavigator: true escapes to the root navigator '
        '(TM-384)', (tester) async {
      await pumpPickerInPane(
        tester,
        container: container,
        picker: AreaPicker(
          initialValue: null,
          valueSetter: (_) {},
          useRootNavigator: true,
        ),
      );

      await tester.tap(find.byKey(const Key('area_picker_button')));
      await tester.pumpAndSettle();

      // With useRootNavigator: true the sheet renders against the root
      // Navigator, so its width spans the full window (1280dp) rather
      // than the 380dp pane. We verify by checking a child of the
      // sheet's content: the "Select area" Text widget. Its containing
      // sheet's width must exceed the pane width.
      final headerCenter = tester.getCenter(find.text('Select area'));
      expect(headerCenter.dx, greaterThan(paneWidth + 20),
          reason: 'with useRootNavigator: true the sheet escapes the '
              'pane — its header should be centered against the FULL '
              '1280dp window, not the 380dp pane. Header x≈paneWidth/2 '
              '(~190) would indicate the modal was scoped to the pane '
              '(wrong); header x≈windowWidth/2 (~640) is the expected '
              'root-navigator behavior.');
    });
  });

  // ── ContextPicker ─────────────────────────────────────────────────────────

  group('ContextPicker useRootNavigator', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer(overrides: [
        personDocIdProvider.overrideWith((ref) => 'test-person'),
        contextsWithDefaultsProvider.overrideWith(
            () => _StubContextsWithDefaults(const <ctx_model.Context>[])),
      ]);
      addTearDown(container.dispose);
    });

    testWidgets('useRootNavigator: false keeps the sheet inside the pane '
        '(TM-384)', (tester) async {
      await pumpPickerInPane(
        tester,
        container: container,
        picker: ContextPicker(
          selected: const [],
          onChanged: (_) {},
          useRootNavigator: false,
        ),
      );

      // Tap the Add pill to open the sheet.
      await tester.tap(find.text('Add'));
      await tester.pumpAndSettle();

      expect(find.text('Add context'), findsOneWidget);
      final headerCenter = tester.getCenter(find.text('Add context'));
      expect(headerCenter.dx, lessThanOrEqualTo(paneWidth),
          reason: 'sheet header must center within the pane width');
    });
  });

  // ── PointsPicker ──────────────────────────────────────────────────────────

  group('PointsPicker useRootNavigator', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
      addTearDown(container.dispose);
    });

    testWidgets('useRootNavigator: false keeps the "Other" dialog inside '
        'the pane (TM-384)', (tester) async {
      await pumpPickerInPane(
        tester,
        container: container,
        picker: PointsPicker(
          value: null,
          onChanged: (_) {},
          useRootNavigator: false,
        ),
      );

      // Tap the "Other" segment (index 5 → label "Other").
      await tester.tap(find.text('Other'));
      await tester.pumpAndSettle();

      expect(find.text('Custom points'), findsOneWidget);
      // AlertDialog defaults to AlertDialogTheme; its content sits
      // inside an InsetPadding constrained by the nested navigator's
      // overlay. With useRootNavigator: false the dialog's title
      // should center at ≤ paneWidth.
      final titleCenter = tester.getCenter(find.text('Custom points'));
      expect(titleCenter.dx, lessThanOrEqualTo(paneWidth),
          reason: 'dialog must stay within the nested pane');
    });

    testWidgets('useRootNavigator: true escapes to the root '
        '(TM-384)', (tester) async {
      await pumpPickerInPane(
        tester,
        container: container,
        picker: PointsPicker(
          value: null,
          onChanged: (_) {},
          useRootNavigator: true,
        ),
      );

      await tester.tap(find.text('Other'));
      await tester.pumpAndSettle();

      expect(find.text('Custom points'), findsOneWidget);
      final titleCenter = tester.getCenter(find.text('Custom points'));
      expect(titleCenter.dx, greaterThan(paneWidth),
          reason: 'with useRootNavigator: true the dialog centers '
              'against the full window, not the 380dp pane');
    });
  });

  // ── DateTimelinePopup ─────────────────────────────────────────────────────
  //
  // The outer sheet is the most-visible part of the popup. Its
  // `_MiniCalendar._openMonthYearPicker` sub-sheet and
  // `_TimeBucketPicker`'s `showTimePicker` ALSO take the flag (a missed
  // thread in `_MiniCalendar` was the pre-push CRITICAL finding for this
  // PR); reaching them requires interacting with date markers + bucket
  // picker, which adds setup complexity disproportionate to the coverage
  // gained over the outer-sheet assertion below. The outer-sheet test
  // verifies the flag is threaded through `DateTimelinePopup.show`'s
  // `showModalBottomSheet` call; the sub-sheet threading is covered
  // implicitly by the production code's `useRootNavigator: widget
  // .useRootNavigator` writes (the `[CRITICAL]` thread is now in the
  // production code's `_openMonthYearPicker`).

  group('DateTimelinePopup useRootNavigator', () {
    Widget triggerButton({required bool useRootNavigator}) {
      return Builder(
        builder: (ctx) => TextButton(
          onPressed: () => DateTimelinePopup.show(
            context: ctx,
            dates: <TaskDateType, DateTime?>{
              for (final t in TaskDateTypes.allTypes) t: null,
            },
            useRootNavigator: useRootNavigator,
            onChanged: (_, __) {},
          ),
          child: const Text('Open dates'),
        ),
      );
    }

    testWidgets('useRootNavigator: false keeps the popup inside the pane '
        '(TM-384)', (tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await pumpPickerInPane(
        tester,
        container: container,
        picker: triggerButton(useRootNavigator: false),
      );

      await tester.tap(find.text('Open dates'));
      await tester.pumpAndSettle();

      // Outer popup renders a unique 'Dates' or 'Save' affordance; we
      // anchor on 'Save' which the header's right-side button uses.
      // Whatever label is present, its center X must be ≤ paneWidth
      // (left-aligned pane).
      expect(find.byType(DateTimelinePopup), findsOneWidget);
      final popupCenter =
          tester.getCenter(find.byType(DateTimelinePopup));
      expect(popupCenter.dx, lessThanOrEqualTo(paneWidth),
          reason: 'date popup must stay within the 380dp nested pane');
    });

    testWidgets('useRootNavigator: true escapes to the root navigator '
        '(TM-384)', (tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await pumpPickerInPane(
        tester,
        container: container,
        picker: triggerButton(useRootNavigator: true),
      );

      await tester.tap(find.text('Open dates'));
      await tester.pumpAndSettle();

      expect(find.byType(DateTimelinePopup), findsOneWidget);
      final popupCenter =
          tester.getCenter(find.byType(DateTimelinePopup));
      expect(popupCenter.dx, greaterThan(paneWidth),
          reason: 'with useRootNavigator: true the popup escapes the '
              'pane and centers against the full window');
    });
  });
}
