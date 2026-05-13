import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taskmaestro/features/areas/presentation/area_multi_picker.dart';
import 'package:taskmaestro/features/areas/providers/area_providers.dart';
import 'package:taskmaestro/models/area.dart';

Area _area(String name, int sortOrder) => Area((b) => b
  ..docId = 'area-$name'
  ..dateAdded = DateTime.utc(2025, 1, 1)
  ..name = name
  ..sortOrder = sortOrder
  ..personDocId = 'p');

Widget _wrap(
  Widget child, {
  List<Area> areas = const [],
}) {
  return ProviderScope(
    overrides: [
      areasProvider.overrideWith((ref) => Stream.value(areas)),
    ],
    child: MaterialApp(
      home: Scaffold(body: child),
      theme: ThemeData.dark(),
    ),
  );
}

void main() {
  testWidgets('renders selected names as removable pills', (tester) async {
    Set<String>? latest;
    await tester.pumpWidget(_wrap(
      AreaMultiPicker(
        selected: const {'Work', 'Home'},
        onChanged: (s) => latest = s,
      ),
      areas: [_area('Work', 1), _area('Home', 2)],
    ));
    await tester.pumpAndSettle();

    expect(find.text('Work'), findsOneWidget);
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Pick areas'), findsOneWidget);

    // Tap the remove ✕ on the Work pill — should fire onChanged
    // with Work removed. The Pill widget puts the close icon inside an
    // InkWell at the right side of the pill; tapping it is the contract.
    final closeButtons = find.byIcon(Icons.close);
    expect(closeButtons, findsNWidgets(2));
    await tester.tap(closeButtons.first);
    await tester.pumpAndSettle();
    expect(latest, {'Home'});
  });

  testWidgets('ghost areas render with strike-through and can be cleared',
      (tester) async {
    // 'Stale' is in `selected` but not in the catalog → ghost chip.
    Set<String>? latest;
    await tester.pumpWidget(_wrap(
      AreaMultiPicker(
        selected: const {'Work', 'Stale'},
        onChanged: (s) => latest = s,
      ),
      areas: [_area('Work', 1)],
    ));
    await tester.pumpAndSettle();

    expect(find.text('Work'), findsOneWidget);
    expect(find.text('Stale'), findsOneWidget);

    // The ghost name has line-through decoration; capture that Text widget
    // and verify the style.
    final staleText = tester.widget<Text>(find.text('Stale'));
    expect(staleText.style?.decoration, TextDecoration.lineThrough);

    // Tap the ✕ on the ghost pill (Work renders first per known-then-ghost
    // ordering, so the ghost pill's close button is the second one).
    final closeButtons = find.byIcon(Icons.close);
    await tester.tap(closeButtons.at(1));
    await tester.pumpAndSettle();
    expect(latest, {'Work'});
  });
}
