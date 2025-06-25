import 'package:built_collection/built_collection.dart';
import 'package:built_value/serializer.dart';
import 'package:taskmaster/models/task_date_type.dart';

class TaskDateTypeSerializer implements PrimitiveSerializer<TaskDateType> {

  @override
  Iterable<Type> get types => BuiltList<Type>([TaskDateType]);

  @override
  String get wireName => 'TaskDateType';

  @override
  TaskDateType deserialize(Serializers serializers, Object serialized, {FullType specifiedType = FullType.unspecified}) {
    if (serialized is String) {
      var typeWithLabel = TaskDateTypes.getTypeWithLabel(serialized);
      if (typeWithLabel == null) {
        throw Exception('Unknown date type: $serialized');
      }
      return typeWithLabel;
    } else {
      throw Exception('Expected string, got: $serialized');
    }
  }

  @override
  Object serialize(Serializers serializers, TaskDateType object, {FullType specifiedType = FullType.unspecified}) {
    return object.label;
  }
}