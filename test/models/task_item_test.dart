import 'package:taskmaster/models/task_date_type.dart';
import 'package:taskmaster/models/task_item.dart';
import 'package:taskmaster/models/task_item_blueprint.dart';
import 'package:test/test.dart';

import '../mocks/mock_data.dart';
import '../mocks/mock_data_builder.dart';

void main() {
  group('TaskItem', () {

    test('fromJSON', () {
      TaskItem catLitter = TaskItem.fromJson(catLitterJSON);
      expect(catLitter.docId, 'CAT_LITTER');
      expect(catLitter.name, 'Cat Litter');
      expect(catLitter.startDate, null);
      expect(catLitter.targetDate, catTarget);
      expect(catLitter.completionDate, catEnd);
      expect(catLitter.recurWait, true);
    });

    test('isCompleted', () {
      TaskItem catLitter = TaskItem.fromJson(catLitterJSON);
      expect(catLitter.isCompleted(), true);
    });

    test('isCompleted not completed', () {
      var taskItem = MockTaskItemBuilder
          .asDefault()
          .create();

      expect(taskItem.isCompleted(), false);
    });

    test('isScheduled is false for past date', () {
      TaskItem catLitter = TaskItem.fromJson(catLitterJSON);
      TaskItemBlueprint blueprint = catLitter.createBlueprint();
      blueprint.startDate = catTarget;
      expect(catTarget.isBefore(DateTime.now()), true);
      expect(blueprint.isScheduled(), false);
    });

    test('isScheduled is false for null date', () {
      TaskItem catLitter = TaskItem.fromJson(catLitterJSON);
      expect(catLitter.startDate, null);
      expect(catLitter.isScheduled(), false);
    });

    test('isScheduled is true for future date', () {
      DateTime futureDate = DateTime.now().add(Duration(days: 5));
      TaskItem catLitter = TaskItem.fromJson(catLitterJSON);
      TaskItemBlueprint blueprint = catLitter.createBlueprint();
      blueprint.startDate = futureDate;
      expect(blueprint.isScheduled(), true);
    });

    test('isPastDue is true for past date', () {
      TaskItem catLitter = TaskItem.fromJson(catLitterJSON);
      TaskItemBlueprint blueprint = catLitter.createBlueprint();
      blueprint.dueDate = catTarget;
      expect(catTarget.isBefore(DateTime.now()), true);
      expect(blueprint.isPastDue(), true);
    });

    test('isPastDue is false for null date', () {
      TaskItem catLitter = TaskItem.fromJson(catLitterJSON);
      expect(catLitter.dueDate, null);
      expect(catLitter.isPastDue(), false);
    });

    test('isPastDue is false for future date', () {
      DateTime futureDate = DateTime.now().add(Duration(days: 5));
      TaskItem catLitter = TaskItem.fromJson(catLitterJSON);
      TaskItemBlueprint blueprint = catLitter.createBlueprint();
      blueprint.dueDate = futureDate;
      expect(blueprint.isPastDue(), false);
    });

    test('isUrgent is true for past date', () {
      TaskItem catLitter = TaskItem.fromJson(catLitterJSON);
      TaskItemBlueprint blueprint = catLitter.createBlueprint();
      blueprint.urgentDate = catTarget;
      expect(catTarget.isBefore(DateTime.now()), true);
      expect(blueprint.isUrgent(), true);
    });

    test('isUrgent is false for null date', () {
      TaskItem catLitter = TaskItem.fromJson(catLitterJSON);
      expect(catLitter.urgentDate, null);
      expect(catLitter.isUrgent(), false);
    });

    test('isUrgent is false for future date', () {
      DateTime futureDate = DateTime.now().add(Duration(days: 5));
      TaskItem catLitter = TaskItem.fromJson(catLitterJSON);
      TaskItemBlueprint blueprint = catLitter.createBlueprint();
      blueprint.urgentDate = futureDate;
      expect(blueprint.isUrgent(), false);
    });

    test('getAnchorDate targetDate when only date', () {
      TaskItem catLitter = TaskItem.fromJson(catLitterJSON);
      var expected = catLitter.targetDate;
      var anchorDate = catLitter.getAnchorDate();
      expect(anchorDate?.dateValue, expected);
      expect(anchorDate?.dateType, TaskDateTypes.target);
    });

    test('getAnchorDate targetDate instead of start date', () {
      TaskItem catLitter = TaskItem.fromJson(catLitterJSON);
      TaskItemBlueprint blueprint = catLitter.createBlueprint();
      blueprint.startDate = catTarget.subtract(Duration(days: 3));
      var expected = catLitter.targetDate;
      var anchorDate = blueprint.getAnchorDate();
      expect(anchorDate?.dateValue, expected);
      expect(anchorDate?.dateType, TaskDateTypes.target);
    });

    test('getAnchorDate urgentDate', () {
      TaskItem catLitter = TaskItem.fromJson(catLitterJSON);
      var expected = catTarget.add(Duration(days: 4));
      TaskItemBlueprint blueprint = catLitter.createBlueprint();
      blueprint.urgentDate = expected;
      var anchorDate = blueprint.getAnchorDate();
      expect(anchorDate?.dateValue, expected);
      expect(anchorDate?.dateType, TaskDateTypes.urgent);
    });

    test('getAnchorDate dueDate', () {
      TaskItem catLitter = TaskItem.fromJson(catLitterJSON);
      var expected = catTarget.add(Duration(days: 6));
      var blueprint = catLitter.createBlueprint();
      blueprint.urgentDate = catTarget.add(Duration(days: 3));
      blueprint.dueDate = expected;
      var anchorDate = blueprint.getAnchorDate();
      expect(anchorDate?.dateValue, expected);
      expect(anchorDate?.dateType, TaskDateTypes.due);
    });

  });
}