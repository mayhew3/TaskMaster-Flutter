import 'package:taskmaster/models/sprint_assignment.dart';
import 'package:taskmaster/models/task_item.dart';
import 'package:taskmaster/models/task_item_preview.dart';
import 'package:test/test.dart';

import '../mocks/mock_data.dart';

void main() {
  group('TaskItem', () {

    test('fromJSON', () {
      TaskItem catLitter = TaskItem.fromJson(catLitterJSON);
      expect(catLitter.id, 25);
      expect(catLitter.name, "Cat Litter");
      expect(catLitter.startDate, null);
      expect(catLitter.targetDate, catTarget);
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
      TaskItemPreview preview = catLitter.createPreview(startDate: catTarget);
      expect(catTarget.isBefore(DateTime.now()), true);
      expect(preview.isScheduled(), false);
    });

    test('isScheduled is false for null date', () {
      TaskItem catLitter = TaskItem.fromJson(catLitterJSON);
      expect(catLitter.startDate, null);
      expect(catLitter.isScheduled(), false);
    });

    test('isScheduled is true for future date', () {
      DateTime futureDate = DateTime.now().add(Duration(days: 5));
      TaskItem catLitter = TaskItem.fromJson(catLitterJSON);
      TaskItemPreview preview = catLitter.createPreview(startDate: futureDate);
      expect(preview.isScheduled(), true);
    });

    test('isPastDue is true for past date', () {
      TaskItem catLitter = TaskItem.fromJson(catLitterJSON);
      TaskItemPreview preview = catLitter.createPreview(dueDate: catTarget);
      expect(catTarget.isBefore(DateTime.now()), true);
      expect(preview.isPastDue(), true);
    });

    test('isPastDue is false for null date', () {
      TaskItem catLitter = TaskItem.fromJson(catLitterJSON);
      expect(catLitter.dueDate, null);
      expect(catLitter.isPastDue(), false);
    });

    test('isPastDue is false for future date', () {
      DateTime futureDate = DateTime.now().add(Duration(days: 5));
      TaskItem catLitter = TaskItem.fromJson(catLitterJSON);
      TaskItemPreview preview = catLitter.createPreview(dueDate: futureDate);
      expect(preview.isPastDue(), false);
    });

    test('isUrgent is true for past date', () {
      TaskItem catLitter = TaskItem.fromJson(catLitterJSON);
      TaskItemPreview preview = catLitter.createPreview(urgentDate: catTarget);
      expect(catTarget.isBefore(DateTime.now()), true);
      expect(preview.isUrgent(), true);
    });

    test('isUrgent is false for null date', () {
      TaskItem catLitter = TaskItem.fromJson(catLitterJSON);
      expect(catLitter.urgentDate, null);
      expect(catLitter.isUrgent(), false);
    });

    test('isUrgent is false for future date', () {
      DateTime futureDate = DateTime.now().add(Duration(days: 5));
      TaskItem catLitter = TaskItem.fromJson(catLitterJSON);
      TaskItemPreview preview = catLitter.createPreview(urgentDate: futureDate);
      expect(preview.isUrgent(), false);
    });

    test('getAnchorDate targetDate when only date', () {
      TaskItem catLitter = TaskItem.fromJson(catLitterJSON);
      var expected = catLitter.targetDate;
      expect(catLitter.getAnchorDate(), expected);
    });

    test('getAnchorDate targetDate instead of start date', () {
      TaskItem catLitter = TaskItem.fromJson(catLitterJSON);
      TaskItemPreview preview = catLitter.createPreview(startDate: catTarget.subtract(Duration(days: 3)));
      var expected = catLitter.targetDate;
      expect(preview.getAnchorDate(), expected);
    });

    test('getAnchorDate urgentDate', () {
      TaskItem catLitter = TaskItem.fromJson(catLitterJSON);
      var expected = catTarget.add(Duration(days: 4));
      TaskItemPreview preview = catLitter.createPreview(urgentDate: expected);
      expect(preview.getAnchorDate(), expected);
    });

    test('getAnchorDate dueDate', () {
      TaskItem catLitter = TaskItem.fromJson(catLitterJSON);
      var expected = catTarget.add(Duration(days: 6));
      var preview = catLitter.createPreview(urgentDate: catTarget.add(Duration(days: 3)), dueDate: expected);
      expect(preview.getAnchorDate(), expected);
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