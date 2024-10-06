import 'dart:convert';

import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:taskmaster/models/sprint.dart';
import 'package:taskmaster/models/task_item.dart';
import 'package:taskmaster/models/task_item_blueprint.dart';
import 'package:taskmaster/models/task_recurrence.dart';
import 'package:taskmaster/task_repository.dart';

import 'mocks/mock_data.dart';
import 'test_mock_helper.mocks.dart';

@GenerateNiceMocks([MockSpec<http.Client>(), MockSpec<GoogleSignInAccount>()])
void main() {

}

class TestMockHelper {

  static TaskRepository createTaskRepositoryWithoutLoad({List<TaskItem>? taskItems, List<Sprint>? sprints}) {
    String email = 'scorpy@gmail.com';
    GoogleSignInAccount googleUser = new MockGoogleSignInAccount();
    http.Client client = new MockClient();

    TaskRepository taskRepository = TaskRepository(client: client);

    when(client.get(taskRepository.getUriWithParameters('/api/tasks', {'person_id': "1"}), headers: anyNamed('headers')))
        .thenAnswer((_) async => http.Response(_mockTheJSON(taskItems: taskItems, sprints: sprints), 200));
    when(googleUser.email)
        .thenAnswer((_) => email);
    return taskRepository;
  }

  static Future<TaskRepository> createTaskRepositoryAndLoad({List<TaskItem>? taskItems, List<Sprint>? sprints}) async {
    TaskRepository taskRepository = createTaskRepositoryWithoutLoad(taskItems: taskItems, sprints: sprints);
    await taskRepository.loadTasks(1, 'token');
    return taskRepository;
  }

  // helper methods

  static dynamic _getMockTask(TaskItem taskItem) {
    return taskItem.toJson();
  }

  static String _mockTheJSON({List<TaskItem>? taskItems, List<Sprint>? sprints, List<TaskRecurrence>? recurrences}) {
    var taskObj = {};
    taskObj['person_id'] = 1;
    var mockTaskList = [];
    var mockSprintList = [];
    var mockRecurrenceList = [];

    for (var taskItem in taskItems ?? allTasks) {
      mockTaskList.add(_getMockTask(taskItem));
    }

    for (var sprintItem in sprints ?? allSprints) {
      mockSprintList.add(sprintItem.toJson());
    }

    for (var recurrence in recurrences ?? []) {
      mockRecurrenceList.add(recurrence.toJson());
    }

    taskObj['tasks'] = mockTaskList;
    taskObj['sprints'] = mockSprintList;
    taskObj['taskRecurrences'] = mockRecurrenceList;
    return json.encode(taskObj);
  }

  static TaskItem mockAddTask(TaskItemBlueprint blueprint, int id, int? recurrenceId) {
    var recurrenceBlueprint = blueprint.recurrenceBlueprint;
    TaskRecurrence? recurrenceCopy;
    if (recurrenceBlueprint != null) {
      recurrenceCopy = new TaskRecurrence((r) => r
        ..id = recurrenceId
        ..personId = recurrenceBlueprint.personId
        ..name = recurrenceBlueprint.name
        ..recurNumber = recurrenceBlueprint.recurNumber
        ..recurUnit = recurrenceBlueprint.recurUnit
        ..recurWait = recurrenceBlueprint.recurWait
        ..recurIteration = recurrenceBlueprint.recurIteration
        ..anchorDate = recurrenceBlueprint.anchorDate
        ..anchorType = recurrenceBlueprint.anchorType);
    }

    TaskItem taskItem = new TaskItem((t) => t
      ..name = blueprint.name
      ..id = id
      ..personId = 1
      ..description = blueprint.description
      ..project = blueprint.project
      ..context = blueprint.context
      ..urgency = blueprint.urgency
      ..priority = blueprint.priority
      ..duration = blueprint.duration
      ..gamePoints = blueprint.gamePoints
      ..startDate = blueprint.startDate
      ..targetDate = blueprint.targetDate
      ..urgentDate = blueprint.urgentDate
      ..dueDate = blueprint.dueDate
      ..completionDate = blueprint.completionDate
      ..offCycle = blueprint.offCycle
      ..recurNumber = blueprint.recurNumber
      ..recurUnit = blueprint.recurUnit
      ..recurWait = blueprint.recurWait
      ..recurrenceId = blueprint.recurrenceId
      ..recurIteration = blueprint.recurIteration
      ..recurrence = recurrenceCopy?.toBuilder()
    );

    return taskItem;

  }

  static TaskItem mockEditTask(TaskItem original, TaskItemBlueprint blueprint) {
    var recurrenceBlueprint = blueprint.recurrenceBlueprint;
    var recurrence = original.recurrence;
    TaskRecurrence? recurrenceCopy;
    if (recurrenceBlueprint != null && recurrence != null) {
      recurrenceCopy = new TaskRecurrence((r) => r
        ..id = recurrence.id
        ..personId = recurrence.personId
        ..name = recurrenceBlueprint.name ?? recurrence.name
        ..recurNumber = recurrenceBlueprint.recurNumber ?? recurrence.recurNumber
        ..recurUnit = recurrenceBlueprint.recurUnit ?? recurrence.name
        ..recurWait = recurrenceBlueprint.recurWait ?? recurrence.recurWait
        ..recurIteration = recurrenceBlueprint.recurIteration ?? recurrence.recurIteration
        ..anchorDate = recurrenceBlueprint.anchorDate ?? recurrence.anchorDate
        ..anchorType = recurrenceBlueprint.anchorType ?? recurrence.anchorType);
    }

    TaskItem taskItem = new TaskItem((t) => t
      ..name = original.name
      ..id = original.id
      ..personId = 1
      ..description = blueprint.description
      ..project = blueprint.project
      ..context = blueprint.context
      ..urgency = blueprint.urgency
      ..priority = blueprint.priority
      ..duration = blueprint.duration
      ..gamePoints = blueprint.gamePoints
      ..startDate = blueprint.startDate
      ..targetDate = blueprint.targetDate
      ..urgentDate = blueprint.urgentDate
      ..dueDate = blueprint.dueDate
      ..completionDate = blueprint.completionDate
      ..offCycle = blueprint.offCycle
      ..recurNumber = blueprint.recurNumber
      ..recurUnit = blueprint.recurUnit
      ..recurWait = blueprint.recurWait
      ..recurrenceId = blueprint.recurrenceId
      ..recurIteration = blueprint.recurIteration
      ..recurrence = recurrenceCopy?.toBuilder()
    );

    return taskItem;
  }

}
