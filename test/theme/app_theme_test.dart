import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taskmaster/app_theme.dart';

void main() {
  group('taskMasterTheme M3 contract', () {
    testWidgets('uses Material 3', (tester) async {
      late ThemeData theme;
      await tester.pumpWidget(
        MaterialApp(
          theme: taskMasterTheme,
          home: Builder(
            builder: (context) {
              theme = Theme.of(context);
              return const SizedBox();
            },
          ),
        ),
      );
      expect(theme.useMaterial3, isTrue);
    });

    testWidgets('primary and surface are distinct colors', (tester) async {
      // Locks in the TM-254 fix: previously both were TaskColors.backgroundColor,
      // which broke M3's role-based contrast system.
      late ColorScheme scheme;
      await tester.pumpWidget(
        MaterialApp(
          theme: taskMasterTheme,
          home: Builder(
            builder: (context) {
              scheme = Theme.of(context).colorScheme;
              return const SizedBox();
            },
          ),
        ),
      );
      expect(scheme.primary, isNot(equals(scheme.surface)));
    });

    testWidgets('cardTheme uses elevation 2.0', (tester) async {
      late CardThemeData cardTheme;
      await tester.pumpWidget(
        MaterialApp(
          theme: taskMasterTheme,
          home: Builder(
            builder: (context) {
              cardTheme = Theme.of(context).cardTheme;
              return const SizedBox();
            },
          ),
        ),
      );
      expect(cardTheme.elevation, 2.0);
    });

    testWidgets('dialogTheme uses 20px corner radius', (tester) async {
      late DialogThemeData dialogTheme;
      await tester.pumpWidget(
        MaterialApp(
          theme: taskMasterTheme,
          home: Builder(
            builder: (context) {
              dialogTheme = Theme.of(context).dialogTheme;
              return const SizedBox();
            },
          ),
        ),
      );
      expect(dialogTheme.shape, isA<RoundedRectangleBorder>());
      final shape = dialogTheme.shape! as RoundedRectangleBorder;
      expect(shape.borderRadius, isA<BorderRadius>());
      final radius = shape.borderRadius as BorderRadius;
      expect(radius.topLeft.x, 20.0);
    });
  });
}
