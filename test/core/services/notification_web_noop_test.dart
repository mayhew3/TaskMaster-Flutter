import 'package:flutter_test/flutter_test.dart';
import 'package:taskmaestro/core/services/notification_helper_impl.dart'
    show NotificationHelper;
import 'package:taskmaestro/core/services/notification_web_noop.dart';
import 'package:taskmaestro/models/sprint.dart';
import 'package:taskmaestro/models/task_item.dart';

void main() {
  group('NotificationHelperWebNoop', () {
    late NotificationHelper helper;

    setUp(() => helper = NotificationHelperWebNoop());

    test('is a NotificationHelper', () {
      expect(helper, isA<NotificationHelper>());
    });

    test('all methods complete without throwing (and without a plugin)',
        () async {
      final task = TaskItem((b) => b
        ..docId = 'task1'
        ..name = 'T'
        ..personDocId = 'person1'
        ..dateAdded = DateTime.now().toUtc()
        ..offCycle = false
        ..pendingCompletion = false);
      final sprint = Sprint((b) => b
        ..docId = 'sprint1'
        ..dateAdded = DateTime.now().toUtc()
        ..startDate = DateTime.now().toUtc()
        ..endDate = DateTime.now().toUtc().add(const Duration(days: 7))
        ..numUnits = 1
        ..unitName = 'week'
        ..personDocId = 'person1'
        ..sprintNumber = 1);

      await expectLater(helper.cancelAllNotifications(), completes);
      await expectLater(
          helper.cancelNotificationsForTaskId('task1'), completes);
      await expectLater(helper.syncNotificationForSprint(sprint), completes);
      await expectLater(
          helper.syncNotificationForTasksAndSprint([task], sprint), completes);
      await expectLater(helper.updateNotificationForTask(task), completes);
      await expectLater(
          helper.updateNotificationsForTasks([task]), completes);
    });
  });
}
