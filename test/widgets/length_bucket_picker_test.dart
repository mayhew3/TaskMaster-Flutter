import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taskmaestro/features/shared/presentation/widgets/length_bucket_picker.dart';

Future<void> _pump(WidgetTester tester, Widget child) async {
  await tester.pumpWidget(MaterialApp(home: Scaffold(body: child)));
}

void main() {
  group('LengthBucketPicker.closestBucketIndex', () {
    test('exact bucket matches return its own index', () {
      expect(LengthBucketPicker.closestBucketIndex(5), 0);
      expect(LengthBucketPicker.closestBucketIndex(15), 1);
      expect(LengthBucketPicker.closestBucketIndex(60), 3);
      expect(LengthBucketPicker.closestBucketIndex(1440), 7);
    });

    test('between buckets snaps to nearest', () {
      // 10 is exactly between 5 and 15 — both deltas are 5. `closestBucketIndex`
      // breaks ties by picking the first encountered (lower) bucket, so 10
      // snaps to 5 (index 0). Documented intentional behavior.
      expect(LengthBucketPicker.closestBucketIndex(10), 0);
      // 90 is between 60 (delta 30) and 120 (delta 30) — ties pick first.
      expect(LengthBucketPicker.closestBucketIndex(90), 3); // 60
      // 100 is closer to 120 (delta 20) than 60 (delta 40).
      expect(LengthBucketPicker.closestBucketIndex(100), 4); // 120
      // 720 is closer to 480 (delta 240) than 1440 (delta 720).
      expect(LengthBucketPicker.closestBucketIndex(720), 6); // 480
    });

    test('null minutes returns null index', () {
      expect(LengthBucketPicker.closestBucketIndex(null), isNull);
    });

    test('negative or zero snaps to smallest bucket', () {
      expect(LengthBucketPicker.closestBucketIndex(0), 0);
      expect(LengthBucketPicker.closestBucketIndex(-30), 0);
    });
  });

  group('LengthBucketPicker widget', () {
    testWidgets('tapping a bucket emits its canonical minutes', (tester) async {
      int? captured;
      await _pump(
        tester,
        LengthBucketPicker(minutes: null, onChanged: (m) => captured = m),
      );
      await tester.tap(find.text('1h'));
      await tester.pumpAndSettle();
      expect(captured, 60);
    });

    testWidgets('tapping the active bucket clears the value', (tester) async {
      int? captured = -1; // sentinel: not yet called
      await _pump(
        tester,
        LengthBucketPicker(minutes: 60, onChanged: (m) => captured = m),
      );
      await tester.tap(find.text('1h'));
      await tester.pumpAndSettle();
      expect(captured, isNull,
          reason:
              'Tap-active-to-clear matches the priority bar so users can null out length the same way.');
    });
  });
}
