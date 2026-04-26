import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:taskmaster/models/serializers.dart';

part 'person.g.dart';

abstract class Person implements Built<Person, PersonBuilder> {
  @BuiltValueSerializer(serializeNulls: true)
  static Serializer<Person> get serializer => _$personSerializer;

  String get docId;
  DateTime get dateAdded;

  String get email;
  String? get displayName;
  String? get familyDocId;

  String? get retired;
  DateTime? get retiredDate;

  Person._();
  factory Person([Function(PersonBuilder) updates]) = _$Person;

  static Person fromJson(dynamic json) {
    return serializers.deserializeWith(Person.serializer, json)!;
  }
}
