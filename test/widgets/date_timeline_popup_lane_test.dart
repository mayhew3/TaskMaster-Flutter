import 'package:flutter_test/flutter_test.dart';
import 'package:taskmaestro/features/shared/presentation/widgets/date_timeline_popup.dart';

/// Tests for the lane-assignment algorithm that prevents marker collisions
/// in the date timeline popup. Two markers can share a lane only when
/// their x positions are at least `markerWidth + minGap` pixels apart;
/// otherwise the later one is bumped to the next available lane.
const double _markerWidth = 96;
const double _minGap = 6;

List<int> _assign(List<double> xs) =>
    assignTimelineLanes(xs, markerWidth: _markerWidth, minGap: _minGap);

void main() {
  group('assignTimelineLanes', () {
    test('single marker → lane 0', () {
      expect(_assign([100]), [0]);
    });

    test('markers spaced wider than markerWidth+minGap stay in lane 0', () {
      // 250 - 100 = 150 ≥ 102 → both fit in lane 0.
      expect(_assign([100, 250]), [0, 0]);
    });

    test('markers closer than threshold get pushed to lane 1', () {
      // 150 - 100 = 50 < 102 → second one goes to lane 1.
      expect(_assign([100, 150]), [0, 1]);
    });

    test('three markers all at the same x → lanes 0, 1, 2', () {
      expect(_assign([100, 100, 100]), [0, 1, 2]);
    });

    test('four overlapping markers → lanes 0, 1, 2, 3', () {
      expect(_assign([100, 105, 110, 120]), [0, 1, 2, 3]);
    });

    test('lane reuse after enough horizontal travel', () {
      // First marker at 0, second at 50 (overlap → lane 1), third at 200.
      // 200 - 0 = 200 ≥ 102 → lane 0 has room again, third returns to lane 0.
      expect(_assign([0, 50, 200]), [0, 1, 0]);
    });

    test('exactly at the threshold → shares lane', () {
      // 0 to 102 is exactly markerWidth+minGap, so the second still fits
      // in lane 0 (the inequality is `>=`).
      expect(_assign([0, 102]), [0, 0]);
    });

    test('one pixel under the threshold → bumps to lane 1', () {
      expect(_assign([0, 101]), [0, 1]);
    });

    test('empty input returns empty list', () {
      expect(_assign([]), isEmpty);
    });
  });

  group('assignTimelineLanes priority ordering', () {
    List<int> assignWithPriorities(List<double> xs, List<int> priorities) =>
        assignTimelineLanes(
          xs,
          priorities: priorities,
          markerWidth: _markerWidth,
          minGap: _minGap,
        );

    test('two same-x markers: higher priority gets lane 0', () {
      // Same x → forced collision. Priority 3 (e.g. Due) should land in
      // lane 0 (closest to track), priority 0 (e.g. Start) bumps to lane 1.
      // Result is parallel to the input order: [Start_lane, Due_lane].
      expect(assignWithPriorities([100, 100], [0, 3]), [1, 0]);
    });

    test('all four overlapping in TaskDateTypes order → reverse stack', () {
      // Input order matches TaskDateTypes ordering: Start, Target, Urgent,
      // Due. Want top-down display Start → Target → Urgent → Due, which
      // is lanes 3, 2, 1, 0 respectively.
      expect(
        assignWithPriorities([100, 100, 100, 100], [0, 1, 2, 3]),
        [3, 2, 1, 0],
      );
    });

    test('non-colliding markers all stay at lane 0 regardless of priority', () {
      expect(
        assignWithPriorities([0, 200, 400, 600], [0, 1, 2, 3]),
        [0, 0, 0, 0],
      );
    });

    test(
        'partial overlap: only the colliding subset stacks, lower priority wins',
        () {
      // Start at x=0, Target at x=50 (collide), Urgent at x=400 (alone).
      // Cluster {Start, Target}: Target (priority 1) takes lane 0,
      // Start (priority 0) bumps to lane 1. Urgent alone → lane 0.
      expect(
        assignWithPriorities([0, 50, 400], [0, 1, 2]),
        [1, 0, 0],
      );
    });

    test('priorities length must match xs', () {
      expect(
        () => assignTimelineLanes(
          [0, 100],
          priorities: const [0],
          markerWidth: _markerWidth,
          minGap: _minGap,
        ),
        throwsA(isA<AssertionError>()),
      );
    });
  });
}
