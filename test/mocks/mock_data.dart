
import 'package:taskmaster/models/sprint.dart';
import 'package:taskmaster/models/task_item.dart';
import 'package:taskmaster/models/task_recurrence.dart';
import 'package:taskmaster/models/serializers.dart';

import 'mock_data_builder.dart';
import 'mock_recurrence_builder.dart';


final DateTime pastSprintStart = DateTime.now().subtract(Duration(days: 10));
final DateTime pastSprintAdded = DateTime.utc(2019, 6, 24, 8, 11, 56, 123);

final String currentSprintId = 'CURRENT_SPRINT';
final String pastSprintId = 'PAST_SPRINT';

final Map<String, dynamic> pastSprintJSON = {
  'docId': pastSprintId,
  'dateAdded': pastSprintStart.toIso8601String(),
  'startDate': pastSprintStart.toIso8601String(),
  'endDate': pastSprintStart.add(Duration(days: 7)).toIso8601String(),
  'numUnits': 1,
  'unitName': 'Weeks',
  'personDocId': MockTaskItemBuilder.me,
  'sprintNumber': 5,
  'sprintAssignments': [
    {
      'docId': '1234',
      'taskDocId': 'BIRTHDAY',
      'sprintDocId': pastSprintId
    },
    {
      'docId': '1233',
      'taskDocId': 'GLUTEN_FREE',
      'sprintDocId': pastSprintId
    }
  ]
};

final DateTime currentSprintStart = DateTime.now().subtract(Duration(days: 3));
final DateTime currentSprintAdded = DateTime.utc(2019, 7, 22, 1, 16, 8, 153);

final Map<String, dynamic> currentSprintJSON = {
  'docId': currentSprintId,
  'dateAdded': currentSprintStart.toIso8601String(),
  'startDate': currentSprintStart.toIso8601String(),
  'endDate': currentSprintStart.add(Duration(days: 7)).toIso8601String(),
  'numUnits': 1,
  'unitName': 'Weeks',
  'personDocId': MockTaskItemBuilder.me,
  'sprintNumber': 6,
  'sprintAssignments': [
    {
      'docId': '2346',
      'taskDocId': 'CAT_LITTER',
      'sprintDocId': currentSprintId
    },
    {
      'docId': '2345',
      'taskDocId': 'BIRTHDAY',
      'sprintDocId': currentSprintId
    },
    {
      'docId': '1233',
      'taskDocId': 'BURN_HOUSE',
      'sprintDocId': currentSprintId
    }
  ]
};

Sprint pastSprint = serializers.deserializeWith(Sprint.serializer, pastSprintJSON)!;
Sprint currentSprint = serializers.deserializeWith(Sprint.serializer, currentSprintJSON)!;

List<Sprint> allSprints = [pastSprint, currentSprint];

final DateTime catStart = DateTime.utc(2019, 11, 5, 3, 0, 0);
final DateTime catTarget = DateTime.utc(2019, 11, 7, 3, 0, 0);
final DateTime catEnd = DateTime.utc(2019, 11, 9, 2, 49, 43);
final DateTime catAdded = DateTime.utc(2019, 9, 27, 4, 34, 48, 460);
final DateTime catRetired = DateTime.utc(2019, 10, 18, 3, 14, 47, 666);
final Map<String, dynamic> catLitterJSON = {
  'docId': 'CAT_LITTER',
  'personDocId': MockTaskItemBuilder.me,
  'name': 'Cat Litter',
  'description': null,
  'project': 'Maintenance',
  'context': 'Home',
  'urgency': 4,
  'priority': 6,
  'duration': 12,
  'startDate': null,
  'targetDate': catTarget.toIso8601String(),
  'dueDate': null,
  'completionDate': catEnd.toIso8601String(),
  'offCycle': false,
  'urgentDate': null,
  'gamePoints': 5,
  'recurNumber': 10,
  'recurUnit': 'Days',
  'recurWait': true,
  'recurIteration': 1,
  'recurrenceDocId': 'CAT_LITTER_RECUR',
  'dateAdded': catAdded.toIso8601String(),
  'retired': null,
  'retiredDate': null,
};

final Map<String, dynamic> catLitterRecurrenceJSON = {
  'docId': 'CAT_LITTER_RECUR',
  'personDocId': MockTaskItemBuilder.me,
  'name': 'Cat Litter',
  'recurNumber': 10,
  'recurUnit': 'Days',
  'recurWait': true,
  'recurIteration': 1,
  'anchorDate': catAdded.toIso8601String(),
  'anchorType': 'Target',
  'dateAdded': catAdded.toIso8601String(),
  'retired': null,
  'retiredDate': null,
};

final DateTime bdayDue = DateTime.now().add(Duration(days: 20)).toUtc();
final DateTime bdayAdded = DateTime.utc(2019, 8, 30, 17, 32, 14, 674);

