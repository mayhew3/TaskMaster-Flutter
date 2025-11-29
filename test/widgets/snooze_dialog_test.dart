import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taskmaster/features/shared/presentation/snooze_dialog.dart';
import 'package:taskmaster/models/task_item.dart';
import 'package:taskmaster/core/services/task_completion_service.dart';
import 'package:taskmaster/timezone_helper.dart';

/// Widget Test: SnoozeDialog
///
/// Tests the SnoozeDialog widget (Riverpod version) to verify:
/// 1. Dialog renders without errors
/// 2. Form fields are present
/// 3. Buttons exist and are functional
///
/// SnoozeDialog is used to shift task dates forward (snooze)

// Test helper for TimezoneHelperNotifier
class _TestTimezoneHelperNotifier extends TimezoneHelperNotifier {
  @override
  Future<TimezoneHelper> build() async {
    final helper = TimezoneHelper();
    await helper.configureLocalTimeZone();
    return helper;
  }
}

void main() {
  group('SnoozeDialog Tests', () {
    // Helper to create a basic task for testing
    TaskItem createTestTask({
      String docId = 'test_task_id',
      String name = 'Test Task',
      DateTime? dueDate,
      DateTime? targetDate,
    }) {
      return TaskItem((b) => b
        ..docId = docId
        ..name = name
        ..personDocId = 'test_person_id'
        ..offCycle = false
        ..dateAdded = DateTime.now().toUtc()
        ..dueDate = dueDate?.toUtc()
        ..targetDate = targetDate?.toUtc());
    }

    testWidgets('Dialog can be created and displayed', (tester) async {
      // Setup: Create task with due date
      final task = createTestTask(
        dueDate: DateTime.now().add(Duration(days: 1)),
      );

      bool dialogShown = false;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            timezoneHelperNotifierProvider.overrideWith(
              () => _TestTimezoneHelperNotifier(),
            ),
          ],
          child: MaterialApp(
            home: Builder(
              builder: (context) => Scaffold(
                body: Center(
                  child: ElevatedButton(
                    onPressed: () async {
                      dialogShown = true;
                      await showDialog(
                        context: context,
                        builder: (context) => SnoozeDialog(taskItem: task),
                      );
                    },
                    child: Text('Show Dialog'),
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      // Open dialog
      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      // Verify: Dialog was shown
      expect(dialogShown, true);

      // Verify: Dialog renders (check for presence of form elements)
      expect(find.byType(SnoozeDialog), findsOneWidget);
    });

    testWidgets('Dialog has form fields', (tester) async {
      // Setup
      final task = createTestTask(
        dueDate: DateTime.now().add(Duration(days: 1)),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            timezoneHelperNotifierProvider.overrideWith(
              () => _TestTimezoneHelperNotifier(),
            ),
          ],
          child: MaterialApp(
            home: Builder(
              builder: (context) => Scaffold(
                body: Center(
                  child: ElevatedButton(
                    onPressed: () async {
                      await showDialog(
                        context: context,
                        builder: (context) => SnoozeDialog(taskItem: task),
                      );
                    },
                    child: Text('Show Dialog'),
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      // Open dialog
      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      // Verify: Form fields exist (at least one TextFormField for number input)
      expect(find.byType(TextFormField), findsWidgets);

      // Verify: Dropdown exists for unit selection
      expect(find.byType(DropdownButton<String>), findsWidgets);
    });

    testWidgets('Dialog has Cancel and Submit buttons', (tester) async {
      // Setup
      final task = createTestTask(
        dueDate: DateTime.now().add(Duration(days: 1)),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            timezoneHelperNotifierProvider.overrideWith(
              () => _TestTimezoneHelperNotifier(),
            ),
          ],
          child: MaterialApp(
            home: Builder(
              builder: (context) => Scaffold(
                body: Center(
                  child: ElevatedButton(
                    onPressed: () async {
                      await showDialog(
                        context: context,
                        builder: (context) => SnoozeDialog(taskItem: task),
                      );
                    },
                    child: Text('Show Dialog'),
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      // Open dialog
      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      // Verify: Cancel and Submit buttons exist
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Submit'), findsOneWidget);
    });

    testWidgets('Cancel button closes dialog', (tester) async {
      // Setup
      final task = createTestTask(
        dueDate: DateTime.now().add(Duration(days: 1)),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            timezoneHelperNotifierProvider.overrideWith(
              () => _TestTimezoneHelperNotifier(),
            ),
          ],
          child: MaterialApp(
            home: Builder(
              builder: (context) => Scaffold(
                body: Center(
                  child: ElevatedButton(
                    onPressed: () async {
                      await showDialog(
                        context: context,
                        builder: (context) => SnoozeDialog(taskItem: task),
                      );
                    },
                    child: Text('Show Dialog'),
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      // Open dialog
      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      // Tap Cancel
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      // Verify: Dialog closed (SnoozeDialog widget no longer in tree)
      expect(find.byType(SnoozeDialog), findsNothing);
    });
  });
}
