
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:taskmaster/date_util.dart';
import 'package:taskmaster/helpers/recurrence_helper.dart';
import 'package:taskmaster/models/task_date_type.dart';
import 'package:taskmaster/models/task_item.dart';
import 'package:taskmaster/models/task_item_blueprint.dart';
import 'package:taskmaster/redux/actions/task_item_actions.dart';
import 'package:taskmaster/task_repository.dart';
import 'package:test/test.dart';

import 'mocks/mock_data_builder.dart';
import 'task_helper_test.mocks.dart';
import 'test_mock_helper.dart';

@GenerateNiceMocks([MockSpec<TaskRepository>()])
void main() {


  // generatePreview()

  test('generatePreview moves target and due dates', () {
    var blueprint = MockTaskItemBuilder.withDates()
      .create().createBlueprint();

    var originalTarget = blueprint.targetDate!;
    var originalDue = blueprint.dueDate!;

    RecurrenceHelper.generatePreview(blueprint, 6, 'Days', TaskDateTypes.target);

    var newTarget = DateUtil.withoutMillis(blueprint.targetDate!);
    var diffTarget = newTarget.difference(DateUtil.withoutMillis(DateTime.now())).inDays;

    expect(diffTarget, 6, reason: 'Expect Target date to be in 6 days.');
    expect(newTarget.hour, originalTarget.hour, reason: 'Expect hour of target date to be unchanged.');

    var newDue = DateUtil.withoutMillis(blueprint.dueDate!);
    var diffDue = newDue.difference(DateUtil.withoutMillis(DateTime.now())).inDays;

    expect(diffDue, 13, reason: 'Expect Due date to be in 13 days.');
    expect(newDue.hour, originalDue.hour, reason: 'Expect hour of due date to be unchanged.');

  });

  test('generatePreview on task without a start date adds a start date', () {
    var taskItem = MockTaskItemBuilder
        .asDefault()
        .create().createBlueprint();

    RecurrenceHelper.generatePreview(taskItem, 4, 'Days', TaskDateTypes.start);

    var newStart = DateUtil.withoutMillis(taskItem.startDate!);
    var diffDue = newStart.difference(DateUtil.withoutMillis(DateTime.now())).inDays;

    expect(diffDue, 4, reason: 'Expect Start date to be 4 days from now.');

  });


  // updateTaskAndMaybeRecurrence()

  test('updateTaskAndMaybeRecurrence with no recurrence', () {
    var mockTaskRepository = MockTaskRepository();

    var taskItem = MockTaskItemBuilder
        .asDefault()
        .create();
    var blueprint = taskItem.createBlueprint();

    var action = ExecuteSnooze(taskItem: taskItem, blueprint: blueprint, numUnits: 3, unitSize: 'Days', dateType: TaskDateTypes.due);

    TaskItem? resultTask;
    TaskItemBlueprint? resultingBlueprint;

    when(mockTaskRepository.updateTaskAndRecurrence(taskItem.docId, any)).thenAnswer((invocation) {
      resultingBlueprint = invocation.positionalArguments[1];
      resultTask = TestMockHelper.mockEditTask(taskItem, resultingBlueprint!);
      return Future.value((taskItem: resultTask!, recurrence: null));
    });

    RecurrenceHelper.updateTaskAndMaybeRecurrence(mockTaskRepository, action);

    expect(resultingBlueprint, blueprint);
    verify(mockTaskRepository.updateTaskAndRecurrence(taskItem.docId, resultingBlueprint));

  });

  test('updateTaskAndMaybeRecurrence with On Complete recurrence', () {
    expect(1, 0, reason: 'To implement');
  });

  test('updateTaskAndMaybeRecurrence with On Schedule recurrence, off cycle', () {
    expect(1, 0, reason: 'To implement');
  });

  test('updateTaskAndMaybeRecurrence with On Schedule recurrence, on cycle', () {
    expect(1, 0, reason: 'To implement');
  });


}