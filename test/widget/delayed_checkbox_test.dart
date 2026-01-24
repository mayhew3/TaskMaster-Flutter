import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taskmaster/features/shared/presentation/delayed_checkbox.dart';
import 'package:taskmaster/models/check_state.dart';
import 'package:taskmaster/models/task_colors.dart';

void main() {
  group('DelayedCheckbox', () {
    testWidgets('shows inactive state initially', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DelayedCheckbox(
              taskName: 'Test Task',
              initialState: CheckState.inactive,
              checkCycleWaiter: (_) => null,
            ),
          ),
        ),
      );

      // Should not show any icon for inactive state (inactiveIcon is null by default)
      expect(find.byIcon(Icons.more_horiz), findsNothing);
      expect(find.byIcon(Icons.done_outline), findsNothing);
    });

    testWidgets('shows checked state initially', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DelayedCheckbox(
              taskName: 'Test Task',
              initialState: CheckState.checked,
              checkCycleWaiter: (state) => null,
            ),
          ),
        ),
      );

      // Should show checkmark icon
      expect(find.byIcon(Icons.done_outline), findsOneWidget);
      expect(find.byIcon(Icons.more_horiz), findsNothing);
    });

    testWidgets('shows pending state initially', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DelayedCheckbox(
              taskName: 'Test Task',
              initialState: CheckState.pending,
              checkCycleWaiter: (state) => null,
            ),
          ),
        ),
      );

      // Should show pending icon (three dots)
      expect(find.byIcon(Icons.more_horiz), findsOneWidget);
      expect(find.byIcon(Icons.done_outline), findsNothing);
    });

    testWidgets('immediately shows pending state when tapped from inactive (TM-323)',
        (tester) async {
      CheckState? callbackState;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DelayedCheckbox(
              taskName: 'Test Task',
              initialState: CheckState.inactive,
              checkCycleWaiter: (state) {
                callbackState = state;
                return null;
              },
            ),
          ),
        ),
      );

      // Initially no pending icon
      expect(find.byIcon(Icons.more_horiz), findsNothing);

      // Tap the checkbox
      await tester.tap(find.byType(DelayedCheckbox));
      await tester.pump();

      // Should immediately show pending state (three dots)
      expect(find.byIcon(Icons.more_horiz), findsOneWidget);

      // Callback should have been called with the initial state
      expect(callbackState, CheckState.inactive);
    });

    testWidgets('immediately shows pending state when tapped from checked (TM-323)',
        (tester) async {
      CheckState? callbackState;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DelayedCheckbox(
              taskName: 'Test Task',
              initialState: CheckState.checked,
              checkCycleWaiter: (state) {
                callbackState = state;
                return null;
              },
            ),
          ),
        ),
      );

      // Initially shows checkmark
      expect(find.byIcon(Icons.done_outline), findsOneWidget);

      // Tap the checkbox
      await tester.tap(find.byType(DelayedCheckbox));
      await tester.pump();

      // Should immediately show pending state (three dots)
      expect(find.byIcon(Icons.more_horiz), findsOneWidget);
      expect(find.byIcon(Icons.done_outline), findsNothing);

      // Callback should have been called with the initial state
      expect(callbackState, CheckState.checked);
    });

    testWidgets('ignores taps while already pending', (tester) async {
      int callbackCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DelayedCheckbox(
              taskName: 'Test Task',
              initialState: CheckState.inactive,
              checkCycleWaiter: (state) {
                callbackCount++;
                return null;
              },
            ),
          ),
        ),
      );

      // First tap - should trigger callback
      await tester.tap(find.byType(DelayedCheckbox));
      await tester.pump();
      expect(callbackCount, 1);

      // Second tap while pending - should be ignored
      await tester.tap(find.byType(DelayedCheckbox));
      await tester.pump();
      expect(callbackCount, 1); // Still 1, not 2

      // Third tap - still ignored
      await tester.tap(find.byType(DelayedCheckbox));
      await tester.pump();
      expect(callbackCount, 1);
    });

    testWidgets('updates state when parent provides new initialState',
        (tester) async {
      // Start with inactive
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DelayedCheckbox(
              taskName: 'Test Task',
              initialState: CheckState.inactive,
              checkCycleWaiter: (state) => null,
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.done_outline), findsNothing);

      // Parent rebuilds with checked state (simulating Firestore update)
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DelayedCheckbox(
              taskName: 'Test Task',
              initialState: CheckState.checked,
              checkCycleWaiter: (state) => null,
            ),
          ),
        ),
      );

      // Should now show checked state
      expect(find.byIcon(Icons.done_outline), findsOneWidget);
      expect(find.byIcon(Icons.more_horiz), findsNothing);
    });

    testWidgets('pending state is replaced when parent provides new state',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DelayedCheckbox(
              taskName: 'Test Task',
              initialState: CheckState.inactive,
              checkCycleWaiter: (state) => null,
            ),
          ),
        ),
      );

      // Tap to show pending
      await tester.tap(find.byType(DelayedCheckbox));
      await tester.pump();
      expect(find.byIcon(Icons.more_horiz), findsOneWidget);

      // Parent rebuilds with checked state (Firestore confirmed completion)
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DelayedCheckbox(
              taskName: 'Test Task',
              initialState: CheckState.checked,
              checkCycleWaiter: (state) => null,
            ),
          ),
        ),
      );

      // Should now show checked state, not pending
      expect(find.byIcon(Icons.done_outline), findsOneWidget);
      expect(find.byIcon(Icons.more_horiz), findsNothing);
    });

    testWidgets('shows correct background color for each state', (tester) async {
      // Test inactive state color
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DelayedCheckbox(
              taskName: 'Test Task',
              initialState: CheckState.inactive,
              checkCycleWaiter: (state) => null,
            ),
          ),
        ),
      );

      var card = tester.widget<Card>(find.byType(Card));
      expect(card.color, const Color.fromARGB(0, 0, 0, 0));

      // Test pending state color
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DelayedCheckbox(
              taskName: 'Test Task',
              initialState: CheckState.pending,
              checkCycleWaiter: (state) => null,
            ),
          ),
        ),
      );

      card = tester.widget<Card>(find.byType(Card));
      expect(card.color, TaskColors.pendingCheckbox);
    });

    testWidgets('uses custom inactiveIcon when provided', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DelayedCheckbox(
              taskName: 'Test Task',
              initialState: CheckState.inactive,
              inactiveIcon: Icons.add,
              checkCycleWaiter: (state) => null,
            ),
          ),
        ),
      );

      // Should show custom inactive icon
      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('uses custom checkedColor when provided', (tester) async {
      const customColor = Colors.green;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DelayedCheckbox(
              taskName: 'Test Task',
              initialState: CheckState.checked,
              checkedColor: customColor,
              checkCycleWaiter: (state) => null,
            ),
          ),
        ),
      );

      final card = tester.widget<Card>(find.byType(Card));
      expect(card.color, customColor);
    });
  });
}
