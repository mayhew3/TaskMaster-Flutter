import 'package:built_collection/built_collection.dart';
import 'package:built_value/serializer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
      return serialized;
    } else if (serialized is Timestamp) {
      return DateTime.fromMillisecondsSinceEpoch(serialized.millisecondsSinceEpoch);
    } else {
      throw Exception("Attempt to deserialize date that is neither string or DateTime: ${serialized.runtimeType}");
    }
  }

  @override
  final Iterable<Type> types = BuiltList<Type>([DateTime]);
  @override
  final String wireName = 'DateTime';

}