import 'package:taskmaster/models/data_object.dart';
import 'package:taskmaster/models/task_field.dart';
import 'package:taskmaster/models/task_item.dart';

import 'app_state.dart';

class Sprint extends DataObject {

  TaskFieldDate startDate;
  TaskFieldDate endDate;
  TaskFieldDate closeDate;

  TaskFieldInteger personId;

  List<TaskItem> taskItems = [];

  static List<String> controlledFields = ['id'];

  Sprint(): super() {
    startDate = addDateField('start_date');
    endDate = addDateField('end_date');
    closeDate = addDateField('close_date');
    personId = addIntegerField('person_id');
  }

  void addToTasks(TaskItem taskItem) {
    if (!taskItems.contains(taskItem)) {
      taskItems.add(taskItem);
    }
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
