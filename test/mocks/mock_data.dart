
import 'package:taskmaster/models/sprint.dart';
import 'package:taskmaster/models/task_item.dart';
import 'package:taskmaster/models/task_recurrence.dart';

import 'mock_recurrence_builder.dart';


final DateTime pastSprintStart = DateTime.now().subtract(Duration(days: 10));
final DateTime pastSprintAdded = DateTime.utc(2019, 6, 24, 8, 11, 56, 123);

final Map<String, dynamic> pastSprintJSON = {
  "id": 10,
  "start_date": pastSprintStart.toIso8601String(),
  "end_date": pastSprintStart.add(Duration(days: 7)).toIso8601String(),
  "num_units": 1,
  "unit_name": "Weeks",
  "person_id": 1,
  "sprint_number": 5
};

final DateTime currentSprintStart = DateTime.now().subtract(Duration(days: 3));
final DateTime currentSprintAdded = DateTime.utc(2019, 7, 22, 1, 16, 8, 153);

final Map<String, dynamic> currentSprintJSON = {
  "id": 11,
  "start_date": currentSprintStart.toIso8601String(),
  "end_date": currentSprintStart.add(Duration(days: 7)).toIso8601String(),
  "num_units": 1,
  "unit_name": "Weeks",
  "person_id": 1,
  "sprint_number": 6
};

Sprint pastSprint = Sprint.fromJson(pastSprintJSON);
Sprint currentSprint = Sprint.fromJson(currentSprintJSON);

List<Sprint> allSprints = [pastSprint, currentSprint];

final DateTime catStart = DateTime.utc(2019, 11, 5, 3, 0, 0);
final DateTime catTarget = DateTime.utc(2019, 11, 7, 3, 0, 0);
final DateTime catEnd = DateTime.utc(2019, 11, 9, 2, 49, 43);
final DateTime catAdded = DateTime.utc(2019, 9, 27, 4, 34, 48, 460);
final DateTime catRetired = DateTime.utc(2019, 10, 18, 3, 14, 47, 666);
final Map<String, dynamic> catLitterJSON = {
  "id": 25,
  "person_id": 1,
  "name": "Cat Litter",
  "description": null,
  "project": "Maintenance",
  "context": "Home",
  "urgency": 4,
  "priority": 6,
  "duration": 12,
  "start_date": null,
  "target_date": catTarget.toIso8601String(),
  "due_date": null,
  "completion_date": catEnd.toIso8601String(),
  "urgent_date": null,
  "game_points": 5,
  "recur_number": 10,
  "recur_unit": "Days",
  "recur_wait": true,
  "recur_iteration": 1,
  "recurrence_id": 1,
  "date_added": catAdded.toIso8601String(),
  "retired": 0,
  "retired_date": null,
  "sprint_assignments": [
    {
      "id": 2346,
      "sprint_id": currentSprint.id
    }
  ]
};

final Map<String, dynamic> catLitterRecurrenceJSON = {
  "id": 1,
  "person_id": 1,
  "name": "Cat Litter",
  "recur_number": 10,
  "recur_unit": "Days",
  "recur_wait": true,
  "recur_iteration": 1,
  "anchor_date": catAdded.toIso8601String(),
  "anchor_type": "Target",
  "date_added": catAdded.toIso8601String(),
  "retired": 0,
  "retired_date": null,
};

final DateTime bdayDue = DateTime.now().add(Duration(days: 20)).toUtc();
final DateTime bdayAdded = DateTime.utc(2019, 8, 30, 17, 32, 14, 674);

final Map<String, dynamic> birthdayJSON = {
  "id": 26,
  "person_id": 1,
  "name": "Hunter Birthday",
  "description": null,
  "project": "Friends",
  "context": "Planning",
  "urgency": 6,
  "priority": 7,
  "duration": 35,
  "start_date": null,
  "target_date": null,
  "due_date": bdayDue.toIso8601String(),
  "completion_date": null,
  "urgent_date": null,
  "game_points": 15,
  "recur_number": null,
  "recur_unit": null,
  "recur_wait": null,
  "recur_iteration": null,
  "recurrence_id": null,
  "date_added": bdayAdded.toIso8601String(),
  "retired": 0,
  "retired_date": null,
  "sprint_assignments": [
    {
      "id": 1234,
      "sprint_id": pastSprint.id
    },
    {
      "id": 2345,
      "sprint_id": currentSprint.id
    }
  ]
};

