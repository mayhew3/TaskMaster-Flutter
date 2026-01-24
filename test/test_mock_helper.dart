import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:taskmaster/models/sprint.dart';
import 'package:taskmaster/models/task_item.dart';
import 'package:taskmaster/models/task_item_blueprint.dart';
import 'package:taskmaster/models/task_recurrence.dart';
import 'package:taskmaster/task_repository.dart';

import 'mocks/mock_data_builder.dart';
import 'test_mock_helper.mocks.dart';

@GenerateNiceMocks([MockSpec<GoogleSignInAccount>(), MockSpec<FirebaseFirestore>()])
void main() {

}

class TestMockHelper {

  static TaskRepository createTaskRepositoryWithoutLoad({List<TaskItem>? taskItems, List<Sprint>? sprints}) {
    String email = 'scorpy@gmail.com';
    GoogleSignInAccount googleUser = MockGoogleSignInAccount();
    var mockFirebaseFirestore = MockFirebaseFirestore();

    TaskRepository taskRepository = TaskRepository(firestore: mockFirebaseFirestore);

    when(googleUser.email)
        .thenAnswer((_) => email);
    return taskRepository;
  }

  static Future<TaskRepository> createTaskRepositoryAndLoad({List<TaskItem>? taskItems, List<Sprint>? sprints}) async {
    TaskRepository taskRepository = createTaskRepositoryWithoutLoad(taskItems: taskItems, sprints: sprints);
    return taskRepository;
  }

  // helper methods

  static TaskItem mockAddTask(TaskItemBlueprint blueprint, String id, String? recurrenceDocId) {
    var recurrenceBlueprint = blueprint.recurrenceBlueprint;
    TaskRecurrence? recurrenceCopy;
    if (recurrenceBlueprint != null) {
      recurrenceCopy = TaskRecurrence((r) => r
        ..docId = recurrenceDocId
        ..personDocId = recurrenceBlueprint.personDocId
        ..name = recurrenceBlueprint.name
        ..recurNumber = recurrenceBlueprint.recurNumber
        ..recurUnit = recurrenceBlueprint.recurUnit
        ..recurWait = recurrenceBlueprint.recurWait
        ..recurIteration = recurrenceBlueprint.recurIteration
        ..anchorDate = recurrenceBlueprint.anchorDate!.toBuilder()
      );
    }

    TaskItem taskItem = TaskItem((t) => t
      ..name = blueprint.name
      ..docId = id
      ..personDocId = MockTaskItemBuilder.me
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
      ..recurrenceDocId = blueprint.recurrenceDocId
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
      recurrenceCopy = TaskRecurrence((r) => r
        ..docId = recurrence.docId
        ..dateAdded = recurrence.dateAdded
        ..personDocId = recurrence.personDocId
        ..name = recurrenceBlueprint.name ?? recurrence.name
        ..recurNumber = recurrenceBlueprint.recurNumber ?? recurrence.recurNumber
        ..recurUnit = recurrenceBlueprint.recurUnit ?? recurrence.name
        ..recurWait = recurrenceBlueprint.recurWait ?? recurrence.recurWait
        ..recurIteration = recurrenceBlueprint.recurIteration ?? recurrence.recurIteration
        ..anchorDate = recurrenceBlueprint.anchorDate?.toBuilder() ?? recurrence.anchorDate.toBuilder()
      );
    }

    TaskItem taskItem = TaskItem((t) => t
      ..name = blueprint.name
      ..docId = original.docId
      ..dateAdded = original.dateAdded
      ..personDocId = original.personDocId
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
      ..recurrenceDocId = blueprint.recurrenceDocId
      ..recurIteration = blueprint.recurIteration
      ..recurrence = recurrenceCopy?.toBuilder()
    );

    return taskItem;
  }

}
