import 'package:json_annotation/json_annotation.dart';
import 'package:taskmaster/models/task_date_type.dart';

class TaskDateTypeConverter implements JsonConverter<TaskDateType, String> {
  const TaskDateTypeConverter();

  @override
  TaskDateType fromJson(String json) {
    var typeWithLabel = TaskDateTypes.getTypeWithLabel(json);
    if (typeWithLabel == null) {
      throw Exception('Unknown date type: $json');
    }
    return typeWithLabel;
  }

  @override
  String toJson(TaskDateType object) {
    return object.label;
  }

}