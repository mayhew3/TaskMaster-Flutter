
import 'package:json_annotation/json_annotation.dart';

// @JsonSerializable(fieldRename: FieldRename.snake, includeIfNull: false)
class TaskRecurrence {

  TaskRecurrence({
    required int id,
    required int personId
  });
}