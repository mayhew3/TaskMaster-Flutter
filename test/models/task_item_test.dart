import 'package:taskmaster/models/sprint_assignment.dart';
import 'package:taskmaster/models/task_item_blueprint.dart';
import 'package:test/test.dart';
import 'package:taskmaster/models/task_item.dart';

import '../mocks/mock_data.dart';

void main() {
  group('TaskItem', () {

    test('fromJSON', () {
      TaskItem catLitter = TaskItem.fromJson(catLitterJSON);
      expect(catLitter.id, 25);
      expect(catLitter.name, "Cat Litter");
      expect(catLitter.startDate, null);
      expect(catLitter.targetDate, catTarget);
      expect(catLitter.dateAdded, catAdded);
      expect(catLitter.completionDate, catEnd);
      expect(catLitter.recurWait, true);
      expect(catLitter.sprintAssignments, isNot(null));
      expect(catLitter.sprintAssignments!.length, 1);

      SprintAssignment sprintAssignment = catLitter.sprintAssignments![0];
      expect(sprintAssignment.id, 2346);
      expect(sprintAssignment.sprintId, 11);
    });

    test('isCompleted', () {
      TaskItem catLitter = TaskItem.fromJson(catLitterJSON);
      expect(catLitter.isCompleted(), true);
    });

    test('isCompleted not completed', () {
      TaskItem taskItem = new TaskItem(id: 2, personId: 1, name: 'Eat a Penny');
      expect(taskItem.isCompleted(), false);
    });

    test('isScheduled is false for past date', () {
      TaskItem catLitter = TaskItem.fromJson(catLitterJSON);
      catLitter.startDate = catTarget;
      expect(catTarget.isBefore(DateTime.now()), true);
      expect(catLitter.isScheduled(), false);
    });

    test('isScheduled is false for null date', () {
      TaskItem catLitter = TaskItem.fromJson(catLitterJSON);
      expect(catLitter.startDate, null);
      expect(catLitter.isScheduled(), false);
    });

    test('isScheduled is true for future date', () {
      DateTime futureDate = DateTime.now().add(Duration(days: 5));
      TaskItem catLitter = TaskItem.fromJson(catLitterJSON);
      catLitter.startDate = futureDate;
      expect(catLitter.isScheduled(), true);
    });

    test('isPastDue is true for past date', () {
      TaskItem catLitter = TaskItem.fromJson(catLitterJSON);
      catLitter.dueDate = catTarget;
      expect(catTarget.isBefore(DateTime.now()), true);
      expect(catLitter.isPastDue(), true);
    });

    test('isPastDue is false for null date', () {
      TaskItem catLitter = TaskItem.fromJson(catLitterJSON);
      expect(catLitter.dueDate, null);
      expect(catLitter.isPastDue(), false);
    });

    test('isPastDue is false for future date', () {
      DateTime futureDate = DateTime.now().add(Duration(days: 5));
      TaskItem catLitter = TaskItem.fromJson(catLitterJSON);
      catLitter.dueDate = futureDate;
      expect(catLitter.isPastDue(), false);
    });

    test('isUrgent is true for past date', () {
      TaskItem catLitter = TaskItem.fromJson(catLitterJSON);
      catLitter.urgentDate = catTarget;
      expect(catTarget.isBefore(DateTime.now()), true);
      expect(catLitter.isUrgent(), true);
    });

    test('isUrgent is false for null date', () {
      TaskItem catLitter = TaskItem.fromJson(catLitterJSON);
      expect(catLitter.urgentDate, null);
      expect(catLitter.isUrgent(), false);
    });

    test('isUrgent is false for future date', () {
      DateTime futureDate = DateTime.now().add(Duration(days: 5));
      TaskItem catLitter = TaskItem.fromJson(catLitterJSON);
      catLitter.urgentDate = futureDate;
      expect(catLitter.isUrgent(), false);
    });

    test('getAnchorDate targetDate when only date', () {
      TaskItem catLitter = TaskItem.fromJson(catLitterJSON);
      var expected = catLitter.targetDate;
      expect(catLitter.getAnchorDate(), expected);
    });

    test('getAnchorDate targetDate instead of start date', () {
      TaskItem catLitter = TaskItem.fromJson(catLitterJSON);
      catLitter.startDate = catTarget.subtract(Duration(days: 3));
      var expected = catLitter.targetDate;
      expect(catLitter.getAnchorDate(), expected);
    });

    test('getAnchorDate urgentDate', () {
      TaskItem catLitter = TaskItem.fromJson(catLitterJSON);
      var expected = catTarget.add(Duration(days: 4));
      catLitter.urgentDate = expected;
      expect(catLitter.getAnchorDate(), expected);
    });

    test('getAnchorDate dueDate', () {
      TaskItem catLitter = TaskItem.fromJson(catLitterJSON);
      catLitter.urgentDate = catTarget.add(Duration(days: 3));
      var expected = catTarget.add(Duration(days: 6));
      catLitter.dueDate = expected;
      expect(catLitter.getAnchorDate(), expected);
    });

    test("equals identity", () {
      TaskItem catLitter = TaskItem.fromJson(catLitterJSON);
      expect(catLitter, catLitter);
    });

    test("equals only id matching", () {
      TaskItem catLitter = TaskItem.fromJson(catLitterJSON);
      TaskItem taskItem = new TaskItem(id: catLitter.id, personId: 1, name: 'Eat a Penny');
      expect(catLitter, taskItem);
    });

    test("equals no matching", () {
      TaskItem taskItem = new TaskItem(id: 2, personId: 1, name: 'Eat a Penny');
      TaskItem catLitter = TaskItem.fromJson(catLitterJSON);
      expect(catLitter, isNot(taskItem));
    });

  });
}