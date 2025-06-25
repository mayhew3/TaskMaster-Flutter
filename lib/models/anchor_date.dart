import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:taskmaster/models/serializers.dart';
import 'package:taskmaster/models/task_date_type.dart';

import 'json_datetime_converter.dart';

part 'anchor_date.g.dart';

abstract class AnchorDate implements Built<AnchorDate, AnchorDateBuilder> {
  @BuiltValueSerializer(serializeNulls: true)
  static Serializer<AnchorDate> get serializer => _$anchorDateSerializer;

  @JsonDateTimePassThroughConverter()
  DateTime get dateValue;

  TaskDateType get dateType;

  AnchorDate._();

  factory AnchorDate([void Function(AnchorDateBuilder) updates]) = _$AnchorDate;

  static AnchorDate fromJson(dynamic json) {
    return serializers.deserializeWith(AnchorDate.serializer, json)!;
  }

  dynamic toJson() {
    return serializers.serializeWith(AnchorDate.serializer, this);
  }
}
