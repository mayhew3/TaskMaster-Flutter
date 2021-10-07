import 'package:mockito/mockito.dart';
import 'package:taskmaster/app_state.dart';
import 'package:taskmaster/task_helper.dart';
import 'package:taskmaster/task_repository.dart';

class MockTaskHelper extends Fake implements TaskHelper {

  @override
  late AppState appState;
  final TaskRepository taskRepository;

  MockTaskHelper({
    required this.taskRepository,
  });

}