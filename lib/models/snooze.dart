import 'package:taskmaster/models/data_object.dart';
import 'package:taskmaster/models/task_field.dart';

class Snooze extends DataObject {

  late TaskFieldInteger taskID;
  late TaskFieldInteger snoozeNumber;
  late TaskFieldString snoozeUnits;
  late TaskFieldString snoozeAnchor;
  late TaskFieldDate previousAnchor;
  late TaskFieldDate newAnchor;

  static List<String> controlledFields = ['id', 'date_added'];

  Snooze(): super() {
    this.taskID = addIntegerField('task_id');
    this.snoozeNumber = addIntegerField('snooze_number');
    this.snoozeUnits = addStringField('snooze_units');
    this.snoozeAnchor = addStringField('snooze_anchor');
    this.previousAnchor = addDateField('previous_anchor');
    this.newAnchor = addDateField('new_anchor');
  }

  @override
  List<String> getControlledFields() {
    return controlledFields;
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
