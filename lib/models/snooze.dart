import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:taskmaster/models/serializers.dart';

part 'snooze.g.dart';

abstract class Snooze implements Built<Snooze, SnoozeBuilder> {
  @BuiltValueSerializer(serializeNulls: true)
  static Serializer<Snooze> get serializer => _$snoozeSerializer;

  int? get id;
  String get docId;

  DateTime get dateAdded;

  int? get taskId;
  String get taskDocId;

  int get snoozeNumber;
  String get snoozeUnits;
  String get snoozeAnchor;
  DateTime? get previousAnchor;
  DateTime get newAnchor;

  Snooze._();
  factory Snooze([Function(SnoozeBuilder) updates]) = _$Snooze;

  dynamic toJson() {
    return serializers.serializeWith(Snooze.serializer, this);
  }

  static Snooze fromJson(dynamic json) {
    return serializers.deserializeWith(Snooze.serializer, json)!;
  }
}