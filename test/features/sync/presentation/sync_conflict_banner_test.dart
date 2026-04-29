import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taskmaster/features/sync/presentation/sync_conflict_banner.dart';
import 'package:taskmaster/features/sync/providers/sync_conflict_providers.dart';

void main() {
  Widget _harness(int count) {
    return ProviderScope(
      overrides: [
        // Stub the count provider directly so we don't need to wire up the
        // DAO + database for this widget-only test.
        allConflictsCountProvider.overrideWith((ref) => count),
      ],
      child: const MaterialApp(
        home: Scaffold(
          body: Column(
            children: [
              SyncConflictBanner(),
              Expanded(child: SizedBox.shrink()),
            ],
          ),
        ),
      ),
    );
  }

  testWidgets('hides when count is 0', (tester) async {
    await tester.pumpWidget(_harness(0));
    expect(find.byType(SyncConflictBanner), findsOneWidget);
    expect(find.text('Resolve'), findsNothing,
        reason: 'banner collapses to SizedBox.shrink when no conflicts');
  });

  testWidgets('shows singular text when count is 1', (tester) async {
    await tester.pumpWidget(_harness(1));
    expect(find.textContaining('1 sync conflict'), findsOneWidget);
    expect(find.text('Resolve'), findsOneWidget);
  });

  testWidgets('shows plural text when count > 1', (tester) async {
    await tester.pumpWidget(_harness(3));
    expect(find.textContaining('3 sync conflicts'), findsOneWidget);
    expect(find.text('Resolve'), findsOneWidget);
  });
}
