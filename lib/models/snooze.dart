import 'package:taskmaster/models/data_object.dart';
import 'package:taskmaster/models/task_field.dart';

class Snooze extends DataObject {

  TaskFieldInteger taskID;
  TaskFieldInteger snoozeNumber;
  TaskFieldString snoozeUnits;
  TaskFieldString snoozeAnchor;
  TaskFieldDate previousAnchor;
  TaskFieldDate newAnchor;

  static List<String> controlledFields = ['id', 'date_added'];

  Snooze(): super() {
    this.taskID = addIntegerField('task_id');
    this.snoozeNumber = addIntegerField('snooze_number');
    this.snoozeUnits = addStringField('snooze_units');
    this.snoozeAnchor = addStringField('snooze_anchor');
    this.previousAnchor = addDateField('previous_anchor');
    this.newAnchor = addDateField('new_anchor');
  }

  factory Snooze.fromJson(Map<String, dynamic> json) {
    Snooze taskItem = Snooze();
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
