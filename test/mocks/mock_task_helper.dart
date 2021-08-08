import 'package:flutter/src/widgets/framework.dart';
import 'package:mockito/mockito.dart';
import 'package:taskmaster/app_state.dart';
import 'package:taskmaster/models/task_item.dart';
import 'package:taskmaster/task_helper.dart';
import 'package:taskmaster/task_repository.dart';

class MockTaskHelper extends Mock implements TaskHelper {

  @override
  AppState appState;
  final TaskRepository taskRepository;

  MockTaskHelper({
    required this.taskRepository,
  });

}