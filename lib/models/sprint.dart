import 'package:taskmaster/models/data_object.dart';
import 'package:taskmaster/models/task_field.dart';
import 'package:taskmaster/models/task_item.dart';

import 'app_state.dart';

class Sprint extends DataObject {

  TaskFieldDate startDate;
  TaskFieldDate endDate;
  TaskFieldDate closeDate;

  TaskFieldInteger numUnits;
  TaskFieldString unitName;

  TaskFieldInteger personId;

  List<TaskItem> taskItems = [];

  static List<String> controlledFields = ['id'];

  Sprint(): super() {
    startDate = addDateField('start_date');
    endDate = addDateField('end_date');
    closeDate = addDateField('close_date');
    personId = addIntegerField('person_id');
    numUnits = addIntegerField('num_units');
    unitName = addStringField('unit_name');
  }

  void addToTasks(TaskItem taskItem) {
    if (!taskItems.contains(taskItem)) {
      taskItems.add(taskItem);
    }
  }

  factory Sprint.fromJson(Map<String, dynamic> json) {
    Sprint sprint = Sprint();
    sprint.initFromFields(json);
    return sprint;
  }

}
