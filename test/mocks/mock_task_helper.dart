import 'package:mockito/mockito.dart';
import 'package:taskmaster/app_state.dart';
import 'package:taskmaster/task_helper.dart';
import 'package:taskmaster/task_repository.dart';

class MockTaskHelperOld extends Fake implements TaskHelper {

  @override
  late AppState appState;
  final TaskRepository taskRepository;

  MockTaskHelperOld({
    required this.taskRepository,
  });

}