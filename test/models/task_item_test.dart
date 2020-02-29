import 'package:taskmaster/models/task_field.dart';
import 'package:test/test.dart';
import 'package:taskmaster/models/task_item.dart';

import '../mock_data.dart';

void main() {
  group('TaskItem', () {

    test('Should be constructed', () {
      final taskItem = TaskItem();
      expect(taskItem.id == null, false);
      expect(taskItem.id.value, null);
      expect(taskItem.fields.length > 2, true);
    });

    test('revertAllChanges', () {
      final taskItem = TaskItem();
      taskItem.name.value = 'Cat Litter';
      taskItem.priority.value = 4;
      taskItem.revertAllChanges();
      expect(taskItem.name.value, null);
      expect(taskItem.priority.value, null);
    });

    test('fromJSON', () {
      TaskItem catLitter = TaskItem.fromJson(catLitterJSON);
      expect(catLitter.id.value, 25);
      expect(catLitter.name.value, "Cat Litter");
      expect(catLitter.startDate.value, null);
      expect(catLitter.targetDate.value, catTarget.toLocal());
      expect(catLitter.dateAdded.value, catAdded.toLocal());
      expect(catLitter.completionDate.value, catEnd.toLocal());
      expect(catLitter.recurWait.value, true);
    });

    test('createCopy skips some fields', () {
      TaskItem catLitter = TaskItem.fromJson(catLitterJSON);
      TaskItem catCopy = catLitter.createCopy();
      expect(catCopy.id.value, null);
      expect(catCopy.name.value, "Cat Litter");
      expect(catCopy.dateAdded.value, null);
      expect(catCopy.targetDate.value, catTarget.toLocal());
      expect(catCopy.recurWait.value, true);
      expect(catCopy.completionDate.value, null);
    });

    test('getTaskField', () {
      TaskItem taskItem = new TaskItem();
      var fieldName = 'target_date';
      TaskField taskField = taskItem.getTaskField(fieldName);
      expect(taskField is TaskFieldDate, true);
      expect(taskField.fieldName, fieldName);
    });

    test('getTaskField with unknown field', () {
      TaskItem taskItem = new TaskItem();
      var fieldName = 'bogus_field';
      TaskField taskField = taskItem.getTaskField(fieldName);
      expect(taskField, null);
    });

    test('getTaskField with unknown field', () {
      TaskItem taskItem = new TaskItem();
      var fieldName = 'target_date';
      var dupeField = new TaskFieldDate(fieldName);
      taskItem.fields.add(dupeField);
      expect(() => taskItem.getTaskField(fieldName), throwsException);
    });

    test('isCompleted', () {
      TaskItem catLitter = TaskItem.fromJson(catLitterJSON);
      expect(catLitter.isCompleted(), true);
    });

    test('isCompleted not completed', () {
      TaskItem taskItem = new TaskItem();
      expect(taskItem.isCompleted(), false);
    });

  });
}