final Map<String, dynamic> birthdayJSON = {
  'docId': 'BIRTHDAY',
  'personDocId': MockTaskItemBuilder.me,
  'name': 'Hunter Birthday',
  'description': null,
  'project': 'Friends',
  'context': 'Planning',
  'urgency': 6,
  'priority': 7,
  'duration': 35,
  'startDate': null,
  'targetDate': null,
  'dueDate': bdayDue.toIso8601String(),
  'completionDate': null,
  'offCycle': false,
  'urgentDate': null,
  'gamePoints': 15,
  'recurNumber': null,
  'recurUnit': null,
  'recurWait': null,
  'recurIteration': null,
  'recurrenceDocId': null,
  'dateAdded': bdayAdded.toIso8601String(),
  'retired': null,
  'retiredDate': null,
};

final DateTime futureStart = DateTime.now().add(Duration(days: 90));
final DateTime futureAdded = DateTime.utc(2019, 6, 24, 8, 11, 56, 123);

final Map<String, dynamic> futureJSON = {
  'docId': 'BECOME_PRESIDENT',
  'personDocId': MockTaskItemBuilder.me,
  'name': 'Become President',
  'description': 'It could happen',
  'project': 'Projects',
  'context': 'Outside',
  'urgency': 3,
  'priority': 9,
  'duration': 1200,
  'startDate': futureStart.toIso8601String(),
  'targetDate': null,
  'dueDate': null,
  'completionDate': null,
  'offCycle': false,
  'urgentDate': null,
  'gamePoints': 15,
  'recurNumber': null,
  'recurUnit': null,
  'recurWait': null,
  'recurIteration': null,
  'recurrenceDocId': null,
  'dateAdded': futureAdded.toIso8601String(),
  'retired': null,
  'retiredDate': null,
};

final DateTime pastStart = DateTime.now().subtract(Duration(days: 90));
final DateTime pastAdded = DateTime.utc(2019, 6, 24, 8, 11, 56, 123);

final Map<String, dynamic> pastJSON = {
  'docId': 'GLUTEN_FREE',
  'personDocId': MockTaskItemBuilder.me,
  'name': 'Cut out Gluten',
  'description': 'Because my tummy',
  'project': 'Health',
  'context': 'Home',
  'urgency': 4,
  'priority': 5,
  'duration': 60,
  'startDate': pastStart.toIso8601String(),
  'targetDate': null,
  'dueDate': null,
  'completionDate': null,
  'offCycle': false,
  'urgentDate': null,
  'gamePoints': 15,
  'recurNumber': 6,
  'recurUnit': 'Weeks',
  'recurWait': false,
  'recurIteration': 1,
  'recurrenceDocId': 'CAT_LITTER_RECUR',
  'dateAdded': pastAdded.toIso8601String(),
  'retired': null,
  'retiredDate': null,
};

final DateTime burnTarget = DateTime.now().subtract(Duration(days: 10));
final DateTime burnComplete = DateTime.now().subtract(Duration(hours: 7));
final DateTime burnAdded = DateTime.utc(2019, 6, 24, 8, 11, 56, 123);

final Map<String, dynamic> burnJSON = {
  'docId': 'BURN_HOUSE',
  'personDocId': MockTaskItemBuilder.me,
  'name': 'Burn Down the House',
  'description': "Because you're talking to my talking head",
  'project': 'Organization',
  'context': 'Home',
  'urgency': 8,
  'priority': 4,
  'duration': 70,
  'startDate': null,
  'targetDate': burnTarget.toIso8601String(),
  'dueDate': null,
  'completionDate': burnComplete.toIso8601String(),
  'offCycle': false,
  'urgentDate': null,
  'gamePoints': 4,
  'recurNumber': null,
  'recurUnit': null,
  'recurWait': null,
  'recurIteration': null,
  'recurrenceDocId': null,
  'dateAdded': burnAdded.toIso8601String(),
  'retired': null,
  'retiredDate': null,
};

TaskItem catLitterTask = serializers.deserializeWith(TaskItem.serializer, catLitterJSON)!;
TaskItem birthdayTask = serializers.deserializeWith(TaskItem.serializer, birthdayJSON)!;
TaskItem futureTask = serializers.deserializeWith(TaskItem.serializer, futureJSON)!;
TaskItem pastTask = serializers.deserializeWith(TaskItem.serializer, pastJSON)!;
TaskItem burnTask = serializers.deserializeWith(TaskItem.serializer, burnJSON)!;

List<TaskItem> allTasks = [catLitterTask, birthdayTask, futureTask, pastTask, burnTask];

TaskRecurrence onlyRecurrence = MockTaskRecurrenceBuilder.asDefault().create();
