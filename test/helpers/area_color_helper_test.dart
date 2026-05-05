import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taskmaestro/helpers/area_color_helper.dart';
import 'package:taskmaestro/models/task_colors.dart';

void main() {
  group('AreaColorHelper.colorForArea', () {
    test('null and empty return the fallback color', () {
      const fallback = Color(0x4DFFFFFF);
      expect(AreaColorHelper.colorForArea(null), fallback);
      expect(AreaColorHelper.colorForArea(''), fallback);
      expect(AreaColorHelper.colorForArea('   '), fallback);
    });

    test('same name always returns the same color', () {
      final a1 = AreaColorHelper.colorForArea('Family');
      final a2 = AreaColorHelper.colorForArea('Family');
      expect(a1, a2);
    });

    test('comparison is case-insensitive and trims whitespace', () {
      final a = AreaColorHelper.colorForArea('Family');
      expect(AreaColorHelper.colorForArea('family'), a);
      expect(AreaColorHelper.colorForArea('  FAMILY  '), a);
    });

    test('returns a color from the curated palette', () {
      final color = AreaColorHelper.colorForArea('Hobby');
      expect(TaskColors.areaPalette, contains(color));
    });

    test('many distinct names produce a spread of colors', () {
      final names = List<String>.generate(50, (i) => 'area_$i');
      final distinct = names.map(AreaColorHelper.colorForArea).toSet();
      // With a 50-name × 16-slot palette we expect most slots to fill;
      // require ≥5 to keep the test stable against future palette tweaks.
      expect(distinct.length, greaterThanOrEqualTo(5));
    });
  });

  group('AreaColorHelper.paletteIndexForArea', () {
    test('returns null for null and empty inputs', () {
      expect(AreaColorHelper.paletteIndexForArea(null), isNull);
      expect(AreaColorHelper.paletteIndexForArea(''), isNull);
      expect(AreaColorHelper.paletteIndexForArea('  '), isNull);
    });

    test('returns an index inside the palette range', () {
      final index = AreaColorHelper.paletteIndexForArea('Career')!;
      expect(index, inInclusiveRange(0, TaskColors.areaPalette.length - 1));
    });
  });
}
