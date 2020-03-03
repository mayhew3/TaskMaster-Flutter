import 'package:taskmaster/models/task_field.dart';
import 'package:test/test.dart';
import 'package:taskmaster/models/task_item.dart';

import '../mocks/mock_data.dart';

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

    test('isScheduled is false for past date', () {
      TaskItem catLitter = TaskItem.fromJson(catLitterJSON);
      catLitter.startDate.value = catTarget;
      expect(catTarget.isBefore(DateTime.now()), true);
      expect(catLitter.isScheduled(), false);
    });

    test('isScheduled is false for null date', () {
      TaskItem catLitter = TaskItem.fromJson(catLitterJSON);
      expect(catLitter.startDate.value, null);
      expect(catLitter.isScheduled(), false);
    });

    test('isScheduled is true for future date', () {
      DateTime futureDate = DateTime.now().add(Duration(days: 5));
      TaskItem catLitter = TaskItem.fromJson(catLitterJSON);
      catLitter.startDate.value = futureDate;
      expect(catLitter.isScheduled(), true);
    });

    test('isPastDue is true for past date', () {
      TaskItem catLitter = TaskItem.fromJson(catLitterJSON);
      catLitter.dueDate.value = catTarget;
      expect(catTarget.isBefore(DateTime.now()), true);
      expect(catLitter.isPastDue(), true);
    });

    test('isPastDue is false for null date', () {
      TaskItem catLitter = TaskItem.fromJson(catLitterJSON);
      expect(catLitter.dueDate.value, null);
      expect(catLitter.isPastDue(), false);
    });

    test('isPastDue is false for future date', () {
      DateTime futureDate = DateTime.now().add(Duration(days: 5));
      TaskItem catLitter = TaskItem.fromJson(catLitterJSON);
      catLitter.dueDate.value = futureDate;
      expect(catLitter.isPastDue(), false);
    });

    test('isUrgent is true for past date', () {
      TaskItem catLitter = TaskItem.fromJson(catLitterJSON);
      catLitter.urgentDate.value = catTarget;
      expect(catTarget.isBefore(DateTime.now()), true);
      expect(catLitter.isUrgent(), true);
    });

    test('isUrgent is false for null date', () {
      TaskItem catLitter = TaskItem.fromJson(catLitterJSON);
      expect(catLitter.urgentDate.value, null);
      expect(catLitter.isUrgent(), false);
    });

    test('isUrgent is false for future date', () {
      DateTime futureDate = DateTime.now().add(Duration(days: 5));
      TaskItem catLitter = TaskItem.fromJson(catLitterJSON);
      catLitter.urgentDate.value = futureDate;
      expect(catLitter.isUrgent(), false);
    });

    test('getAnchorDate targetDate when only date', () {
      TaskItem catLitter = TaskItem.fromJson(catLitterJSON);
      var expected = catLitter.targetDate.value;
      expect(catLitter.getAnchorDate(), expected);
    });

    test('getAnchorDate targetDate instead of start date', () {
      TaskItem catLitter = TaskItem.fromJson(catLitterJSON);
      catLitter.startDate.value = catTarget.subtract(Duration(days: 3));
      var expected = catLitter.targetDate.value;
      expect(catLitter.getAnchorDate(), expected);
    });

    test('getAnchorDate urgentDate', () {
      TaskItem catLitter = TaskItem.fromJson(catLitterJSON);
      var expected = catTarget.add(Duration(days: 4));
      catLitter.urgentDate.value = expected;
      expect(catLitter.getAnchorDate(), expected);
    });

    test('getAnchorDate dueDate', () {
      TaskItem catLitter = TaskItem.fromJson(catLitterJSON);
      catLitter.urgentDate.value = catTarget.add(Duration(days: 3));
      var expected = catTarget.add(Duration(days: 6));
      catLitter.dueDate.value = expected;
      expect(catLitter.getAnchorDate(), expected);
    });

    test("equals identity", () {
      TaskItem catLitter = TaskItem.fromJson(catLitterJSON);
      expect(catLitter, catLitter);
    });

    test("equals only id matching", () {
      TaskItem taskItem = new TaskItem();
      TaskItem catLitter = TaskItem.fromJson(catLitterJSON);
      taskItem.id.value = catLitter.id.value;
      expect(catLitter, taskItem);
    });

    test("equals no matching", () {
      TaskItem taskItem = new TaskItem();
      TaskItem catLitter = TaskItem.fromJson(catLitterJSON);
      taskItem.id.value = 3;
      expect(catLitter, isNot(taskItem));
    });

  });
}