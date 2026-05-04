import 'package:flutter_test/flutter_test.dart';
import 'package:taskmaestro/models/area.dart';
import 'package:taskmaestro/models/area_blueprint.dart';
import 'package:taskmaestro/models/serializers.dart';

void main() {
  group('Area built_value (de)serialization', () {
    test('round-trips through serializers', () {
      final original = Area((b) => b
        ..docId = 'area-1'
        ..dateAdded = DateTime.utc(2026, 5, 1, 10, 30)
        ..name = 'Home'
        ..sortOrder = 2
        ..personDocId = 'person-abc');

      final json = serializers.serializeWith(Area.serializer, original);
      final decoded = serializers.deserializeWith(Area.serializer, json);

      expect(decoded, equals(original));
    });

    test('preserves null retired/retiredDate fields', () {
      final original = Area((b) => b
        ..docId = 'area-1'
        ..dateAdded = DateTime.utc(2026, 5, 1)
        ..name = 'Work'
        ..sortOrder = 0
        ..personDocId = 'person-abc');

      final json =
          serializers.serializeWith(Area.serializer, original) as Map;
      // serializeNulls is on, so the keys exist with null values.
      expect(json.containsKey('retired'), isTrue);
      expect(json['retired'], isNull);
    });

    test('preserves retired soft-delete fields when set', () {
      final retiredAt = DateTime.utc(2026, 5, 2);
      final original = Area((b) => b
        ..docId = 'area-1'
        ..dateAdded = DateTime.utc(2026, 5, 1)
        ..name = 'Work'
        ..sortOrder = 0
        ..personDocId = 'person-abc'
        ..retired = 'area-1'
        ..retiredDate = retiredAt);

      final json = serializers.serializeWith(Area.serializer, original);
      final decoded = serializers.deserializeWith(Area.serializer, json);

      expect(decoded?.retired, 'area-1');
      expect(decoded?.retiredDate, retiredAt);
    });
  });

  group('AreaBlueprint', () {
    test('toJson includes all required fields', () {
      final bp = AreaBlueprint(
        name: 'Health',
        sortOrder: 3,
        personDocId: 'person-xyz',
      );
      final json = bp.toJson();
      expect(json['name'], 'Health');
      expect(json['sortOrder'], 3);
      expect(json['personDocId'], 'person-xyz');
    });
  });
}
