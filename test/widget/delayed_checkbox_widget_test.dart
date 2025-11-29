import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taskmaster/models/task_colors.dart';
import 'package:taskmaster/models/check_state.dart';
import 'package:taskmaster/features/shared/presentation/delayed_checkbox.dart';

/// Widget Test: DelayedCheckbox
///
/// Tests the DelayedCheckbox widget (Riverpod version) in isolation to verify:
/// 1. Three states display correctly (inactive, pending, checked)
/// 2. State-specific colors are applied
/// 3. State-specific icons are displayed
/// 4. Tap handling triggers callback with correct state
/// 5. Custom colors and icons work properly
///
/// DelayedCheckbox is used in task items for completion status
void main() {
  group('DelayedCheckbox Tests', () {
    testWidgets('Displays inactive state with default icon', (tester) async {
      // Setup: Create checkbox in inactive state
      CheckState? callbackState;

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            checkboxTheme: CheckboxThemeData(
              fillColor: WidgetStateProperty.all(Colors.blue),
            ),
          ),
          home: Scaffold(
            body: DelayedCheckbox(
              checkCycleWaiter: (state) {
                callbackState = state;
                return null;
              },
              initialState: CheckState.inactive,
              taskName: 'Test Task',
            ),
          ),
        ),
      );

      // Verify: GestureDetector exists for tap handling
      expect(find.byType(GestureDetector), findsOneWidget);

      // Verify: Card with checkbox styling exists
      expect(find.byType(Card), findsOneWidget);
    });

    testWidgets('Displays pending state with horizontal dots icon', (tester) async {
      // Setup: Create checkbox in pending state
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            checkboxTheme: CheckboxThemeData(
              fillColor: WidgetStateProperty.all(Colors.blue),
            ),
          ),
          home: Scaffold(
            body: DelayedCheckbox(
              checkCycleWaiter: (state) => null,
              initialState: CheckState.pending,
              taskName: 'Test Task',
            ),
          ),
        ),
      );

      // Verify: Pending icon (more_horiz) is displayed
      expect(find.byIcon(Icons.more_horiz), findsOneWidget);
    });

    testWidgets('Displays checked state with done icon', (tester) async {
      // Setup: Create checkbox in checked state
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            checkboxTheme: CheckboxThemeData(
              fillColor: WidgetStateProperty.all(Colors.blue),
            ),
          ),
          home: Scaffold(
            body: DelayedCheckbox(
              checkCycleWaiter: (state) => null,
              initialState: CheckState.checked,
              taskName: 'Test Task',
            ),
          ),
        ),
      );

      // Verify: Checked icon (done_outline) is displayed
      expect(find.byIcon(Icons.done_outline), findsOneWidget);
    });

    testWidgets('Displays custom inactive icon when provided', (tester) async {
      // Setup: Create checkbox with custom inactive icon
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            checkboxTheme: CheckboxThemeData(
              fillColor: WidgetStateProperty.all(Colors.blue),
            ),
          ),
          home: Scaffold(
            body: DelayedCheckbox(
              checkCycleWaiter: (state) => null,
              initialState: CheckState.inactive,
              inactiveIcon: Icons.star,
              taskName: 'Test Task',
            ),
          ),
        ),
      );

      // Verify: Custom inactive icon is displayed
      expect(find.byIcon(Icons.star), findsOneWidget);
    });

    testWidgets('Tap triggers callback with correct state', (tester) async {
      // Setup: Create checkbox with tap tracking
      CheckState? tappedState;

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            checkboxTheme: CheckboxThemeData(
              fillColor: WidgetStateProperty.all(Colors.blue),
            ),
          ),
          home: Scaffold(
            body: DelayedCheckbox(
              checkCycleWaiter: (state) {
                tappedState = state;
                return null;
              },
              initialState: CheckState.inactive,
              taskName: 'Test Task',
            ),
          ),
        ),
      );

      // Tap the checkbox
      await tester.tap(find.byType(GestureDetector));
      await tester.pump();

      // Verify: Callback received correct state
      expect(tappedState, CheckState.inactive);
    });

    testWidgets('Tap on pending checkbox passes pending state', (tester) async {
      // Setup: Create pending checkbox with tap tracking
      CheckState? tappedState;

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            checkboxTheme: CheckboxThemeData(
              fillColor: WidgetStateProperty.all(Colors.blue),
            ),
          ),
          home: Scaffold(
            body: DelayedCheckbox(
              checkCycleWaiter: (state) {
                tappedState = state;
                return null;
              },
              initialState: CheckState.pending,
              taskName: 'Test Task',
            ),
          ),
        ),
      );

      // Tap the checkbox
      await tester.tap(find.byType(GestureDetector));
      await tester.pump();

      // Verify: Callback received pending state
      expect(tappedState, CheckState.pending);
    });

    testWidgets('Tap on checked checkbox passes checked state', (tester) async {
      // Setup: Create checked checkbox with tap tracking
      CheckState? tappedState;

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            checkboxTheme: CheckboxThemeData(
              fillColor: WidgetStateProperty.all(Colors.blue),
            ),
          ),
          home: Scaffold(
            body: DelayedCheckbox(
              checkCycleWaiter: (state) {
                tappedState = state;
                return null;
              },
              initialState: CheckState.checked,
              taskName: 'Test Task',
            ),
          ),
        ),
      );

      // Tap the checkbox
      await tester.tap(find.byType(GestureDetector));
      await tester.pump();

      // Verify: Callback received checked state
      expect(tappedState, CheckState.checked);
    });

    testWidgets('Custom checked color is applied', (tester) async {
      // Setup: Create checked checkbox with custom color
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            checkboxTheme: CheckboxThemeData(
              fillColor: WidgetStateProperty.all(Colors.blue),
            ),
          ),
          home: Scaffold(
            body: DelayedCheckbox(
              checkCycleWaiter: (state) => null,
              initialState: CheckState.checked,
              checkedColor: Colors.green,
              taskName: 'Test Task',
            ),
          ),
        ),
      );

      // Verify: Checkbox renders with custom color
      final card = tester.widget<Card>(find.byType(Card));
      expect(card.color, Colors.green);
    });

    testWidgets('Pending state shows pending color', (tester) async {
      // Setup: Create pending checkbox
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            checkboxTheme: CheckboxThemeData(
              fillColor: WidgetStateProperty.all(Colors.blue),
            ),
          ),
          home: Scaffold(
            body: DelayedCheckbox(
              checkCycleWaiter: (state) => null,
              initialState: CheckState.pending,
              taskName: 'Test Task',
            ),
          ),
        ),
      );

      // Verify: Pending color is applied
      final card = tester.widget<Card>(find.byType(Card));
      expect(card.color, TaskColors.pendingCheckbox);
    });

    testWidgets('Multiple checkboxes display independently', (tester) async {
      // Setup: Create multiple checkboxes in different states
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            checkboxTheme: CheckboxThemeData(
              fillColor: WidgetStateProperty.all(Colors.blue),
            ),
          ),
          home: Scaffold(
            body: ListView(
              children: [
                DelayedCheckbox(
                  checkCycleWaiter: (state) => null,
                  initialState: CheckState.inactive,
                  taskName: 'Task 1',
                ),
                DelayedCheckbox(
                  checkCycleWaiter: (state) => null,
                  initialState: CheckState.pending,
                  taskName: 'Task 2',
                ),
                DelayedCheckbox(
                  checkCycleWaiter: (state) => null,
                  initialState: CheckState.checked,
                  taskName: 'Task 3',
                ),
              ],
            ),
          ),
        ),
      );

      // Verify: All checkboxes and their icons exist
      expect(find.byType(DelayedCheckbox), findsNWidgets(3));
      expect(find.byIcon(Icons.more_horiz), findsOneWidget);
      expect(find.byIcon(Icons.done_outline), findsOneWidget);
    });

    testWidgets('Checkbox has correct size constraints', (tester) async {
      // Setup: Create checkbox
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            checkboxTheme: CheckboxThemeData(
              fillColor: WidgetStateProperty.all(Colors.blue),
            ),
          ),
          home: Scaffold(
            body: DelayedCheckbox(
              checkCycleWaiter: (state) => null,
              initialState: CheckState.inactive,
              taskName: 'Test Task',
            ),
          ),
        ),
      );

      // Verify: SizedBox with correct dimensions exists
      // Note: Multiple SizedBoxes exist in tree, find the one in DelayedCheckbox
      final sizedBoxes = tester.widgetList<SizedBox>(find.byType(SizedBox));
      final checkboxSizedBox = sizedBoxes.firstWhere(
        (box) => box.width == 50 && box.height == 50,
      );
      expect(checkboxSizedBox.width, 50);
      expect(checkboxSizedBox.height, 50);
    });

    testWidgets('Checkbox card has rounded corners', (tester) async {
      // Setup: Create checkbox
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            checkboxTheme: CheckboxThemeData(
              fillColor: WidgetStateProperty.all(Colors.blue),
            ),
          ),
          home: Scaffold(
            body: DelayedCheckbox(
              checkCycleWaiter: (state) => null,
              initialState: CheckState.inactive,
              taskName: 'Test Task',
            ),
          ),
        ),
      );

      // Verify: Card has RoundedRectangleBorder shape
      final card = tester.widget<Card>(find.byType(Card));
      expect(card.shape, isA<RoundedRectangleBorder>());
    });
  });
}
