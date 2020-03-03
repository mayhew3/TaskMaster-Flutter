import 'package:flutter/src/widgets/framework.dart';
import 'package:taskmaster/models/app_state.dart';
import 'package:taskmaster/nav_helper.dart';
import 'package:taskmaster/task_repository.dart';
import 'package:taskmaster/typedefs.dart';
import 'package:mockito/mockito.dart';

class MockNavHelper extends Mock implements NavHelper {

  @override
  BuildContext context;

  final AppState appState;
  final TaskRepository taskRepository;

  @override
  TaskAdder get taskAdder => (taskItem) => {};

  @override
  TaskCompleter get taskCompleter => (taskItem, complete) => Future.value(taskItem);

  @override
  TaskDeleter get taskDeleter => (taskItem) => null;

  @override
  TaskUpdater get taskUpdater => (taskItem) => Future.value(taskItem);

  @override
  TaskListReloader get taskListReloader => () => {};

  MockNavHelper({
    @required this.appState,
    @required this.taskRepository,
  });

  @override
  void goToHomeScreen() {
    // TODO: implement goToHomeScreen
  }

  @override
  void goToLoadingScreen(String msg) {
    // TODO: implement goToLoadingScreen
  }

  @override
  void goToSignInScreen() {
    // TODO: implement goToSignInScreen
  }

  @override
  void updateContext(BuildContext context) {
    // TODO: implement updateContext
  }

}