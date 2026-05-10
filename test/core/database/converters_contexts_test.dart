import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:taskmaestro/core/database/converters.dart';

/// Tests for `parseTaskContexts` / `serializeTaskContexts` round-trips
/// (TM-181).
///
/// Both helpers feed the canonical `taskContexts` Drift TEXT column AND the
/// legacy bare-string fallback path; one place to centralise legacy handling.
void main() {
  group('parseTaskContexts', () {
    test('null → empty list', () {
      expect(parseTaskContexts(null), isEmpty);
    });

    test('empty string → empty list', () {
      expect(parseTaskContexts(''), isEmpty);
    });

    test('JSON-encoded list of {name, value} round-trips', () {
      final encoded = jsonEncode([
        {'name': 'Phone', 'value': null},
        {'name': 'Computer', 'value': 30},
      ]);
      final result = parseTaskContexts(encoded);
      expect(result, hasLength(2));
      expect(result[0].name, 'Phone');
      expect(result[0].value, isNull);
      expect(result[1].name, 'Computer');
      expect(result[1].value, 30);
    });

    test('legacy bare string (non-JSON) → single-element list', () {
      // v7 row's `taskContext` column held a raw string — after the v8
      // migration, that exact value lives in `taskContexts`, and the
      // converter must wrap it as a single-element list rather than failing
      // jsonDecode.
      final result = parseTaskContexts('Phone');
      expect(result, hasLength(1));
      expect(result.first.name, 'Phone');
      expect(result.first.value, isNull);
    });

    test('JSON-encoded bare string → single-element list', () {
      // Some legacy callers may have stored the value as a quoted string
      // (e.g. `'"Phone"'`). jsonDecode returns a bare String; we wrap it.
      final result = parseTaskContexts('"Phone"');
      expect(result, hasLength(1));
      expect(result.first.name, 'Phone');
    });

    test('list directly (Firestore round-trip after migration)', () {
      final result = parseTaskContexts([
        {'name': 'Phone'},
        {'name': 'Computer', 'value': 5},
      ]);
      expect(result, hasLength(2));
      expect(result[0].name, 'Phone');
      expect(result[1].value, 5);
    });

    test('list with mixed strings and maps', () {
      final result = parseTaskContexts([
        'Phone',
        {'name': 'Computer'},
      ]);
      expect(result, hasLength(2));
      expect(result[0].name, 'Phone');
      expect(result[1].name, 'Computer');
    });

    test('skips entries with empty name', () {
      final result = parseTaskContexts([
        {'name': ''},
        {'name': 'Phone'},
      ]);
      expect(result, hasLength(1));
      expect(result.first.name, 'Phone');
    });

    test('coerces num value to int', () {
      final result = parseTaskContexts([
        {'name': 'Phone', 'value': 5.0},
      ]);
      expect(result.first.value, 5);
    });
  });

  group('serializeTaskContexts', () {
    test('null → null', () {
      expect(serializeTaskContexts(null), isNull);
    });

    test('empty list → null', () {
      // Empty list serialises as null so the Drift column stays empty;
      // round-trips through `parseTaskContexts` as an empty list.
      expect(serializeTaskContexts(const []), isNull);
    });

    test('omits null `value` field on serialise', () {
      final list = parseTaskContexts([
        {'name': 'Phone'},
      ]);
      final encoded = serializeTaskContexts(list);
      expect(encoded, isNotNull);
      final decoded = jsonDecode(encoded!) as List;
      expect((decoded.first as Map).containsKey('value'), isFalse);
    });

    test('round-trips a list with values', () {
      final list = parseTaskContexts([
        {'name': 'Phone', 'value': 5},
      ]);
      final encoded = serializeTaskContexts(list)!;
      final reparsed = parseTaskContexts(encoded);
      expect(reparsed, hasLength(1));
      expect(reparsed.first.name, 'Phone');
      expect(reparsed.first.value, 5);
    });
  });
}
