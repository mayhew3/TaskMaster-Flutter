import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taskmaster/models/task_colors.dart';
import 'package:taskmaster/features/shared/presentation/widgets/readonly_task_field.dart';

/// Widget Test: ReadOnlyTaskField
///
/// Tests the ReadOnlyTaskField widget in isolation to verify:
/// 1. Header and text display correctly
/// 2. Optional subtext displays when provided
/// 3. Visibility controlled by textToShow parameter
/// 4. Custom colors (text, background, outline) are applied
/// 5. Shadow can be enabled/disabled
/// 6. Proper layout with Row and Column structure
///
/// ReadOnlyTaskField is used to display task metadata in a card format
void main() {
  group('ReadOnlyTaskField Tests', () {
    testWidgets('Displays header and text', (tester) async {
      // Setup: Create field with header and text
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ReadOnlyTaskField(
              headerName: 'Due Date',
              textToShow: 'Tomorrow at 2pm',
            ),
          ),
        ),
      );

      // Verify: Both header and text appear
      expect(find.text('Due Date'), findsOneWidget);
      expect(find.text('Tomorrow at 2pm'), findsOneWidget);
    });

    testWidgets('Displays optional subtext when provided', (tester) async {
      // Setup: Create field with subtext
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ReadOnlyTaskField(
              headerName: 'Date',
              textToShow: 'Jan 15, 2025',
              optionalSubText: '3 days from now',
            ),
          ),
        ),
      );

      // Verify: Main text and subtext both appear
      expect(find.text('Date'), findsOneWidget);
      expect(find.text('Jan 15, 2025'), findsOneWidget);
      expect(find.text('3 days from now'), findsOneWidget);
    });

    testWidgets('Hides widget when textToShow is null', (tester) async {
      // Setup: Create field with null text
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ReadOnlyTaskField(
              headerName: 'Optional Field',
              textToShow: null,
            ),
          ),
        ),
      );

      // Verify: Widget is hidden (Visibility.visible = false)
      final visibility = tester.widget<Visibility>(find.byType(Visibility));
      expect(visibility.visible, false);
    });

    testWidgets('Hides widget when textToShow is empty', (tester) async {
      // Setup: Create field with empty string
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ReadOnlyTaskField(
              headerName: 'Empty Field',
              textToShow: '',
            ),
          ),
        ),
      );

      // Verify: Widget is hidden
      final visibility = tester.widget<Visibility>(find.byType(Visibility));
      expect(visibility.visible, false);
    });

    testWidgets('Shows widget when textToShow has content', (tester) async {
      // Setup: Create field with text content
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ReadOnlyTaskField(
              headerName: 'Status',
              textToShow: 'Active',
            ),
          ),
        ),
      );

      // Verify: Widget is visible
      final visibility = tester.widget<Visibility>(find.byType(Visibility));
      expect(visibility.visible, true);
    });

    testWidgets('Applies custom text color', (tester) async {
      // Setup: Create field with custom text color
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ReadOnlyTaskField(
              headerName: 'Priority',
              textToShow: 'High',
              optionalTextColor: Colors.red,
            ),
          ),
        ),
      );

      // Verify: Custom color is applied
      expect(find.text('High'), findsOneWidget);

      // Find the Text widget displaying 'High'
      final textWidget = tester.widgetList<Text>(find.text('High')).first;
      expect(textWidget.style?.color, Colors.red);
    });

    testWidgets('Applies custom background color', (tester) async {
      // Setup: Create field with custom background
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ReadOnlyTaskField(
              headerName: 'Status',
              textToShow: 'Completed',
              optionalBackgroundColor: Colors.green,
            ),
          ),
        ),
      );

      // Verify: Custom background color is applied
      final card = tester.widget<Card>(find.byType(Card));
      expect(card.color, Colors.green);
    });

    testWidgets('Uses default background color when not specified', (tester) async {
      // Setup: Create field without custom background
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ReadOnlyTaskField(
              headerName: 'Field',
              textToShow: 'Value',
            ),
          ),
        ),
      );

      // Verify: Default background color (TaskColors.cardColor) is used
      final card = tester.widget<Card>(find.byType(Card));
      expect(card.color, TaskColors.cardColor);
    });

    testWidgets('Applies custom outline color', (tester) async {
      // Setup: Create field with custom outline
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ReadOnlyTaskField(
              headerName: 'Highlight',
              textToShow: 'Important',
              optionalOutlineColor: Colors.yellow,
            ),
          ),
        ),
      );

      // Verify: Card has RoundedRectangleBorder with custom outline
      final card = tester.widget<Card>(find.byType(Card));
      expect(card.shape, isA<RoundedRectangleBorder>());

      final border = card.shape as RoundedRectangleBorder;
      expect(border.side.color, Colors.yellow);
      expect(border.side.width, 1.0);
    });

    testWidgets('No outline border when outline color not specified', (tester) async {
      // Setup: Create field without outline color
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ReadOnlyTaskField(
              headerName: 'Normal',
              textToShow: 'Field',
            ),
          ),
        ),
      );

      // Verify: Card has RoundedRectangleBorder without custom side
      final card = tester.widget<Card>(find.byType(Card));
      expect(card.shape, isA<RoundedRectangleBorder>());
    });

    testWidgets('Shadow is enabled by default', (tester) async {
      // Setup: Create field without specifying hasShadow
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ReadOnlyTaskField(
              headerName: 'Shadowed',
              textToShow: 'Field',
            ),
          ),
        ),
      );

      // Verify: Shadow is enabled (shadowColor is black)
      final card = tester.widget<Card>(find.byType(Card));
      expect(card.shadowColor, Colors.black);
    });

    testWidgets('Shadow can be disabled', (tester) async {
      // Setup: Create field with hasShadow = false
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ReadOnlyTaskField(
              headerName: 'Flat',
              textToShow: 'Field',
              hasShadow: false,
            ),
          ),
        ),
      );

      // Verify: Shadow is disabled (shadowColor is invisible)
      final card = tester.widget<Card>(find.byType(Card));
      expect(card.shadowColor, TaskColors.invisible);
    });

    testWidgets('Multiple fields display independently', (tester) async {
      // Setup: Create multiple fields with different content
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ListView(
              children: [
                ReadOnlyTaskField(
                  headerName: 'Name',
                  textToShow: 'Task Name',
                ),
                ReadOnlyTaskField(
                  headerName: 'Due',
                  textToShow: 'Tomorrow',
                  optionalSubText: '1 day left',
                ),
                ReadOnlyTaskField(
                  headerName: 'Status',
                  textToShow: 'Active',
                  optionalBackgroundColor: Colors.blue,
                ),
              ],
            ),
          ),
        ),
      );

      // Verify: All fields appear
      expect(find.text('Name'), findsOneWidget);
      expect(find.text('Task Name'), findsOneWidget);
      expect(find.text('Due'), findsOneWidget);
      expect(find.text('Tomorrow'), findsOneWidget);
      expect(find.text('1 day left'), findsOneWidget);
      expect(find.text('Status'), findsOneWidget);
      expect(find.text('Active'), findsOneWidget);
    });

    testWidgets('Layout uses Row and Column structure', (tester) async {
      // Setup: Create field
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ReadOnlyTaskField(
              headerName: 'Test',
              textToShow: 'Layout',
            ),
          ),
        ),
      );

      // Verify: Card contains Row with Column for text layout
      expect(find.byType(Card), findsOneWidget);
      expect(find.byType(Row), findsOneWidget);
      expect(find.byType(Column), findsOneWidget);
    });

    testWidgets('Header has fixed width', (tester) async {
      // Setup: Create field
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ReadOnlyTaskField(
              headerName: 'Test',
              textToShow: 'Content',
            ),
          ),
        ),
      );

      // Verify: Header is in SizedBox with width 70.0
      final sizedBox = tester.widget<SizedBox>(find.byType(SizedBox));
      expect(sizedBox.width, 70.0);
    });

    testWidgets('Subtext has smaller font size than main text', (tester) async {
      // Setup: Create field with subtext
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ReadOnlyTaskField(
              headerName: 'Date',
              textToShow: 'Main Text',
              optionalSubText: 'Subtext',
            ),
          ),
        ),
      );

      // Verify: Both texts appear
      expect(find.text('Main Text'), findsOneWidget);
      expect(find.text('Subtext'), findsOneWidget);

      // Verify: Different font sizes
      final mainText = tester.widgetList<Text>(find.text('Main Text')).first;
      final subText = tester.widgetList<Text>(find.text('Subtext')).first;

      expect(mainText.style?.fontSize, 16.0);
      expect(subText.style?.fontSize, 12.0);
    });
  });
}
