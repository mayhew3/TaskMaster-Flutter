import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:taskmaestro/core/platform/form_factor.dart';
import 'package:taskmaestro/features/shared/presentation/wide/right_pane_container.dart';

/// TM-383: the wide shell adds a third Row cell (the right pane) only at
/// logical width ≥1200dp. Below that the layout stays Story-1 shape
/// (sidebar + center column only). On compact (phone), neither sidebar
/// nor right pane renders — bottom NavigationBar instead.
///
/// `_AuthenticatedHome` (the production shell) is private; the harness
/// here mirrors `_buildWideShell` and `_buildCompactShell` shape so the
/// three-pane gating can be exercised without exposing the production
/// widget. The actual production wide-shell shape is verified by the
/// pre-existing widget tests in `wide_nav_sidebar_test.dart` (TM-382)
/// plus this file's structural assertions.
void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  Future<void> pump(
    WidgetTester tester, {
    required Size logical,
  }) async {
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = logical;
    addTearDown(tester.view.reset);

    final container = ProviderContainer();
    addTearDown(container.dispose);

    await tester.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: const MaterialApp(home: _TwoPaneHarness()),
    ));
    await tester.pump();
  }

  testWidgets(
      'at 1280x800 the right pane is present (wide two-pane) (TM-383)',
      (tester) async {
    await pump(tester, logical: const Size(1280, 800));
    expect(find.byType(RightPaneContainer), findsOneWidget);
    expect(find.byKey(const Key('test-sidebar')), findsOneWidget);
  });

  testWidgets(
      'at 1000x800 the layout is wide but the right pane is absent '
      '(below two-pane threshold) (TM-383)', (tester) async {
    await pump(tester, logical: const Size(1000, 800));
    expect(find.byType(RightPaneContainer), findsNothing);
    expect(find.byKey(const Key('test-sidebar')), findsOneWidget,
        reason: 'sidebar should still be present at wide-but-not-two-pane');
  });

  testWidgets(
      'at the inclusive boundary (1200x800) the right pane appears',
      (tester) async {
    await pump(tester, logical: const Size(1200, 800));
    expect(find.byType(RightPaneContainer), findsOneWidget);
  });

  testWidgets(
      'at 800x600 compact neither sidebar nor right pane renders '
      '(TM-382 sanity)', (tester) async {
    await pump(tester, logical: const Size(800, 600));
    expect(find.byType(RightPaneContainer), findsNothing);
    expect(find.byKey(const Key('test-sidebar')), findsNothing);
    expect(find.byKey(const Key('test-bottomNav')), findsOneWidget);
  });
}

/// Mirrors `_AuthenticatedHome._buildWideShell` / `_buildCompactShell`:
///   - wide + two-pane: `Row[sidebar, Expanded(body), RightPaneContainer]`
///   - wide + single-pane: `Row[sidebar, Expanded(body)]`
///   - compact: `Scaffold(body, bottomNavigationBar: NavigationBar)`
class _TwoPaneHarness extends StatelessWidget {
  const _TwoPaneHarness();

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final wide = isWideLayout(size);
    final twoPane = isTwoPaneWideLayout(size);

    if (!wide) {
      return Scaffold(
        body: const Center(child: Text('compact body')),
        bottomNavigationBar: NavigationBar(
          key: const Key('test-bottomNav'),
          destinations: const [
            NavigationDestination(icon: Icon(Icons.assignment), label: 'Plan'),
            NavigationDestination(icon: Icon(Icons.list), label: 'Tasks'),
          ],
        ),
      );
    }

    return Scaffold(
      body: Row(
        children: [
          Container(
            key: const Key('test-sidebar'),
            width: 264,
            color: Colors.blue,
          ),
          const Expanded(child: Center(child: Text('wide body'))),
          if (twoPane)
            // Reference the production constant so this harness stays
            // aligned with the real shell if the right-pane width
            // changes in `form_factor.dart`.
            const SizedBox(width: kRightPaneWidth, child: RightPaneContainer()),
        ],
      ),
    );
  }
}
