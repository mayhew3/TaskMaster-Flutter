import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:taskmaster/models/serializers.dart';

part 'family.g.dart';

abstract class Family implements Built<Family, FamilyBuilder> {
  @BuiltValueSerializer(serializeNulls: true)
  static Serializer<Family> get serializer => _$familySerializer;

  String get docId;
  DateTime get dateAdded;
  String get ownerPersonDocId;
  BuiltList<String> get members;

  String? get retired;
  DateTime? get retiredDate;

  Family._();
  factory Family([Function(FamilyBuilder) updates]) = _$Family;

  static Family fromJson(dynamic json) {
    return serializers.deserializeWith(Family.serializer, json)!;
  }
}
