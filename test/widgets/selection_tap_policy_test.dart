import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:taskmaestro/features/shared/presentation/wide/selection_tap_policy.dart';

/// TM-385 — SelectionTapPolicy is the InheritedWidget seam that lets
/// the leaf `EditableTaskItemWidget._summaryRow.onTap` drive shell-
/// level selection without reading shell providers itself. These
/// tests pin the contract:
///   - `maybeOf(context)` returns the nearest ancestor policy when
///     installed
///   - `maybeOf(context)` returns null when no policy ancestor exists
///     (the compact / phone path)
///   - calling the exposed `onShellTap` invokes the supplied callback
void main() {
  testWidgets('maybeOf returns the nearest installed policy', (tester) async {
    int taps = 0;
    SelectionTapPolicy? observed;

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: SelectionTapPolicy(
          onShellTap: () => taps++,
          child: Builder(
            builder: (ctx) {
              observed = SelectionTapPolicy.maybeOf(ctx);
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );

    expect(observed, isNotNull,
        reason: 'descendant Builder context should find the policy');
    observed!.onShellTap();
    expect(taps, 1,
        reason: 'invoking onShellTap on the resolved policy fires the '
            'supplied callback');
  });

  testWidgets('maybeOf returns null when no policy ancestor exists '
      '(compact / no SelectableTaskItem wrap)', (tester) async {
    SelectionTapPolicy? observed = const SelectionTapPolicy(
      onShellTap: _noop,
      child: SizedBox.shrink(),
    );

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: Builder(
          builder: (ctx) {
            observed = SelectionTapPolicy.maybeOf(ctx);
            return const SizedBox.shrink();
          },
        ),
      ),
    );

    expect(observed, isNull,
        reason: 'a context with no SelectionTapPolicy ancestor must '
            'return null — this is the signal the leaf row uses to '
            'default to accordion-only behavior on compact');
  });

  testWidgets('updateShouldNotify gates on callback identity', (tester) async {
    void cb1() {}
    void cb2() {}
    final a = SelectionTapPolicy(
      onShellTap: cb1,
      child: const SizedBox.shrink(),
    );
    final aAgain = SelectionTapPolicy(
      onShellTap: cb1,
      child: const SizedBox.shrink(),
    );
    final b = SelectionTapPolicy(
      onShellTap: cb2,
      child: const SizedBox.shrink(),
    );

    expect(a.updateShouldNotify(aAgain), isFalse,
        reason: 'same callback identity → no notify');
    expect(a.updateShouldNotify(b), isTrue,
        reason: 'different callback identity → notify');
  });
}

void _noop() {}