final DateTime futureStart = DateTime.now().add(Duration(days: 90));
final DateTime futureAdded = DateTime.utc(2019, 6, 24, 8, 11, 56, 123);

final Map<String, dynamic> futureJSON = {
  "id": 27,
  "person_id": 1,
  "name": "Become President",
  "description": "It could happen",
  "project": "Projects",
  "context": "Outside",
  "urgency": 3,
  "priority": 9,
  "duration": 1200,
  "start_date": futureStart.toIso8601String(),
  "target_date": null,
  "due_date": null,
  "completion_date": null,
  "urgent_date": null,
  "game_points": 15,
  "recur_number": null,
  "recur_unit": null,
  "recur_wait": null,
  "recur_iteration": null,
  "recurrence_id": null,
  "date_added": futureAdded.toIso8601String(),
  "retired": 0,
  "retired_date": null,
  "sprint_assignments": []
};

final DateTime pastStart = DateTime.now().subtract(Duration(days: 90));
final DateTime pastAdded = DateTime.utc(2019, 6, 24, 8, 11, 56, 123);

final Map<String, dynamic> pastJSON = {
  "id": 28,
  "person_id": 1,
  "name": "Cut out Gluten",
  "description": "Because my tummy",
  "project": "Health",
  "context": "Home",
  "urgency": 4,
  "priority": 5,
  "duration": 60,
  "start_date": pastStart.toIso8601String(),
  "target_date": null,
  "due_date": null,
  "completion_date": null,
  "urgent_date": null,
  "game_points": 15,
  "recur_number": 6,
  "recur_unit": 'Weeks',
  "recur_wait": false,
  "recur_iteration": 1,
  "recurrence_id": 1,
  "date_added": pastAdded.toIso8601String(),
  "retired": 0,
  "retired_date": null,
  "sprint_assignments": [
    {
      "id": 1233,
      "sprint_id": pastSprint.id
    }
  ]
};

final DateTime burnTarget = DateTime.now().subtract(Duration(days: 10));
final DateTime burnComplete = DateTime.now().subtract(Duration(hours: 7));
final DateTime burnAdded = DateTime.utc(2019, 6, 24, 8, 11, 56, 123);

final Map<String, dynamic> burnJSON = {
  "id": 29,
  "person_id": 1,
  "name": "Burn Down the House",
  "description": "Because you're talking to my talking head",
  "project": "Organization",
  "context": "Home",
  "urgency": 8,
  "priority": 4,
  "duration": 70,
  "start_date": null,
  "target_date": burnTarget.toIso8601String(),
  "due_date": null,
  "completion_date": burnComplete.toIso8601String(),
  "urgent_date": null,
  "game_points": 4,
  "recur_number": null,
  "recur_unit": null,
  "recur_wait": null,
  "recur_iteration": null,
  "recurrence_id": null,
  "date_added": burnAdded.toIso8601String(),
  "retired": 0,
  "retired_date": null,
  "sprint_assignments": [
    {
      "id": 1233,
      "sprint_id": currentSprint.id
    }
  ]
};

TaskItem catLitterTask = TaskItem.fromJson(catLitterJSON);
TaskItem birthdayTask = TaskItem.fromJson(birthdayJSON);
TaskItem futureTask = TaskItem.fromJson(futureJSON);
TaskItem pastTask = TaskItem.fromJson(pastJSON);
TaskItem burnTask = TaskItem.fromJson(burnJSON);

List<TaskItem> allTasks = [catLitterTask, birthdayTask, futureTask, pastTask, burnTask];

TaskRecurrence onlyRecurrence = TaskRecurrenceBuilder.asDefault().create();
