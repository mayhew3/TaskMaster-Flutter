import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:taskmaster/models/serializers.dart';

/// This allows the `Sprint` class to access private members in
/// the generated file. The value for this is *.g.dart, where
/// the star denotes the source file name.
part 'sprint.g.dart';

abstract class Sprint implements Built<Sprint, SprintBuilder> {
  @BuiltValueSerializer(serializeNulls: true)
  static Serializer<Sprint> get serializer => _$sprintSerializer;

  int? get id;
  String get docId;

  DateTime get dateAdded;

  DateTime get startDate;
  DateTime get endDate;

  DateTime? get closeDate;

  int get numUnits;
  String get unitName;

  String get personDocId;

  int get sprintNumber;

  String? get retired;
  DateTime? get retiredDate;

  Sprint._();

  factory Sprint([void Function(SprintBuilder) updates]) = _$Sprint;

  dynamic toJson() {
    return serializers.serializeWith(Sprint.serializer, this);
  }
}
