import 'package:taskmaster/models/app_state.dart';
import 'package:taskmaster/models/task_item.dart';
import 'package:taskmaster/notification_scheduler.dart';
import 'package:taskmaster/task_repository.dart';
import 'package:test/test.dart';

import 'mocks/mock_app_state.dart';
import 'mocks/mock_client.dart';

import 'mocks/mock_data.dart';

void main() {

  test('construct', () {
    NotificationScheduler notificationScheduler = new NotificationScheduler(
        context: null,
        appState: MockAppState(),
        taskAdder: (taskItem) => {},
        taskUpdater: (taskItem) => Future.value(taskItem),
        taskCompleter: (taskItem, completed) => Future.value(taskItem));

  });

}