
import 'package:flutter/foundation.dart';
import 'package:taskmaster/models/task_field.dart';

abstract class DataObject {

  TaskFieldInteger id;
  List<TaskField> fields = [];

  DataObject() {
    this.id = addIntegerField('id');
  }

  revertAllChanges() {
    for (var field in fields) {
      field.revert();
    }
  }

  void initFromFields(Map<String, dynamic> json) {
    for (var field in fields) {
      var jsonVal = json[field.fieldName];
      if (jsonVal is String) {
        field.initializeValueFromString(jsonVal);
      } else {
        field.initializeValue(jsonVal);
      }
    }
  }

  // Private

  @protected
  TaskFieldString addStringField(String fieldName) {
    var taskFieldString = TaskFieldString(fieldName);
    fields.add(taskFieldString);
    return taskFieldString;
  }

  @protected
  TaskFieldInteger addIntegerField(String fieldName) {
    var taskFieldInteger = TaskFieldInteger(fieldName);
    fields.add(taskFieldInteger);
    return taskFieldInteger;
  }

  @protected
  TaskFieldBoolean addBoolField(String fieldName) {
    var taskFieldBoolean = TaskFieldBoolean(fieldName);
    fields.add(taskFieldBoolean);
    return taskFieldBoolean;
  }

  @protected
  TaskFieldDate addDateField(String fieldName) {
    var taskFieldDate = TaskFieldDate(fieldName);
    fields.add(taskFieldDate);
    return taskFieldDate;
  }

  // Overrides

  @override
  int get hashCode =>
      id.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is DataObject &&
              runtimeType == other.runtimeType &&
              id.value == other.id.value;

}