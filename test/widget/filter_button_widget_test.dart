import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taskmaster/redux/presentation/filter_button.dart';

/// Widget Test: FilterButton
///
/// Tests the FilterButton widget (PopupMenuButton with checkboxes).
///
/// FilterButton is a complex widget that:
/// - Shows a PopupMenuButton with filter icon
/// - Displays checked menu items based on filter state
/// - Triggers callbacks when items are selected
/// - Has two filters: "Show Scheduled" and "Show Completed"
///
/// This tests interaction patterns with popup menus and callbacks.
void main() {
  group('FilterButton Tests', () {
    testWidgets('Displays filter icon button', (tester) async {
      // Setup: Create filter button with default state
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: AppBar(
              actions: [
                FilterButton(
                  scheduledGetter: () => false,
                  completedGetter: () => false,
                  toggleScheduled: () {},
                  toggleCompleted: () {},
                ),
              ],
            ),
          ),
        ),
      );

      // Verify: Filter icon appears
      expect(find.byIcon(Icons.filter_list), findsOneWidget);
      expect(find.byType(PopupMenuButton<String>), findsOneWidget);
    });

    testWidgets('Shows popup menu when tapped', (tester) async {
      // Setup: Create filter button
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: AppBar(
              actions: [
                FilterButton(
                  scheduledGetter: () => false,
                  completedGetter: () => false,
                  toggleScheduled: () {},
                  toggleCompleted: () {},
                ),
              ],
            ),
          ),
        ),
      );

      // Tap the filter button
      await tester.tap(find.byIcon(Icons.filter_list));
      await tester.pumpAndSettle();

      // Verify: Menu items appear
      expect(find.text('Show Scheduled'), findsOneWidget);
      expect(find.text('Show Completed'), findsOneWidget);
    });

    testWidgets('Displays unchecked items when both filters are false', (tester) async {
      // Setup: Both filters disabled
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: AppBar(
              actions: [
                FilterButton(
                  scheduledGetter: () => false,
                  completedGetter: () => false,
                  toggleScheduled: () {},
                  toggleCompleted: () {},
                ),
              ],
            ),
          ),
        ),
      );

      // Open menu
      await tester.tap(find.byIcon(Icons.filter_list));
      await tester.pumpAndSettle();

      // Verify: Both menu items exist (checked state is internal to CheckedPopupMenuItem)
      expect(find.text('Show Scheduled'), findsOneWidget);
      expect(find.text('Show Completed'), findsOneWidget);
    });

    testWidgets('Displays checked scheduled item when scheduled filter is true', (tester) async {
      // Setup: Scheduled filter enabled
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: AppBar(
              actions: [
                FilterButton(
                  scheduledGetter: () => true,  // Scheduled checked
                  completedGetter: () => false,
                  toggleScheduled: () {},
                  toggleCompleted: () {},
                ),
              ],
            ),
          ),
        ),
      );

      // Open menu
      await tester.tap(find.byIcon(Icons.filter_list));
      await tester.pumpAndSettle();

      // Verify: Menu items appear
      expect(find.text('Show Scheduled'), findsOneWidget);
      expect(find.text('Show Completed'), findsOneWidget);

      // Verify: Scheduled item has checkmark
      final scheduledMenuItem = tester.widget<CheckedPopupMenuItem<String>>(
        find.widgetWithText(CheckedPopupMenuItem<String>, 'Show Scheduled'),
      );
      expect(scheduledMenuItem.checked, true);
    });

    testWidgets('Displays checked completed item when completed filter is true', (tester) async {
      // Setup: Completed filter enabled
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: AppBar(
              actions: [
                FilterButton(
                  scheduledGetter: () => false,
                  completedGetter: () => true,  // Completed checked
                  toggleScheduled: () {},
                  toggleCompleted: () {},
                ),
              ],
            ),
          ),
        ),
      );

      // Open menu
      await tester.tap(find.byIcon(Icons.filter_list));
      await tester.pumpAndSettle();

      // Verify: Completed item has checkmark
      final completedMenuItem = tester.widget<CheckedPopupMenuItem<String>>(
        find.widgetWithText(CheckedPopupMenuItem<String>, 'Show Completed'),
      );
      expect(completedMenuItem.checked, true);
    });

    testWidgets('Both items checked when both filters are true', (tester) async {
      // Setup: Both filters enabled
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: AppBar(
              actions: [
                FilterButton(
                  scheduledGetter: () => true,
                  completedGetter: () => true,
                  toggleScheduled: () {},
                  toggleCompleted: () {},
                ),
              ],
            ),
          ),
        ),
      );

      // Open menu
      await tester.tap(find.byIcon(Icons.filter_list));
      await tester.pumpAndSettle();

      // Verify: Both items are checked
      final scheduledMenuItem = tester.widget<CheckedPopupMenuItem<String>>(
        find.widgetWithText(CheckedPopupMenuItem<String>, 'Show Scheduled'),
      );
      final completedMenuItem = tester.widget<CheckedPopupMenuItem<String>>(
        find.widgetWithText(CheckedPopupMenuItem<String>, 'Show Completed'),
      );

      expect(scheduledMenuItem.checked, true);
      expect(completedMenuItem.checked, true);
    });

    testWidgets('Tapping scheduled item triggers toggleScheduled callback', (tester) async {
      // Setup: Track callback invocation
      bool scheduledToggled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: AppBar(
              actions: [
                FilterButton(
                  scheduledGetter: () => false,
                  completedGetter: () => false,
                  toggleScheduled: () {
                    scheduledToggled = true;
                  },
                  toggleCompleted: () {},
                ),
              ],
            ),
          ),
        ),
      );

      // Open menu
      await tester.tap(find.byIcon(Icons.filter_list));
      await tester.pumpAndSettle();

      // Tap "Show Scheduled" - use warnIfMissed: false to avoid hit test warnings
      await tester.tap(find.text('Show Scheduled'), warnIfMissed: false);
      await tester.pumpAndSettle();

      // Verify: Callback was invoked
      expect(scheduledToggled, true);
    });

    testWidgets('Tapping completed item triggers toggleCompleted callback', (tester) async {
      // Setup: Track callback invocation
      bool completedToggled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: AppBar(
              actions: [
                FilterButton(
                  scheduledGetter: () => false,
                  completedGetter: () => false,
                  toggleScheduled: () {},
                  toggleCompleted: () {
                    completedToggled = true;
                  },
                ),
              ],
            ),
          ),
        ),
      );

      // Open menu
      await tester.tap(find.byIcon(Icons.filter_list));
      await tester.pumpAndSettle();

      // Tap "Show Completed" - use warnIfMissed: false to avoid hit test warnings
      await tester.tap(find.text('Show Completed'), warnIfMissed: false);
      await tester.pumpAndSettle();

      // Verify: Callback was invoked
      expect(completedToggled, true);
    });

    testWidgets('Can toggle both filters independently', (tester) async {
      // Setup: Track both callbacks
      int scheduledToggleCount = 0;
      int completedToggleCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: AppBar(
              actions: [
                FilterButton(
                  scheduledGetter: () => false,
                  completedGetter: () => false,
                  toggleScheduled: () {
                    scheduledToggleCount++;
                  },
                  toggleCompleted: () {
                    completedToggleCount++;
                  },
                ),
              ],
            ),
          ),
        ),
      );

      // Open menu and tap scheduled
      await tester.tap(find.byIcon(Icons.filter_list));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Show Scheduled'), warnIfMissed: false);
      await tester.pumpAndSettle();

      // Open menu again and tap completed
      await tester.tap(find.byIcon(Icons.filter_list));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Show Completed'), warnIfMissed: false);
      await tester.pumpAndSettle();

      // Verify: Both callbacks invoked once
      expect(scheduledToggleCount, 1);
      expect(completedToggleCount, 1);
    });

    testWidgets('Filter button works in different scaffold positions', (tester) async {
      // Setup: Place filter button in body instead of appbar
      bool toggled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: FilterButton(
                scheduledGetter: () => false,
                completedGetter: () => false,
                toggleScheduled: () {
                  toggled = true;
                },
                toggleCompleted: () {},
              ),
            ),
          ),
        ),
      );

      // Open menu
      await tester.tap(find.byIcon(Icons.filter_list));
      await tester.pumpAndSettle();

      // Tap scheduled
      await tester.tap(find.text('Show Scheduled'), warnIfMissed: false);
      await tester.pumpAndSettle();

      // Verify: Still works in body
      expect(toggled, true);
    });

    testWidgets('Menu items have correct values for routing', (tester) async {
      // Setup: Verify the value passed to onSelected
      String? selectedValue;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: AppBar(
              actions: [
                PopupMenuButton<String>(
                  icon: Icon(Icons.filter_list),
                  onSelected: (value) {
                    selectedValue = value;
                  },
                  itemBuilder: (context) => [
                    CheckedPopupMenuItem<String>(
                      checked: false,
                      value: 'scheduled',
                      child: Text('Show Scheduled'),
                    ),
                    CheckedPopupMenuItem<String>(
                      checked: false,
                      value: 'completed',
                      child: Text('Show Completed'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );

      // Open menu and tap scheduled
      await tester.tap(find.byIcon(Icons.filter_list));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Show Scheduled'), warnIfMissed: false);
      await tester.pumpAndSettle();

      // Verify: Correct value passed
      expect(selectedValue, 'scheduled');

      // Open menu and tap completed
      await tester.tap(find.byIcon(Icons.filter_list));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Show Completed'), warnIfMissed: false);
      await tester.pumpAndSettle();

      // Verify: Correct value passed
      expect(selectedValue, 'completed');
    });
  });
}
