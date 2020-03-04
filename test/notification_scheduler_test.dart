import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:taskmaster/flutter_badger_wrapper.dart';
import 'package:taskmaster/models/app_state.dart';
import 'package:taskmaster/models/task_item.dart';
import 'package:taskmaster/notification_scheduler.dart';
import 'package:taskmaster/task_repository.dart';
import 'package:test/test.dart';

import 'mocks/mock_app_state.dart';
import 'mocks/mock_client.dart';

import 'package:mockito/mockito.dart';
import 'mocks/mock_data.dart';
import 'mocks/mock_flutter_plugin.dart';

class MockAppBadger extends Mock implements FlutterBadgerWrapper {}

void main() {

  FlutterLocalNotificationsPlugin plugin;
  FlutterBadgerWrapper flutterBadgerWrapper;
  AppState appState;

  NotificationScheduler _createScheduler() {
    plugin = MockFlutterLocalNotificationsPlugin();
    flutterBadgerWrapper = MockAppBadger();
    appState = MockAppState();

    return new NotificationScheduler(
      context: null,
      appState: appState,
      taskAdder: (taskItem) => {},
      taskUpdater: (taskItem) => Future.value(taskItem),
      taskCompleter: (taskItem, completed) => Future.value(taskItem),
      flutterLocalNotificationsPlugin: plugin,
      flutterBadgerWrapper: flutterBadgerWrapper,
    );
  }

  test('construct', () {
    _createScheduler();
  });

  test('cancelAllNotifications', () {
    var scheduler = _createScheduler();
    scheduler.cancelAllNotifications();
    verify(plugin.cancelAll()).called(1);
  });

  test('cancelNotificationsForTaskId', () {
    var scheduler = _createScheduler();
    scheduler.cancelAllNotifications();
    verify(plugin.cancelAll()).called(1);
  });


}