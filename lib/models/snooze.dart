import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'snooze.g.dart';

abstract class Snooze implements Built<Snooze, SnoozeBuilder> {
  @BuiltValueSerializer(serializeNulls: true)
  static Serializer<Snooze> get serializer => _$snoozeSerializer;

  int get id;
  DateTime get dateAdded;

  int get taskId;
  int get snoozeNumber;
  String get snoozeUnits;
  String get snoozeAnchor;
  DateTime? get previousAnchor;
  DateTime get newAnchor;

  Snooze._();
  factory Snooze([Function(SnoozeBuilder) updates]) = _$Snooze;
}