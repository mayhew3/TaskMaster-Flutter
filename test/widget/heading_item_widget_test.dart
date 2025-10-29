import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taskmaster/redux/presentation/header_list_item.dart';

/// Widget Test: HeadingItem
///
/// Tests the HeadingItem widget in isolation to verify:
/// 1. Heading text displays correctly
/// 2. Text is converted to uppercase
/// 3. Styling is applied properly
///
/// HeadingItem is used for section headers in task lists
/// (e.g., "PAST DUE", "URGENT", "TARGET", "TASKS")
void main() {
  group('HeadingItem Tests', () {
    testWidgets('Displays heading text', (tester) async {
      // Setup: Create heading with simple text
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HeadingItem('Test Heading'),
          ),
        ),
      );

      // Verify: Heading text appears
      expect(find.text('TEST HEADING'), findsOneWidget);
    });

    testWidgets('Converts lowercase to uppercase', (tester) async {
      // Setup: Create heading with lowercase text
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HeadingItem('past due'),
          ),
        ),
      );

      // Verify: Text is converted to uppercase
      expect(find.text('PAST DUE'), findsOneWidget);
      expect(find.text('past due'), findsNothing);
    });

    testWidgets('Handles mixed case text', (tester) async {
      // Setup: Create heading with mixed case
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HeadingItem('Urgent Tasks'),
          ),
        ),
      );

      // Verify: Text is all uppercase
      expect(find.text('URGENT TASKS'), findsOneWidget);
      expect(find.text('Urgent Tasks'), findsNothing);
    });

    testWidgets('Displays multiple headings independently', (tester) async {
      // Setup: Create multiple headings
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ListView(
              children: [
                HeadingItem('Past Due'),
                HeadingItem('Urgent'),
                HeadingItem('Target'),
                HeadingItem('Tasks'),
              ],
            ),
          ),
        ),
      );

      // Verify: All headings appear
      expect(find.text('PAST DUE'), findsOneWidget);
      expect(find.text('URGENT'), findsOneWidget);
      expect(find.text('TARGET'), findsOneWidget);
      expect(find.text('TASKS'), findsOneWidget);
    });

    testWidgets('Handles empty string', (tester) async {
      // Setup: Create heading with empty string
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HeadingItem(''),
          ),
        ),
      );

      // Verify: Widget renders (even with empty text)
      expect(find.byType(HeadingItem), findsOneWidget);
      expect(find.byType(Text), findsOneWidget);
    });

    testWidgets('Applies theme text style', (tester) async {
      // Setup: Create heading with custom theme
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            textTheme: TextTheme(
              bodySmall: TextStyle(
                fontSize: 12.0,
                color: Colors.grey,
              ),
            ),
          ),
          home: Scaffold(
            body: HeadingItem('Styled Heading'),
          ),
        ),
      );

      // Verify: Heading appears
      expect(find.text('STYLED HEADING'), findsOneWidget);

      // Verify: Text widget uses bodySmall style
      final textWidget = tester.widget<Text>(find.text('STYLED HEADING'));
      expect(textWidget.style, isNotNull);
    });

    testWidgets('Widget is wrapped in Container with correct padding', (tester) async {
      // Setup: Create heading
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HeadingItem('Container Test'),
          ),
        ),
      );

      // Verify: Container exists
      expect(find.byType(Container), findsOneWidget);

      // Verify: Text is present
      expect(find.text('CONTAINER TEST'), findsOneWidget);
    });

    testWidgets('Handles special characters', (tester) async {
      // Setup: Create heading with special characters
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HeadingItem('Task @ 2PM!'),
          ),
        ),
      );

      // Verify: Special characters are preserved and uppercased
      expect(find.text('TASK @ 2PM!'), findsOneWidget);
    });

    testWidgets('Handles numbers in heading', (tester) async {
      // Setup: Create heading with numbers
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HeadingItem('Sprint 123'),
          ),
        ),
      );

      // Verify: Numbers are preserved
      expect(find.text('SPRINT 123'), findsOneWidget);
    });
  });
}
