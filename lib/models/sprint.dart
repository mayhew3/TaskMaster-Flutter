import 'package:taskmaster/models/data_object.dart';
import 'package:taskmaster/models/task_field.dart';
import 'package:taskmaster/models/task_item.dart';

class Sprint extends DataObject {

  TaskFieldDate startDate;
  TaskFieldDate endDate;
  TaskFieldDate closeDate;

  List<TaskItem> taskItems = [];

  static List<String> controlledFields = ['id'];

  Sprint(): super() {
    startDate = addDateField('start_date');
    endDate = addDateField('end_date');
    closeDate = addDateField('close_date');
  }

  factory Sprint.fromJson(Map<String, dynamic> json) {
    Sprint taskItem = Sprint();
    for (var field in taskItem.fields) {
      var jsonVal = json[field.fieldName];
      if (jsonVal is String) {
        field.initializeValueFromString(jsonVal);
      } else {
        field.initializeValue(jsonVal);
      }
    }
    return taskItem;
  }

}
