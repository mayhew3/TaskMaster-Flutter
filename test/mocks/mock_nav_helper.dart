import 'package:flutter/src/widgets/framework.dart';
import 'package:taskmaster/app_state.dart';
import 'package:taskmaster/nav_helper.dart';
import 'package:taskmaster/task_repository.dart';
import 'package:mockito/mockito.dart';

class MockNavHelper extends Mock implements NavHelper {

  @override
  late BuildContext context;

  @override
  AppState appState;
  final TaskRepository taskRepository;

  MockNavHelper({
    required this.appState,
    required this.taskRepository,
  });


}