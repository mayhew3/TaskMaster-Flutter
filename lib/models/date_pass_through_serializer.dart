import 'package:built_value/serializer.dart';
// TM-361: cloud_firestore 6.x added its own `Type` symbol (for pipeline
// expressions) which collides with `dart:core`'s `Type`. Hide it so the
// `[DateTime]` literal infers as `List<core.Type>` correctly.
import 'package:cloud_firestore/cloud_firestore.dart' hide Type;

class DatePassThroughSerializer implements PrimitiveSerializer<DateTime> {

  @override
  Object serialize(Serializers serializers, DateTime dateTime, {FullType specifiedType = FullType.unspecified}) {
    if (!dateTime.isUtc) {
      throw ArgumentError.value(
          dateTime, 'dateTime', 'Must be in utc for serialization.');
    }
    return dateTime;
  }

  @override
  DateTime deserialize(Serializers serializers, Object serialized, {FullType specifiedType = FullType.unspecified}) {
    if (serialized is String) {
      return DateTime.parse(serialized).toUtc();
    } else if (serialized is DateTime) {
      if (!serialized.isUtc) {
        throw ArgumentError.value(
            serialized, 'dateTime', 'Must be in utc for serialization.');
      }
      return serialized;
    } else if (serialized is Timestamp) {
      return DateTime.fromMillisecondsSinceEpoch(serialized.millisecondsSinceEpoch).toUtc();
    } else {
      throw Exception('Attempt to deserialize date that is neither string or DateTime: ${serialized.runtimeType}');
    }
  }

  @override
  Iterable<Type> get types => const [DateTime];
  @override
  String get wireName => 'DateTime';

}