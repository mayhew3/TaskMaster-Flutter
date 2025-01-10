
import 'package:built_collection/built_collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:redux/redux.dart';
import 'package:taskmaster/date_util.dart';
import 'package:taskmaster/helpers/recurrence_helper.dart';
import 'package:taskmaster/models/snooze.dart';
import 'package:taskmaster/models/sprint.dart';
import 'package:taskmaster/models/task_date_type.dart';
import 'package:taskmaster/models/task_item.dart';
import 'package:taskmaster/models/task_item_blueprint.dart';
import 'package:taskmaster/models/task_recurrence.dart';
import 'package:taskmaster/redux/actions/task_item_actions.dart';
import 'package:taskmaster/redux/app_state.dart';
import 'package:taskmaster/redux/middleware/notification_helper.dart';
import 'package:taskmaster/redux/middleware/store_task_items_middleware.dart';
import 'package:taskmaster/routes.dart';
import 'package:taskmaster/task_repository.dart';
import 'package:test/test.dart';

import 'mocks/mock_data.dart';
import 'mocks/mock_data_builder.dart';
import 'mocks/mock_flutter_plugin.dart';
import 'mocks/mock_timezone_helper.dart';
import 'task_helper_test.mocks.dart';
import 'test_mock_helper.dart';

void main() {

  test('previewSnooze moves target and due dates', () {
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

  test('previewSnooze on task without a start date adds a start date', () {
    var taskItem = MockTaskItemBuilder
        .asDefault()
        .create().createBlueprint();

    RecurrenceHelper.generatePreview(taskItem, 4, 'Days', TaskDateTypes.start);

    var newStart = DateUtil.withoutMillis(taskItem.startDate!);
    var diffDue = newStart.difference(DateUtil.withoutMillis(DateTime.now())).inDays;

    expect(diffDue, 4, reason: 'Expect Start date to be 4 days from now.');

  });

}