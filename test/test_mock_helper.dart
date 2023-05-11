import 'dart:convert';

import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:taskmaster/app_state.dart';
import 'package:taskmaster/auth.dart';
import 'package:taskmaster/models/sprint.dart';
import 'package:taskmaster/models/task_item.dart';
import 'package:taskmaster/models/task_item_blueprint.dart';
import 'package:taskmaster/models/task_item_preview.dart';
import 'package:taskmaster/models/task_recurrence.dart';
import 'package:taskmaster/task_repository.dart';

import 'mocks/mock_data.dart';
import 'mocks/mock_task_master_auth.dart';
import 'test_mock_helper.mocks.dart';

@GenerateNiceMocks([MockSpec<http.Client>(), MockSpec<GoogleSignInAccount>()])
void main() {

}

class TestMockHelper {

  static TaskRepository createTaskRepositoryWithoutLoad({List<TaskItem>? taskItems, List<Sprint>? sprints}) {
    String email = 'scorpy@gmail.com';
    TaskMasterAuth auth = MockTaskMasterAuth();
    GoogleSignInAccount googleUser = new MockGoogleSignInAccount();
    http.Client client = new MockClient();

    AppState appState = new AppState(auth: auth);
    appState.currentUser = googleUser;
    appState.tokenRetrieved = true;
    TaskRepository taskRepository = TaskRepository(appState: appState, client: client);

    when(client.get(taskRepository.getUriWithParameters('/api/tasks', {'email': email}), headers: anyNamed('headers')))
        .thenAnswer((_) async => http.Response(_mockTheJSON(taskItems: taskItems, sprints: sprints), 200));
    when(googleUser.email)
        .thenAnswer((_) => email);
    return taskRepository;
  }

  static Future<TaskRepository> createTaskRepositoryAndLoad({List<TaskItem>? taskItems, List<Sprint>? sprints}) async {
    TaskRepository taskRepository = createTaskRepositoryWithoutLoad(taskItems: taskItems, sprints: sprints);
    await taskRepository.loadTasks((callback) => callback());
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

  static TaskItem mockAddTask(TaskItemPreview taskItemPreview) {
    TaskItem taskItem = new TaskItem(
      name: taskItemPreview.name,
      id: 1,
      personId: 1,
      description: taskItemPreview.description,
      project: taskItemPreview.project,
      context: taskItemPreview.context,
      urgency: taskItemPreview.urgency,
      priority: taskItemPreview.priority,
      duration: taskItemPreview.duration,
      gamePoints: taskItemPreview.gamePoints,
      startDate: taskItemPreview.startDate,
      targetDate: taskItemPreview.targetDate,
      urgentDate: taskItemPreview.urgentDate,
      dueDate: taskItemPreview.dueDate,
      completionDate: taskItemPreview.completionDate,
      recurNumber: taskItemPreview.recurNumber,
      recurUnit: taskItemPreview.recurUnit,
      recurWait: taskItemPreview.recurWait,
      recurrenceId: taskItemPreview.recurrenceId,
      recurIteration: taskItemPreview.recurIteration,
    );

    return taskItem;
  }

  static TaskItem mockEditTask(TaskItem original, TaskItemBlueprint blueprint) {
    TaskItem taskItem = new TaskItem(
      name: original.name,
      id: original.id,
      personId: 1,
      description: blueprint.description,
      project: blueprint.project,
      context: blueprint.context,
      urgency: blueprint.urgency,
      priority: blueprint.priority,
      duration: blueprint.duration,
      gamePoints: blueprint.gamePoints,
      startDate: blueprint.startDate,
      targetDate: blueprint.targetDate,
      urgentDate: blueprint.urgentDate,
      dueDate: blueprint.dueDate,
      completionDate: blueprint.completionDate,
      recurNumber: blueprint.recurNumber,
      recurUnit: blueprint.recurUnit,
      recurWait: blueprint.recurWait,
      recurrenceId: blueprint.recurrenceId,
      recurIteration: blueprint.recurIteration,
    );

    return taskItem;
  }

}
